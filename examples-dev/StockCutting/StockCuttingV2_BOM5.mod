# Stock Cutting Problem
# This version of the model attempts to address the its large
# scale nature.

# Number of towers to build
param N >= 1;

# PARTS
set PARTS;
param pLength{PARTS};
param demand{PARTS};

# Raw Materials
set RMATS;
param rLength{RMATS};
param inventory{RMATS};
param cost{RMATS};

# Patterns
set I := 1..10;
var z{I,PARTS,RMATS} >= 0, integer;

# Waste
var w{I,RMATS} >= 0;

# Feasible Patterns
s.t. pattern{i in I, r in RMATS} : sum{p in PARTS} pLength[p]*z[i,p,r] <= rLength[r];


data;

param N := 50;

param : PARTS :  pLength  demand :=
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

param : RMATS : rLength  inventory   cost :=
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
