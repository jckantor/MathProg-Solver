# Example 19.3

set PRODUCTS;
set CRUDES;

var f{CRUDES} >= 0;
var x{PRODUCTS} >= 0;

param capacity{PRODUCTS};
param yield{PRODUCTS,CRUDES};
param productPrice{PRODUCTS};
param crudePrice{CRUDES};
param processingCost{CRUDES};

var income;
var rawmaterial;
var processing;

maximize profit: income - rawmaterial - processing;

A: income = sum {p in PRODUCTS} productPrice[p]*x[p];
B: rawmaterial = sum {c in CRUDES} crudePrice[c]*f[c];
C: processing = sum {c in CRUDES} processingCost[c]*f[c];
D {p in PRODUCTS}: x[p] = sum{c in CRUDES} yield[p,c]*f[c];
E {p in PRODUCTS}: x[p] <= capacity[p];

solve;

table production {p in PRODUCTS} OUT "JSON" "Table" :
    p~Product,
    x[p]~BPD;



data;

param : PRODUCTS : productPrice       capacity :=
      'Gasoline'             36             24000
      'Kerosine'             24              2000
      'Fuel Oil'             21              6000
      'Residual'             10              10000 ;
   
param : CRUDES :     crudePrice  processingCost :=
      'Crude #1'             24            0.50
      'Crude #2'             15            1.00 ;

param yield :     'Crude #1'      'Crude #2' :=
      'Gasoline'          0.80            0.44
      'Kerosine'          0.05            0.10
      'Fuel Oil'          0.10            0.36
      'Residual'          0.05            0.10 ;

end;