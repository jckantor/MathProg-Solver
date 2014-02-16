/* Giapetto goes to town. */

set PRODUCTS := {"Soldiers","Trains","Nutcrackers","Flags","Scrap"};
set MONTHS := 1..12;
set RESOURCES := {"Finishing","Carpentry","WoodA","WoodB"};

param demand{MONTHS,PRODUCTS};
param recipe{RESOURCES,PRODUCTS};
param prices{PRODUCTS};
param costs{RESOURCES};

var x{MONTHS,PRODUCTS} >= 0;
var revenue >= 0;
var cost >= 0;

s.t. Demand {m in MONTHS, p in PRODUCTS}: x[m,p] <= demand[m,p];
s.t. Cost: cost = sum{r in RESOURCES, m in MONTHS, p in PRODUCTS} cost[
s.t. Revenue: revenue = sum{m in MONTHS, p in PRODUCTS} prices[p]*x[m,p];

maximize profit: revenue - cost;

solve;

data;

param prices 
    Soldiers     27
    Trains       21
    Nutcrackers  50
    Flags        10
    Scrap         2 ;

param costs
    Finishing     4
    Carpentry     6
    WoodA         1
    WoodB         0.5;
    
param demand default 0:
      Soldiers   Trains   Nutcrackers   Flags    Scrap :=
   1        40     1000             .        .    1000 
   2        40     1000             .        .    1000
   3        40     1000             .        .    1000
   4        40     1000             .        .    1000
   5        40     1000             .        .    1000
   6        40     1000             .      100    1000
   7        40     1000             .      100    1000
   8        40     1000             .        .    1000
   9        40     1000             .        .    1000
  10        40     1000             .        .    1000
  11       100     1000             .        .    1000
  12       100     1000             .        .    1000 ;

end;