# SEMD Problem 19.5

set CRUDES;
set PRODUCTS;

param profit{CRUDES};
param capacity{PRODUCTS};
param yields{PRODUCTS,CRUDES};

var feeds{CRUDES} >= 0;
var prods{PRODUCTS} >= 0;

maximize Profits : sum{c in CRUDES} profit[c]*feeds[c];

s.t. cap{p in PRODUCTS} : sum{c in CRUDES} yields[p,c]*feeds[c] <= capacity[p];

data;

param : PRODUCTS : capacity :=
    'Gasoline'       6000
    'Kerosine'       2400
    'Fuel Oil'      12000 ;

param : CRUDES : profit :=
    'Crude No. 1'    2.00
    'Crude No. 2'    1.40 ;

param  yields : 'Crude No. 1' 'Crude No. 2' :=
    'Gasoline'       0.70             0.31
    'Kerosine'       0.06             0.09
    'Fuel Oil'       0.24             0.60 ;

end;
