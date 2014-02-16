param nBINS;
param nITEMS;

set BINS := 1..nBINS;
set ITEMS := 1..nITEMS;

param weight{ITEMS};

var wmax >= 0;
var wmin >= 0;
var x{i in ITEMS, b in BINS} binary;
var Imin{b in BINS};

s.t. A{i in ITEMS}: sum{b in BINS} x[i,b] = 1;
s.t. B{b in BINS}: sum{i in ITEMS} weight[i]*x[i,b] <= wmax;
s.t. C{b in BINS}: sum{i in ITEMS} weight[i]*x[i,b] >= wmin;
s.t. D{b in BINS, i in ITEMS}: Imin[b] <= i*x[i,b] + nITEMS*(1-x[i,b]);
s.t. E{i in ITEMS, b in BINS: b < nBINS}: i*x[i,b] <= Imin[b+1];

minimize obj: wmax-wmin;

solve;

for {b in BINS}: {
    printf "Bin %d: total weight %d\n", b, sum{i in ITEMS} weight[i]*x[i,b];
    printf {i in ITEMS : x[i,b] = 1}: "     item %d (%d)\n", i, weight[i];
    printf "\n";
}

data;

param nBINS := 3;
param nITEMS := 8;

param weight :=
    1    40
    2    60
    3    30
    4    70
    5    50
    6    40
    7    15
    8    25 ;
    
end;