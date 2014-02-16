# Stock Cutting Problem

# Products
set PRODUCTS;
param pLength{PRODUCTS};
param demand{PRODUCTS};

# Raw Materials
set RAWMATERIALS;
param rLength{RAWMATERIALS};
param avail{RAWMATERIALS};

# Big M should be greater than the length of any stock piece
param bigM;
check {r in RAWMATERIALS} : bigM > rLength[r];

# Create indexed sets enumerating all production pieces
set Q{p in PRODUCTS} := 1..demand[p] ;

# Create indexed sets enumerating all raw material pieces
set S{r in RAWMATERIALS} := 1..avail[r];

# y[p,q,r,s] = 1 assigns (product p, piece q) to (raw material r, piece s)
var y{p in PRODUCTS, q in Q[p], r in RAWMATERIALS, s in S[r]} binary;

# u[r,s] = 1 indicates use of (raw material r, piece s)
var u{r in RAWMATERIALS, s in S[r]} binary;

# w[r,s] is the remainder left over from (raw material r, piece s)
var w{r in RAWMATERIALS, s in S[r]} >= 0;

# Assign product (p,q) only once to the set of all raw materials (r,s)
s.t. A{p in PRODUCTS, q in Q[p]} : sum{r in RAWMATERIALS, s in S[r]} y[p,q,r,s] = 1;

# Cut enough pieces to exactly meet the demand for each product
s.t. B{p in PRODUCTS} : sum{q in Q[p], r in RAWMATERIALS, s in S[r]} y[p,q,r,s] = demand[p];

# Do not exceed the length each piece of raw material
s.t. C{r in RAWMATERIALS, s in S[r]} : 
    sum{p in PRODUCTS, q in Q[p]} pLength[p]*y[p,q,r,s] + w[r,s] = rLength[r];
    
# Determine if a piece (r,s) of raw material is used.
s.t. D{r in RAWMATERIALS, s in S[r]} : bigM*u[r,s] >= sum{p in PRODUCTS, q in Q[p]} y[p,q,r,s];

# minimize Pieces : sum{r in RAWMATERIALS, s in S[r]} rLength[r]*s*u[r,s];

solve;

table products {p in PRODUCTS} OUT "JSON" "Products" "Table" : 
    p~Product, pLength[p]~Length, demand[p]~Demand;

table rawmaterials {r in RAWMATERIALS} OUT "JSON" "Raw Materials" "Table" : 
    r~Raw_Materials, rLength[r]~Length, avail[r]~Available;

printf "Cutting Plan\n";
for {r in RAWMATERIALS} : {
    printf "    Raw Material %s \n", r;
    for {s in S[r]} : {
        printf "        Piece %4s-%2d : Remainder = %5.1f : Product pieces ", r,s, w[r,s];
        for {p in PRODUCTS} : {
            for {q in Q[p] : y[p,q,r,s]} : {
                printf "%4s-%2d ", p, q;
            }
        }
        printf "\n";
    }
    printf "\n";
}

printf "Production Plan\n";
for {p in PRODUCTS} : {
    printf "    Product %s \n", p;
    for {q in Q[p]} : {
        printf "        Piece %4s-%2d : Cut from piece ", p, q;
        for {r in RAWMATERIALS} : {
            for {s in S[r] : y[p,q,r,s]} : {
                printf "%4s-%2d ", r, s;
            }
        }
        printf "\n";
    }
    printf "\n";
}

data;

param bigM := 300;

param : PRODUCTS : pLength demand :=
    '110m'   110   1
    '107m'   107   6
    '105m'   105   4
    '103m'   103   3
    '100m'   100   2
    '96m'     96   4
    '94m'     94   1
    '91m'     91   3
    '86m'     86   3
    '78m'     78   2
    '76m'     76   2
    '69m'     69   5;
 
param : RAWMATERIALS : rLength avail :=
    '280m'  280   13 ;
   
end;
