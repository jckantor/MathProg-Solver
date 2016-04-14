/* # Piecewise Linear Interpolation

A common requirement is to incorporate a nonlinear constraint or objective function
into an MIP problem. Normally special ordered sets of type 2 (SOS2) are used to model
these situations, but SOS2 is not implemented in GLPK. Based on notes by Andrew 
Makhorin and Robbie Morrison, the following model demonstrates piecewise linear
interpolation in MathProg. */

param N;              # Interpolation Points
param xi{0..N};
param fi{0..N};

var z{1..N} binary;   # z[n] denotes the nth interval
var s{1..N} >= 0;

var x;
var f;

s.t. A {n in 1..N} : s[n] <= z[n];
s.t. B : 1 = sum{n in 1..N} z[n];
s.t. C : x = sum{n in 1..N} (xi[n-1]*z[n] + (xi[n]-xi[n-1])*s[n]);
s.t. D : f = sum{n in 1..N} (fi[n-1]*z[n] + (fi[n]-fi[n-1])*s[n]);

maximize Objective : f;

solve;

table tab1 {n in 0..N} OUT "JSON" "Piecewise Linear Function" "LineChart" : 
    xi[n], fi[n], f~Optimum;

data;

param N := 10;

param : xi    fi  :=
    0   0.0   0.0
    1   0.1   0.12
    2   0.2   0.22
    3   0.3   0.45
    4   0.4   0.33
    5   0.5   0.50
    6   0.6   0.62
    7   0.7   0.81
    8   0.8   0.75
    9   0.9   0.72
   10   1.0   0.50 ;

end;
