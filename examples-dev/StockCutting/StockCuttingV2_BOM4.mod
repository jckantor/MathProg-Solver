# Stock Cutting Problem

# Products
set PRODUCTS;
param pLength{PRODUCTS};
param demand{PRODUCTS};

# Raw Materials
set RAWMATERIALS;
param rLength{RAWMATERIALS};
param avail{RAWMATERIALS};
param unitcost{RAWMATERIALS};

# Big M should be greater than the length of any stock piece
param bigM;
check {r in RAWMATERIALS} : bigM > rLength[r];

# Create indexed sets enumerating all raw material pieces
set S{r in RAWMATERIALS} := 1..avail[r];

# x[p,r,s] number of product p assigned to (raw material r, piece s)
var x{p in PRODUCTS, r in RAWMATERIALS, s in S[r]} >= 0;

# u[r,s] = 1 indicates use of (raw material r, piece s)
var u{r in RAWMATERIALS, s in S[r]} binary;

# Cut enough pieces to meet the demand for each product
s.t. A{p in PRODUCTS}: sum{r in RAWMATERIALS, s in S[r]} x[p,r,s] = demand[p];

# Do not exceed the length each piece of raw material
s.t. B{r in RAWMATERIALS, s in S[r]} : 
    sum{p in PRODUCTS} pLength[p]*x[p,r,s] <= rLength[r];
    
# Determine if a piece (r,s) of raw material is used.
s.t. C{r in RAWMATERIALS, s in S[r]} : bigM*u[r,s] >= sum{p in PRODUCTS} x[p,r,s];

minimize Pieces : sum{r in RAWMATERIALS, s in S[r]} unitcost[r]*rLength[r]*u[r,s];

solve;

# w[r,s] is the remainder left over from (raw material r, piece s)
param w{r in RAWMATERIALS, s in S[r]} := rLength[r] - sum{p in PRODUCTS} pLength[p]*x[p,r,s];

#table products {p in PRODUCTS} OUT "JSON" "Products" "Table" : 
#    p~Product, pLength[p]~Length, demand[p]~Demand;

#table rawmaterials {r in RAWMATERIALS} OUT "JSON" "Raw Materials" "Table" : 
#    r~Raw_Materials, rLength[r]~Length, avail[r]~Available;

printf "Cutting Plan\n";
for {r in RAWMATERIALS} : {
    printf "    Raw Material %s \n", r;
    for {s in S[r]} : {
        printf "        %4s-%2d: Remainder = %5.2f\n", r,s, w[r,s];
        for {p in PRODUCTS : x[p,r,s] > 0} : {
                printf "%19s (x%2d)\n", p, x[p,r,s];
        }
        printf "\n";
    }
    printf "\n";
}

data;

param bigM := 12500;

param : PRODUCTS :  pLength  demand :=
            0378        378      16
            0408        408       8
           m0878        878       8
           m1549       1549       8
            1642       1642       8
            1996       1996       8
            2153       2153       8
            2516       2516       4
            2872       2872       2
            3116       3116       4
            3226       3226       4
            4839       4839       1
            5314       5314       4
            5500       5500       8
            5919       5919       2
            6742       6742       4
            6919       6919       2
            7298       7298       8
;

param : RAWMATERIALS : rLength  avail   unitcost :=
        'RM03-09100'      9100      100    1.10
       'mRM04-09500'      9500     1320    1.00
        'RM03-09700'      9700       52    1.10
        'RM01-10000'     10000      116    1.00
        'RM01-10500'     10500      140    1.25
       'mRM04-11000'     11000     3340    1.00
        'RM02-11000'     11000      156    1.20
        'RM02-11500'     11500        8    1.20
       'mRM04-12000'     12000     1728    1.00
        'RM02-12000'     12000       42    1.20
;

end;
