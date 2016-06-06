/* # LumberCut

This example shows how produce a list of parts from a collection of boards. The
parts and boards are assumed to have the same cross section (e.g., all boards and parts
are made from 2 x 4 inch dimensioned lumber). The input data consists of the number and
length of the parts required, and the number and lengths of the boards available.

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

# boards available
set BOARDS;
param bType{BOARDS} symbolic;
param bLen{BOARDS};
param bNum{BOARDS};
param bPrice{BOARDS};

# parts to be produced
set PARTS;
param pType{PARTS} symbolic;
param pLen{PARTS};
param pNum{PARTS};

# create set of all board types
set TYPES := setof{b in BOARDS} bType[b];

# check that part types are within the set of board types
check {p in PARTS} : pType[p] in TYPES;

# create indexed sets enumerating all parts and boards
set pIndex{p in PARTS} := 1..pNum[p] ;
set bIndex{b in BOARDS} := 1..bNum[b];

# y[p,pi,b,bi] = 1 assigns (product p, piece pi) to (board b, piece bi)
var y{p in PARTS, pi in pIndex[p], b in BOARDS, bi in bIndex[b] : pType[p] = bType[b]} binary;

# u[b,bi] = 1 indicates use of (board b, piece bi)
var u{b in BOARDS, bi in bIndex[b]} binary;

# w[b,bi] is the remainder left over from (board b, piece bi)
var w{b in BOARDS, bi in bIndex[b]} >= 0;

# cost
var cost >= 0;
CostDef : cost = sum {b in BOARDS, bi in bIndex[b]} bPrice[b]*u[b,bi];

# assign product (p,pi) to one and only one boards (b,bi)
A{p in PARTS, pi in pIndex[p]} : sum{b in BOARDS, bi in bIndex[b] : pType[p] = bType[b]} y[p,pi,b,bi] = 1;

# cut enough parts to exactly meet the demand for each part
B{p in PARTS} : sum{pi in pIndex[p], b in BOARDS, bi in bIndex[b] : pType[p] = bType[b]} y[p,pi,b,bi] = pNum[p];

# do not exceed the length each board
C{b in BOARDS, bi in bIndex[b]} : 
    sum{p in PARTS, pi in pIndex[p] : pType[p] = bType[b]} pLen[p]*y[p,pi,b,bi] + w[b,bi] = bLen[b]*u[b,bi];
    
#minimize Pieces : sum{b in BOARDS, bi in bIndex[b]} bLen[b]*bi*u[b,bi];
minimize Cost : sum{b in BOARDS, bi in bIndex[b]} bPrice[b]*u[b,bi];
#minimize WasteValue: sum{b in BOARDS, bi in bIndex[b]} (bPrice[b]*w[b,bi] + 0.1*bi*u[b,bi]);
#minimize Cost : sum{b in BOARDS, bi in bIndex[b]} (bPrice[b]*u[b,bi] + 0.1*bi*u[b,bi]);

solve;

printf "\n\nBILL OF MATERIALS = $%.2f\n\n", cost;
printf "    %5s    %-20s    %5s    %6s    %6s    %6s\n", 'Qty', 'Desc', 'Type', 'Len', 'Each', 'Total';
for {b in BOARDS : sum{bi in bIndex[b]} u[b,bi] > 0} : {
    printf "    %5d    %-20s    %5s    %6.2f    %6.2f", sum{bi in bIndex[b]} u[b,bi], b, bType[b], bLen[b], bPrice[b];
    printf "    %6.2f\n", sum{bi in bIndex[b]} bPrice[b]*u[b,bi];
}

printf "\nCUTTING PLAN\n\n";
for {b in BOARDS : sum{bi in bIndex[b]} u[b,bi] > 0} : {
    printf "    %s; Type %s; Length %5.2f \n", b, bType[b], bLen[b];
    for {bi in bIndex[b] : u[b,bi]} : {
        printf "\n       %2d : Waste = %5.2f\n", bi, w[b,bi];
        for {p in PARTS, pi in pIndex[p] : pType[p] = bType[b] and y[p,pi,b,bi]} : 
            printf "%12s%-20s  %5.2f\n", "",p,pLen[p];
    }
    printf "\n";
}

printf "\nPRODUCTION PLAN\n\n";
for {p in PARTS} : {
    printf "    Part: %s \n", p;
    for {pi in pIndex[p], b in BOARDS, bi in bIndex[b] : pType[p] = bType[b] and y[p,pi,b,bi]} : 
        printf "%8s%2d : %s-%-2d \n", "", pi, b, bi;
    printf "\n";
}

data;

param: PARTS: pType pLen pNum :=
    'side rail'           '2x4'    83      4
	'end rail'            '2x4'     7      4
	'leg'                 '2x4'    23      4
	'post'                '2x4'    12.5    4
;

param: BOARDS: bType bLen bNum bPrice:= 
    'Cedar  6ft 2x4'    '2x4'     72    4   6.22
    'Cedar  8ft 2x4'    '2x4'     96    6   7.81
    'Cedar  8ft 2x4 - garage'    '2x4'     96    0   0.00
;
 
end;
