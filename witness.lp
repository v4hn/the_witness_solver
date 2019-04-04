%%%%%%%%%%%
% example %
%%%%%%%%%%%

% surrounding grid of crossings/corners
grid(4,4).

% start/exit position
start(c(0,0)).
exit(c(2,0)).

blocked(c(3,3)).
blocked(p(c(2,2),c(3,2))).
dot(p(c(0,2), c(0,3))).
dot(c(1,1)).

triangles(3,b(0,2)).

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
% paths are lines on the map
path(P) :-
	line(P);
	not blocked(P).
path_sym(P) :- path(P).
path_sym(p(B,A)) :- path_sym(p(A,B)).

pathes_around_block(b(X,Y), p(c(X,Y), c(X+1,Y))) :- crossing(c(X,Y)).
pathes_around_block(b(X,Y), p(c(X,Y), c(X,Y+1))) :- crossing(c(X,Y)).
pathes_around_block(b(X,Y), p(c(X+1,Y), c(X+1,Y+1))) :- crossing(c(X,Y)).
pathes_around_block(b(X,Y), p(c(X,Y+1), c(X+1,Y+1))) :- crossing(c(X,Y)).

block(B) :-
	4 { pathes_around_block(B,P) : pathes_around_block(B,P) },
	crossing(c(XB,YB)),
	B = b(XB,YB).

% connection might be made by drawing the line on a path
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

N { conn(P) : pathes_around_block(B,P) } N :-
	triangles(N, B),
	block(B).

%%%%%%%%%%%%%%%%%
% visualization %
%%%%%%%%%%%%%%%%%

% rounded off grid
draw(1, circle(cx(10*X), cy(10*Y), r(1), fill("black"))) :-
	crossing(c(X,Y)).
draw(1, line(x1(10*X1), y1(10*Y1), x2(10*X2), y2(10*Y2), stroke("black"), style("stroke-width:2"))) :-
	path(p(c(X1,Y1), c(X2,Y2))).

% big circle around start
draw(2, circle(cx(10*X), cy(10*Y), r(2), fill("black"))) :-
	start(c(X,Y)).
% draw exit
% TODO: change side_exit into exit_direction(n/e/s/w, c(x,y))
side_exit :- exit(c(X,Y)), not path_sym(p(c(X,Y),c(X+1,Y))).
side_exit :- exit(c(X,Y)), not path_sym(p(c(X,Y),c(X-1,Y))).
draw(2, rect(x(10*X-3), y(10*Y-1), width(6), height(2), fill("black"))) :-
	exit(c(X,Y)), side_exit.
draw(2, rect(x(10*X-1), y(10*Y-3), width(2), height(6), fill("black"))) :-
	exit(c(X,Y)), not side_exit.

% draw solution lines
draw(3, line(x1(10*X1), y1(10*Y1), x2(10*X2), y2(10*Y2), stroke("lightgray"), style("stroke-width:2"))) :-
	conn(p(c(X1,Y1), c(X2,Y2))).
draw(3, circle(cx(10*X), cy(10*Y), r(1), fill("lightgray"))) :-
	used(c(X,Y)).

% draw solution start
draw(3, circle(cx(10*X), cy(10*Y), r(2), fill("lightgray"))) :-
	used(c(X,Y)),
	start(c(X,Y)).

%TODO: draw solution end

draw(4, circle(cx((X1+X2)*10/2), cy((Y1+Y2)*10/2), r(1), fill("gray"))) :-
	dot(p(c(X1,Y1),c(X2,Y2))),
	crossing(c(X1,Y1)),
	crossing(c(X2,Y2)).

draw(4, circle(cx(X*10), cy(Y*10), r(1), fill("gray"))) :-
	dot(c(X,Y)),
	crossing(c(X,Y)).

draw(4, circle(cx(X*10+5),cy(Y*10+5),r(1), fill("rgb(240,230,0)"))) :- triangles(1,b(X,Y)).

draw(4, circle(cx(X*10+3),cy(Y*10+5),r(1), fill("rgb(240,230,0)"))) :- triangles(2,b(X,Y)).
draw(4, circle(cx(X*10+7),cy(Y*10+5),r(1), fill("rgb(240,230,0)"))) :- triangles(2,b(X,Y)).

draw(4, circle(cx(X*10+5),cy(Y*10+3),r(1), fill("rgb(240,230,0)"))) :- triangles(3,b(X,Y)).
draw(4, circle(cx(X*10+3),cy(Y*10+6),r(1), fill("rgb(240,230,0)"))) :- triangles(3,b(X,Y)).
draw(4, circle(cx(X*10+7),cy(Y*10+6),r(1), fill("rgb(240,230,0)"))) :- triangles(3,b(X,Y)).

%% example directives
%draw(2, rect(x(10*X), y(10*Y), width(1), height(1), fill("red"))).
%draw(1, circle(cx(X), cy(Y), r(20), fill("black"))).
%draw(1, line(x1(10*X1), y1(10*Y1), x2(10*X2), y2(10*Y2), stroke("black"), style("stroke-width:0.1"))).
