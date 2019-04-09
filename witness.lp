%%%%%%%%%%%
% example %
%%%%%%%%%%%

% surrounding grid of crossings/corners
grid(4,4).

% start/exit position
start(c(0,0)).
exit(c(3,1)).

blocked(c(3,3)).
blocked(p(c(1,2),c(2,2))).
dot(p(c(0,2), c(0,3))).
dot(c(1,1)).

triangles(3,b(0,2)).

colored_block(b(0,1), "green").
colored_block(b(0,0), "orange").

%%%%%%%%%%%%%%%
% explanation %
%%%%%%%%%%%%%%%

#program definitions.

% coordinate does not exist in map
blocked(c(x,y)).
% line does not exist on map
blocked(p(c(x1,y1),c(x2,y2))).

% dot on the connecting line
dot(p(c(x1,y1), c(x2,y2))).

% dot on the crossing
dot(c(x,y)).

% n triangles on block
triangles(n,b(x,y)).

% block has color
colored_block(b(x,y), color).

%%%%%%%%%
% model %
%%%%%%%%%

#program base.

% coordinates are locations on the grid
coordinate(c(0..X-1, 0..Y-1)) :- grid(X,Y).
% crossings are existing crossings on the map
crossing(A) :-
	coordinate(A);
	not blocked(A).

% blocks are the square areas between coordinates/lines
block(b(0..X-2, 0..Y-2)) :- grid(X,Y).

% helpers
neighbor_offset(0,1).
neighbor_offset(1,0).

blocked(p(A,B)) :- blocked(p(B,A)).

% connecting lines on the grid
line(p(c(X1,Y1),c(X2,Y2))) :-
	crossing(c(X1,Y1));
	crossing(c(X2,Y2));
	X2= X1+XO;
	Y2= Y1+YO;
	neighbor_offset(XO,YO).
% paths are lines on the map that are not deliberately blocked
path(P) :-
	line(P);
	not blocked(P).
% symmetric version of path/1.
path_sym(P) :- path(P).
path_sym(p(B,A)) :- path_sym(p(A,B)).

% relate blocks on the grid to their corresponding surrounding paths
4 {
paths_around_block(b(X,Y), p(c(X,Y), c(X+1,Y)));
paths_around_block(b(X,Y), p(c(X,Y), c(X,Y+1)));
paths_around_block(b(X,Y), p(c(X+1,Y), c(X+1,Y+1)));
paths_around_block(b(X,Y), p(c(X,Y+1), c(X+1,Y+1)))
} :-
	block(b(X,Y)).

% connection might be made by drawing the line on a path
% this is the main choice in this puzzle
0{conn(P)}1 :- path(P).
connection(P) :- conn(P).
connection(p(B,A)) :- conn(p(A,B)).

% always link start and exit
linked(S) :- start(S).
linked(A) :- linked(B); connection(p(A,B)).
:- not linked(E); exit(E).

% start and exit only have one connecting line
:- start(S), 2 { connection(p(S,B)) : connection(p(S,B)) }.
:- exit(S), 2 { connection(p(S,B)) : connection(p(S,B)) }.

% enforce a single line without intersections
used(A) :- connection(p(A,_)).
:- crossing(A); 3 { connection(p(A,B)) : connection(p(A,B)) }.
:- used(A); not linked(A).

% line forced by dot
conn(p(A,B)) :-
	dot(p(A,B)),
	crossing(A),
	crossing(B).

% crossing forced by dot
:- dot(A),
	not used(A),
	crossing(A).

% force N paths around triangle block
N { conn(P) : paths_around_block(B,P) } N :-
	triangles(N, B),
	block(B).

block_connection(b(Xb1,Yb1), b(Xb2,Yb2)) :-
	not connection(p(c(X1,Y1),c(X1+1,Y1))),
	Xb1=X1, Yb1=Y1-1,
	Xb2=X1, Yb2=Y1,
	block(b(Xb1,Yb1)),
	block(b(Xb2,Yb2)).
