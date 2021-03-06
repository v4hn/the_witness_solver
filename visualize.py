#!/usr/bin/env python

import clingo
import sys

# import pdb; pdb.set_trace()

class Box:
	def __init__(self, lower, upper):
		self.lower= [lower[0], lower[1]]
		self.upper= [upper[0], upper[1]]
	def include(self, box):
		self.lower[0]= min(self.lower[0], box.lower[0])
		self.lower[1]= min(self.lower[1], box.lower[1])
		self.upper[0]= max(self.upper[0], box.upper[0])
		self.upper[1]= max(self.upper[1], box.upper[1])
	def viewBox(self):
		return " ".join([
			str(self.lower[0]),
			str(self.lower[1]),
			str(self.upper[0]-self.lower[0]),
			str(self.upper[1]-self.lower[1])])

class Figure:
	def __init__(self, atom):
		self.name= atom.name
		self.args= {}
		for i in range(len(atom.arguments)):
			arg= atom.arguments[i]
			aname= arg.name
			if arg.arguments[0].type == clingo.SymbolType.String:
				aval= arg.arguments[0].string
			elif arg.arguments[0].type == clingo.SymbolType.Number:
				aval= arg.arguments[0].number
			self.args[aname]= aval
	def svg(self):
		return (
			'<'+self.name+
			' '+' '.join([k+'="'+str(self.args[k])+'"' for k in self.args])+
			'/>')
	def getBox(self):
		raise NotImplementedError()

class Circle(Figure):
	def __init__(self, atom):
		super().__init__(atom)
	def getBox(self):
		return Box(
			(self.args["cx"]-self.args["r"], self.args["cy"]-self.args["r"]),
			(self.args["cx"]+self.args["r"], self.args["cy"]+self.args["r"])
			)

class Rect(Figure):
	def __init__(self, atom):
		super().__init__(atom)
	def getBox(self):
		return Box(
			(self.args["x"], self.args["y"]),
			(self.args["x"]+self.args["width"], self.args["y"]+self.args["height"])
			)

class Line(Figure):
	def __init__(self, atom):
		super().__init__(atom)
	def getBox(self):
		P1=self.args["x1"]
		return Box(
			(
				min(self.args["x1"], self.args["x2"]),
				min(self.args["y1"], self.args["y2"])
			),
			(
				max(self.args["x1"], self.args["x2"]),
				max(self.args["y1"], self.args["y2"])
			)
			)

ClassMap = {
	"circle" : Circle,
	"rect" : Rect,
	"line" : Line,
}

def parse_atoms(draw):
	draw_out = []
	for fig in draw:
		for i in range(len(fig["figure"])):
			f= {"layer" : fig["layer"]}
			f["figure"]= ClassMap[fig["figure"][i].name](fig["figure"][i])
			draw_out.append(f)
	return draw_out

def serialize(model):
	symbols= {}
	draw = [{ "layer" : d.arguments[0].number, "figure" : d.arguments[1:]} for d in model.symbols(atoms= True) if d.name == "draw"]

	draw.sort(key= lambda d: d["layer"])

	draw= parse_atoms(draw)

	canvas= Box((0,0),(0,0))
	for fig in draw:
		canvas.include(fig["figure"].getBox())

	svg= '<svg viewBox="'+canvas.viewBox()+'">\n'
	for d in draw:
		svg+= d["figure"].svg()+"\n"
	svg+= '</svg>'
	return svg

def solve(lp, instance, sols, programs):
	ctl = clingo.Control(["-n", str(sols)])
	ctl.load(lp)
	if len(instance) > 0:
		ctl.load(instance)
	ctl.ground([(x,[]) for x in programs])
	with ctl.solve(yield_= True) as solutions:
		for s in solutions:
			yield s


if __name__ == '__main__':
	sols= int(sys.argv[2]) if len(sys.argv) > 2 else 1
	instance= sys.argv[1] if len(sys.argv) > 1 else ""
	print(
'''<html>
<head>
<title>Witness Puzzle</title>
<style>
div.solution {
        display:inline-block;
        min-width:200px;
        width: 22%;
        background-color: white;
        border: 10px solid green;
        padding: 5px;
        margin: 5px;
}

/*
div.solution:hover {
	transform:scale(1.7);
        transform-origin: top left;
}
*/
</style>
</head>
<body>
<div id="solutions">''')
	for s in solve("witness.lp", instance, sols, ["base", "visualize"]):
		print('<div class="solution">')
		print(serialize(s))
		print('</div>')
	#TODO: is there really no way to reset a Control object?
	for s in solve("witness.lp", instance, sols, ["base", "constraints", "visualize", "visualize_solution"]):
		print('<div class="solution">')
		print(serialize(s))
		print('</div>')
	print(
'''</div>
</body>
</html>''')
