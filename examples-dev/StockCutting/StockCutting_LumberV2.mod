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
#minimize WasteValue: sum{b in BOARDS, bi in bIndex[b]} (bPrice[b]*w[b,bi] + 0.001*bi*u[b,bi]);

solve;

printf "Bill of Materials\n";
printf "    %5s    %-20s    %5s    %6s    %6s    %6s\n", 'Qty', 'Desc', 'Type', 'Len', 'Each', 'Total';
for {b in BOARDS : sum{bi in bIndex[b]} u[b,bi] > 0} : {
    printf "    %5d    %-20s    %5s    %6.2f    %6.2f", sum{bi in bIndex[b]} u[b,bi], b, bType[b], bLen[b], bPrice[b];
    printf "    %6.2f\n", sum{bi in bIndex[b]} bPrice[b]*u[b,bi];
}
printf "%67s%5.2f\n",'',cost;

printf "\nCutting Plan\n";
for {b in BOARDS : sum{bi in bIndex[b]} u[b,bi] > 0} : {
    printf "    Board %s; Type %s; Length %5.2f \n", b, bType[b], bLen[b];
    for {bi in bIndex[b] : u[b,bi]} : {
        printf "       %2d : Waste = %5.2f\n", bi, w[b,bi];
        for {p in PARTS, pi in pIndex[p] : pType[p] = bType[b] and y[p,pi,b,bi]} : 
            printf "%12s%-20s  %5.2f\n", "",p,pLen[p];
    }
    printf "\n";
}

printf "Production Plan\n";
for {p in PARTS} : {
    printf "    Part: %s \n", p;
    for {pi in pIndex[p], b in BOARDS, bi in bIndex[b] : pType[p] = bType[b] and y[p,pi,b,bi]} : 
        printf "%8s%2d : %s-%-2d \n", "", pi, b, bi;
    printf "\n";
}

data;

param: PARTS: pType pLen pNum :=
    'chair back'           '2x4'    30       2
    'chair back support'   '2x2'    19.5     2
    'chair_front_leg'      '2x2'    12.5     4
    'side_apron'           '1x3'    17.5     2
    'front_apron'          '1x3'    16.5     1
    'back_apron'           '1x3'    18       1
    'seat_board'           '1x4'    19       5
    'back_board'           '1x4'    15       5
;

param: BOARDS: bType bLen bNum bPrice:= 
    'Cedar  6ft 2x4'    '2x4'     72    2   6.22
    'Cedar  8ft 2x4'    '2x4'     96    2   7.81
    'Cedar  3ft 2x2'    '2x2'     36    2   2.48
    'Cedar  4ft 2x2'    '2x2'     48    2   3.28
    'Cedar  6ft 2x2'    '2x2'     72    2   4.89
    'Cedar  8ft 2x2'    '2x2'     96    2   6.20
    'Cedar  3ft 1x3'    '1x3'     36    2   1.68    
    'Cedar  4ft 1x3'    '1x3'     48    2   2.13    
    'Cedar  6ft 1x3'    '1x3'     72    2   3.20    
    'Cedar  8ft 1x3'    '1x3'     96    2   3.88    
    'Cedar 10ft 1x3'    '1x3'    120    2   5.69
    'Cedar 12ft 1x3'    '1x3'    144    2   6.31
    'Cedar  3ft 1x4'    '1x4'     36    2   4.56
    'Cedar  8ft 1x4'    '1x4'     96    2   4.56
;
 
end;
