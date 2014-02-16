param N := 20;

set K := 1..N;
var C{K} binary;
var D{K} >= 15000, <= 35000;

s.t. a: D[1] = 16000;
s.t. b{k in (K diff {N})} : 1810*C[k] + D[k] - D[k+1] = 500 + Uniform(0,300);

minimize min: sum{k in K} (36.6525001526*C[k] + k*C[k]);
solve;
table tout {k in K} OUT "GCHART" "Results" "LineChart" : k, D[k]-15000;
table tout {k in K} OUT "GCHART" "Results" "ColumnChart" : k, C[k];
end;
