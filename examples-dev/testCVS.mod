
/* CSV */

set ROWS;

param A{ROWS};
param B{ROWS};
param C{ROWS};
param D{ROWS};
param E{ROWS};

var x;
c: x = A[1];

solve;

printf A[1];

data;

set ROWS := 1 2 3 4;

param:   A      B     C      D      E :=
1     23.4   12.3  24.5   15.5   34.4
2     12.3   34.2  84.4   12.3   34.1
3      6.3  -23.2  24.3   45.4   28.3
4     12.3   19.3   8.4    9.3    3.4 ;

end;