%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% example with multiple constraints %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% surrounding grid of crossings/corners
grid(5,5).

% start/exit position
start(c(0,0)).
start(c(4,4)).
exit(c(4,1)).
exit(c(1,4)).

blocked(c(3,3)).
blocked(p(c(1,1),c(2,1))).
dot(p(c(0,2), c(0,3))).
dot(c(1,1)).

triangles(3,b(0,2)).

colored_block(b(0,1), "green").
colored_block(b(0,0), "orange").

pattern(b(2,0), 0).
shape(0, o(0,0)).
shape(0, o(0,1)).
shape(0, o(1,0)).