block_connection(b(Xb1,Yb1), b(Xb2,Yb2)) :-
	not connection(p(c(X1,Y1),c(X1,Y1+1))),
	Xb1=X1-1, Yb1=Y1,
	Xb2=X1, Yb2=Y1,
	block(b(Xb1,Yb1)),
	block(b(Xb2,Yb2)).
block_connection(B1,B2) :- block_connection(B2,B1).

floodfilled_color(B, Color) :- colored_block(B, Color).
floodfilled_color(Bn, Color) :-
	floodfilled_color(B, Color),
	block_connection(B, Bn).

0 { floodfilled_color(B, Color) : floodfilled_color(B,Color) } 1 :- block(B).

%%%%%%%%%%%%%%%%%
% visualization %
%%%%%%%%%%%%%%%%%

#const n= 20.
#const lwidth= n/5.

% rounded off grid
draw(1, circle(cx(n*X), cy(n*Y), r(lwidth/2), fill("black"))) :-
	crossing(c(X,Y)).
draw(1, line(x1(n*X1), y1(n*Y1), x2(n*X2), y2(n*Y2), stroke("black"), style("stroke-width:4"))) :-
	path(p(c(X1,Y1), c(X2,Y2))).

% big circle around start
draw(2, circle(cx(n*X), cy(n*Y), r(lwidth), fill("black"))) :-
	start(c(X,Y)).

%TODO: add and use above/2, below/2, left/2, right/2.
%TODO: add and use path_left/2, path_right/2, path_up/2, path_down/2.

% draw exit depending on direction
exit_direction(c(X,Y), up) :-
	exit(c(X,Y));
	not path(p(c(X,Y-1), c(X,Y))).
exit_direction(c(X,Y), down) :-
	exit(c(X,Y));
	not path(p(c(X,Y), c(X,Y+1))).
exit_direction(c(X,Y), left) :-
	exit(c(X,Y));
	not path(p(c(X-1,Y), c(X,Y)));
	not exit_direction(c(X,Y), down);
	not exit_direction(c(X,Y), up).
exit_direction(c(X,Y), right) :-
	exit(c(X,Y));
	not path(p(c(X,Y), c(X+1,Y)));
	not exit_direction(c(X,Y), down);
	not exit_direction(c(X,Y), up).

draw(2,
	rect(x(n*X-n/3), y(n*Y-lwidth/2), width(n/3), height(lwidth), fill("black")),
	circle(cx(n*X-n/3), cy(n*Y), r(lwidth/2), fill("black"))
	) :- exit_direction(c(X,Y), left).
draw(2,
	rect(x(n*X), y(n*Y-lwidth/2), width(n/3), height(lwidth), fill("black")),
	circle(cx(n*X+n/3), cy(n*Y), r(lwidth/2), fill("black"))
	) :-
	exit_direction(c(X,Y), right).
draw(2,
	rect(x(n*X-lwidth/2), y(n*Y-n/3), width(lwidth), height(n/3), fill("black")),
	circle(cx(n*X), cy(n*Y-n/3), r(lwidth/2), fill("black"))
	) :- exit_direction(c(X,Y), up).
draw(2,
	rect(x(n*X-lwidth/2), y(n*Y), width(lwidth), height(n/3), fill("black")),
	circle(cx(n*X), cy(n*Y+n/3), r(lwidth/2), fill("black"))
	) :- exit_direction(c(X,Y), down).

% show interupted paths if they are blocked
% this draws line starts for both ends of the blocked line because blocked(p/2) is symmetric
draw(1, line(x1(n*X1), y1(n*Y1), x2(n*X1+n*(X2-X1)/3), y2(n*Y2), stroke("black"), style("stroke-width:4"))) :-
	blocked(p(c(X1,Y1), c(X2,Y2))).

% draw solution lines
draw(3, line(x1(n*X1), y1(n*Y1), x2(n*X2), y2(n*Y2), stroke("lightgray"), style("stroke-width:4"))) :-
	conn(p(c(X1,Y1), c(X2,Y2))).
draw(3, circle(cx(n*X), cy(n*Y), r(lwidth/2), fill("lightgray"))) :-
	used(c(X,Y)).

