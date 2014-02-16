
set PRODUCTS;
set RESOURCES;

param price{PRODUCTS};
param demand{PRODUCTS};
param resources{RESOURCES};
param unitcosts{RESOURCES};
param recipe{RESOURCES,PRODUCTS};

var x{PRODUCTS} >=0 integer;
var cost;
var revenue;

s.t. Revenue: revenue = sum{p in PRODUCTS} x[p]*price[p];
s.t. Cost: cost = sum{p in PRODUCTS, r in RESOURCES} x[p]*recipe[r,p]*unitcosts[r];
s.t. Resources{r in RESOURCES}: sum{p in PRODUCTS} x[p]*recipe[r,p] <= resources[r];
s.t. Demand{p in PRODUCTS}: x[p] <= demand[p];

maximize profit: revenue - cost;

solve;

data;

param : PRODUCTS : price := 
    Soldier           27
    Train             21 ;

param demand :=
    Soldier           40
    Train           1000 ;
    
param : RESOURCES : resources :=
    Finishing        100
    Carpentry         80
    Wood            1000 ;
    
param unitcosts :=
    Finishing          4
    Carpentry          6
    Wood               1 ;
     
param recipe :   Soldier  Train :=
    Finishing          2      1
    Carpentry          1      1
    Wood              10      9 ;
    
end;