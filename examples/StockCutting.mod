/* # Stock Cutting

The stock cutting problem is to minimize the waste associated with cutting up stock
materials to produce a set of products. Examples of the one dimensional problem include
cutting lengths of steel bar into a set of products, cutting wide paper rolls into
smaller ones, and cutting dimensioned lumber to meet the production needs of furniture
shops.

In large scale applications the stock cutting problem begins with a base set of cutting
patterns. Each cutting pattern breaks a piece of stock into a set of products. The base
calculation is to find a mix of cutting patterns to meet product requirements. A
secondary problem is solved to find additional cutting patterns with the potential to
reduce costs. The solution then proceeds iteratively with new patterns are generated 'on
the fly' coupled with a branch and bound search to find an optimal solution. This
approach is called 'column generation.'

As demonstrated below, for small scale problems the stock cutting problem can be 
formulated as an assignment of product pieces to stock pieces. For this example the data 
consists of a list of product types, lengths and demand. The example incorporates 
multiple types of raw materials. The objective is to maximize the number of pieces of 
stock material that are left uncut.

An aspect of this problem is the high degree of solution symmetry. The number of 
equivalent solutions is a combinatorial function of the number of identical pieces of raw 
of materials. In these cases a solver may quickly find a solution but then need to search 
many equivalent solutions to verify optimality. This example uses a weighted objective to 
separate otherwise equivalent solutions.

To repeat, this approach will not work for larger problems due to the excessive number of 
binary variables required and high degree of solution symmetry. Consult the <a 
href="https://code.google.com/p/cspsol/">cspsol project</a> for a solution method using 
column generation and glpk api.
*/

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

minimize Pieces : sum{r in RAWMATERIALS, s in S[r]} rLength[r]*s*u[r,s];

solve;

table products {p in PRODUCTS} OUT "JSON" "Products" "Table" : 
    p~Product, pLength[p]~Length, demand[p]~Demand;

table rawmaterials {r in RAWMATERIALS} OUT "JSON" "Raw Materials" "Table" : 
    r~Raw_Materials, rLength[r]~Length, avail[r]~Available;

printf "Cutting Plan\n";
for {r in RAWMATERIALS} : {
    printf "    Raw Material %s \n", r;
    for {s in S[r]} : {
        printf "        Piece %s-%d : Remainder = %5.2f : Cut product pieces ", r,s, w[r,s];
        for {p in PRODUCTS} : {
            for {q in Q[p] : y[p,q,r,s]} : {
                printf "%s-%d ", p, q;
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
        printf "        Piece %s-%d : Cut from stock piece ", p, q;
        for {r in RAWMATERIALS} : {
            for {s in S[r] : y[p,q,r,s]} : {
                printf "%s-%d ", r, s;
            }
        }
        printf "\n";
    }
    printf "\n";
}

data;

param bigM := 20;

param: PRODUCTS: pLength demand :=
        '7m'        7        3
        '6m'        6        2
        '4m'        4        6
        '3m'        3        1 ;
  
param: RAWMATERIALS: rLength avail := 
       '15m'       15        3
       '10m'       10        3 ;
  
end;
