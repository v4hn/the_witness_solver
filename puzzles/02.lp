% surrounding grid of crossings/corners
grid(5,5).

% start/exit position
start(c(0,4)).
exit(c(4,0)).

blocked(p(c(0,3),c(0,4))).
blocked(p(c(0,3),c(1,3))).
blocked(p(c(1,2),c(1,3))).
blocked(p(c(1,4),c(2,4))).
blocked(p(c(4,3),c(4,4))).
blocked(p(c(4,3),c(4,4))).
blocked(p(c(4,3),c(4,4))).
blocked(p(c(3,2),c(3,3))).
blocked(p(c(3,2),c(4,2))).
blocked(p(c(3,1),c(4,1))).
blocked(p(c(0,1),c(0,2))).
blocked(p(c(1,1),c(2,1))).
blocked(p(c(1,0),c(1,1))).
blocked(p(c(2,0),c(2,1))).
blocked(p(c(3,0),c(3,1))).
blocked(p(c(4,0),c(4,1))).
