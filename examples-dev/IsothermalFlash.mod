# Isothermal Flash
set SPECIES;

param z{SPECIES} >= 0;
param K{SPECIES} >= 0;

var x{SPECIES} >= 0;
var y{SPECIES} >= 0;

var phi >= 0, <= 1;

s.t. Liq : sum{s in SPECIES} x[s] = 1;
s.t. Vap : sum{s in SPECIES} y[s] = 1;
s.t. Eq {s in SPECIES} : y[s] = K[s]*x[s];

solve;

table tab1 {s in SPECIES} OUT "JSON" "Table" : s, K[s], z[s], x[s], y[s];

data;

param : SPECIES :  z    K :=
    pentane        0.50   1.685
    hexane         0.30   0.742
    cyclohexane    0.20   0.532 ;
    
end;