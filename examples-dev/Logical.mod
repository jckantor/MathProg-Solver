var X, integer, >= 1, <= 60;
var Z, integer, >= 1, <= 60;
var W, integer, >= 1, <= 10;
var K, integer, >= 1, <= 10;

var y, binary;

param M := 100;
param eps := 0.01;

# A <=> (X>Z)
var A, binary;    
s.t. A1: X - Z >= eps - M*(1-A);
s.t. A2: X - Z <= M*A;

# B <=> (Z>X)
var B, binary; 
s.t. B1: Z - X >= eps - M*(1-B);
s.t. B2: Z - X <= M*B;

# C <=> (W>K)
var C, binary;  
s.t. C1: W - K >= eps - M*(1-C);
s.t. C2: W - K <= M*C;

# D <=> (K>W)
var D, binary;
s.t. D1: K - W >= eps - M*(1-D);
s.t. D2: K - W <= M*D;

# y => not(A) and not(B) and not(C) and (not(D))
s.t. a: A + y <= 1;
s.t. b: B + y <= 1;
s.t. c: C + y <= 1;
s.t. d: D + y <= 1;

# not(y) => A or B or C or D
s.t. e: A + B + C + D + y >= 1;

maximize obj: X + Z + W + K;
solve;
end;
