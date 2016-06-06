/* # Lumber Cutting

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

# parts to be produced
set PARTS;
param pLen{PARTS};
param pNum{PARTS};

# boards available
set BOARDS;
param bLen{BOARDS};
param bNum{BOARDS};
param bPrice{BOARDS};

# create indexed sets enumerating all parts and boards
set pIndex{p in PARTS} := 1..pNum[p] ;
set bIndex{b in BOARDS} := 1..bNum[b];

# y[p,pi,b,bi] = 1 assigns (product p, piece pi) to (board b, piece bi)
var y{p in PARTS, pi in pIndex[p], b in BOARDS, bi in bIndex[b]} binary;

# u[b,bi] = 1 indicates use of (board b, piece bi)
var u{b in BOARDS, bi in bIndex[b]} binary;

# w[b,bi] is the remainder left over from (board b, piece bi)
var w{b in BOARDS, bi in bIndex[b]} >= 0;

# assign product (p,pi) to one and only one boards (b,bi)
A{p in PARTS, pi in pIndex[p]} : sum{b in BOARDS, bi in bIndex[b]} y[p,pi,b,bi] = 1;

# cut enough parts to exactly meet the demand for each part
B{p in PARTS} : sum{pi in pIndex[p], b in BOARDS, bi in bIndex[b]} y[p,pi,b,bi] = pNum[p];

# do not exceed the length each board
C{b in BOARDS, bi in bIndex[b]} : 
    sum{p in PARTS, pi in pIndex[p]} pLen[p]*y[p,pi,b,bi] + w[b,bi] = bLen[b]*u[b,bi];
    
#minimize Pieces : sum{b in BOARDS, bi in bIndex[b]} bLen[b]*bi*u[b,bi];
#minimize Cost : sum{b in BOARDS, bi in bIndex[b]} bPrice[b]*u[b,bi];
minimize WasteValue: sum{b in BOARDS, bi in bIndex[b]} (bPrice[b]*w[b,bi] + 0.01*bi*u[b,bi]);

solve;

printf "Cutting Plan\n";
for {b in BOARDS} : {
    printf "    Board Type: %s, length = %5.2f \n", b, bLen[b];
    for {bi in bIndex[b] : u[b,bi]} : {
        printf "       %2d : Waste = %5.2f\n", bi, w[b,bi];
        for {p in PARTS, pi in pIndex[p] : y[p,pi,b,bi]} : 
            printf "%12s%-10s  %5.2f\n", "",p,pLen[p];
    }
    printf "\n";
}

printf "Production Plan\n";
for {p in PARTS} : {
    printf "    Part: %s \n", p;
    for {pi in pIndex[p], b in BOARDS, bi in bIndex[b] : y[p,pi,b,bi]} : 
        printf "%8s%2d : %s-%-2d \n", "", pi, b, bi;
    printf "\n";
}

data;

param: PARTS:         pLen      pNum :=
       'Long_Rail'    53        2
       'Short_Rail'   53        2
       'Post'         12.5      4
       'Leg'          23        4
       'EndRail'       7        4
;

param: BOARDS:        bLen      bNum   bPrice:= 
       '8ft 2x4'      96        5       8.57
;
 
end;