% draw solution start
draw(3, circle(cx(n*X), cy(n*Y), r(lwidth), fill("lightgray"))) :-
	used(c(X,Y)),
	start(c(X,Y)).

draw(3,
	rect(x(n*X-n/3), y(n*Y-lwidth/2), width(n/3), height(lwidth), fill("lightgray")),
	circle(cx(n*X-n/3), cy(n*Y), r(lwidth/2), fill("lightgray"))
	) :- exit_direction(c(X,Y), left), used(c(X,Y)).
draw(3,
	rect(x(n*X), y(n*Y-lwidth/2), width(n/3), height(lwidth), fill("lightgray")),
	circle(cx(n*X+n/3), cy(n*Y), r(lwidth/2), fill("lightgray"))
	) :- exit_direction(c(X,Y), right), used(c(X,Y)).
draw(3,
	rect(x(n*X-lwidth/2), y(n*Y-n/3), width(lwidth), height(n/3), fill("lightgray")),
	circle(cx(n*X), cy(n*Y-n/3), r(lwidth/2), fill("lightgray"))
	) :- exit_direction(c(X,Y), up), used(c(X,Y)).
draw(3,
	rect(x(n*X-lwidth/2), y(n*Y), width(lwidth), height(n/3), fill("lightgray")),
	circle(cx(n*X), cy(n*Y+n/3), r(lwidth/2), fill("lightgray"))
	) :- exit_direction(c(X,Y), down), used(c(X,Y)).

% draw dot on path
draw(4, circle(cx((X1+X2)*n/2), cy((Y1+Y2)*n/2), r(lwidth/2), fill("gray"))) :-
	dot(p(c(X1,Y1),c(X2,Y2))),
	path_sym(p(c(X1,Y1),c(X2,Y2))).

% draw dot on crossing
draw(4, circle(cx(X*n), cy(Y*n), r(lwidth/2), fill("gray"))) :-
	dot(c(X,Y)),
	crossing(c(X,Y)).

% draw blocks with N (1-3) triangles
draw(4, circle(cx(X*n+n/2),cy(Y*n+n/2),r(n/10), fill("rgb(240,230,0)"))) :- triangles(1,b(X,Y)).

draw(4,
	circle(cx(X*n+n/3),cy(Y*n+n/2),r(n/10), fill("rgb(240,230,0)")),
	circle(cx(X*n+n*2/3),cy(Y*n+n/2),r(n/10), fill("rgb(240,230,0)"))
	) :- triangles(2,b(X,Y)).

draw(4,
	circle(cx(X*n+n/2),cy(Y*n+n/3),r(n/10), fill("rgb(240,230,0)")),
	circle(cx(X*n+n/3),cy(Y*n+n*2/3),r(n/10), fill("rgb(240,230,0)")),
	circle(cx(X*n+n*2/3),cy(Y*n+n*2/3),r(n/10), fill("rgb(240,230,0)"))
	) :- triangles(3,b(X,Y)).

% draw colored dots in blocks
draw(4, circle(cx(X*n+n/2),cy(Y*n+n/2),r(n/8), fill(Color))) :-
	colored_block(b(X,Y), Color).

%%%%%%%%%%%%%%%%%%%%%%%
% debug visualization %
%%%%%%%%%%%%%%%%%%%%%%%

%% draw colors for "flooded" block
%draw(0, circle(cx(X*n+n/2), cy(Y*n+n/2), r(n/3), fill(Color), opacity("0.5"))) :-
%	floodfilled_color(b(X,Y), Color).


%% draw block_connection for debugging purposes
%draw(6, line(x1(X1*n+n/2), x2(X2*n+n/2), y1(Y1*n+n/2), y2(Y2*n+n/2), stroke("red"), style("stroke-width:2.0"))) :-
%	block_connection(b(X1,Y1), b(X2,Y2)).

%% example directives
%draw(2, rect(x(n*X), y(n*Y), width(1), height(1), fill("red"))).
%draw(1, circle(cx(X), cy(Y), r(20), fill("black"))).
%draw(1, line(x1(n*X1), y1(n*Y1), x2(n*X2), y2(n*Y2), stroke("black"), style("stroke-width:0.1"))).
