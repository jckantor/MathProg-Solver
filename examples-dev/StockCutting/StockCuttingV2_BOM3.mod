# Stock Cutting Problem

# Products
set PRODUCTS;
param pLength{PRODUCTS};
param demand{PRODUCTS};

# Raw Materials
set RAWMATERIALS;
param rLength{RAWMATERIALS};
param avail{RAWMATERIALS};
param cost{RAWMATERIALS};

# Big M should be greater than the length of any stock piece
param bigM;
check {r in RAWMATERIALS} : bigM > rLength[r];

# Create indexed sets enumerating all raw material pieces
set S{r in RAWMATERIALS} := 1..avail[r];

# x[p,r,s] number of product p assigned to (raw material r, piece s)
var x{p in PRODUCTS, r in RAWMATERIALS, s in S[r]} >= 0, integer;

# u[r,s] = 1 indicates use of (raw material r, piece s)
var u{r in RAWMATERIALS, s in S[r]} binary;

# Cut enough pieces to meet the demand for each product
s.t. A{p in PRODUCTS}: sum{r in RAWMATERIALS, s in S[r]} x[p,r,s] = demand[p];

# Do not exceed the length each piece of raw material
s.t. B{r in RAWMATERIALS, s in S[r]} : 
    sum{p in PRODUCTS} pLength[p]*x[p,r,s] <= rLength[r];
    
# Determine if a piece (r,s) of raw material is used.
s.t. C{r in RAWMATERIALS, s in S[r]} : bigM*u[r,s] >= sum{p in PRODUCTS} x[p,r,s];

minimize Pieces : sum{r in RAWMATERIALS, s in S[r]} (cost[r]*u[r,s] + s*u[r,s]);

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

param bigM := 30000;

param : PRODUCTS : pLength demand :=
0378-A	378	8
0378-B	378	8
0408-A	408	8
0873-A	873	1
0874-A	874	1
0877-A	877	1
0877-B	877	1
0878-A	878	1
0878-B	878	3
1548-A	1548	5
1548-B	1548	1
1549-A	1549	2
1642-A	1642	4
1642-B	1642	4
2153-A	2153	4
2153-B	2153	4
3116-A	3116	2
3116-B	3116	2
3226-A	3226	2
3226-B	3226	2
4839-A	4839	1
5500-A	5500	4
5500-B	5500	4
7298-A	7298	4
7298-B	7298	4 ;
 
param : RAWMATERIALS : rLength avail cost :=
    '280m'  28000      7    280
    '100m'  10000      4    80 ;

end;
