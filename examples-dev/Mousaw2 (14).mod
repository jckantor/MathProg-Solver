# product batches to produce
set BATCHES;

# equipment capabilities as (unit,operation) pairs
set EQUIPMENT dimen 2;
param dur{EQUIPMENT};

# units and operations are extracted from EQUIPMENT set
set UNITS := setof{(unit,operation) in EQUIPMENT} unit;
set OPERATIONS := setof{(unit,operation) in EQUIPMENT} operation;

# the recipe is a set of steps and operations
set RECIPE dimen 2;
set STEPS := setof{(step,operation) in RECIPE} step;

var makespan >= 0;
var start{BATCHES,STEPS} >= 0;
var a{BATCHES,STEPS,UNITS} binary;

var stepdur{BATCHES,STEPS} >= 0;

minimize OBJ: makespan;

# Definition of makespan
A{batch in BATCHES, step in STEPS}: 
    start[batch,step] + stepdur[batch,step] <= makespan;
    
# Bound the duration of each step
B{b in BATCHES, s1 in STEPS, (unit,op1) in EQUIPMENT, (s2,op2) in RECIPE : s1=s2 and op1=op2}: stepdur[b,s1] >= dur[unit,op1] - 1000*(1-a[b,s1,unit]);

# Assign one unit to each batch step
C{b in BATCHES, s in STEPS}: sum{u in UNITS} a[b,s,u] = 1;

# Assign units capable of the needed operations
D{b in BATCHES, s1 in STEPS, (s2, op1) in RECIPE : s1=s2}:
    sum{(u,op2) in EQUIPMENT : op1=op2} a[b,s1,u] = 1;
    
# Sequence batch steps
E{b in BATCHES, k in 1..(card(STEPS)-1)} :
    start[b,k+1] >= start[b,k] + stepdur[b,k];

# Unit commitment
F{u in UNITS, b1 in BATCHES, s1 in STEPS, b2 in BATCHES, s2 in STEPS : b1<b2}:
    start[b1,s1] + stepdur[b1,s1] <= start[b2,s2] + 1000*(2 - a[b1,s1,u] - a[b2,s2,u]);

solve;

printf "UNITS\n";
printf {unit in UNITS}: "%s\n", unit;

printf "\nOPERATIONS\n";
printf {operation in OPERATIONS}: "%s\n", operation;

for {batch in BATCHES} : {
	printf "\nBatch %d\n", batch;
    for {step in STEPS} : {
        for {unit in UNITS, (s2,op) in RECIPE : a[batch,step,unit]=1 and step=s2} : {
            printf "    Step %d: ",step;
            printf "%-15s ",op;
            printf " Unit: %-8s", unit;
            printf "   Start: %5.1f ", start[batch,step];
            printf "     Finish: %5.1f", start[batch,step] + stepdur[batch,step];
        }
        printf "\n";
    }
}

for {unit in UNITS} : {
    printf "\nUnit %s\n", unit;
    for {b in BATCHES, s1 in STEPS, (s2,op) in RECIPE : a[b,s1,unit]=1 and s1=s2} : {
        printf "    Batch: %2d", b;
        printf "   Step %2d:", s1;
        printf " %-15s", op;
        printf "   Start: %5.1f ", start[b,s1];
        printf "     Finish: %5.1f", start[b,s1] + stepdur[b,s1];      
        printf "\n";
    }
}

data;

# set of batches to produce
set BATCHES := 1 2 3 4;

# dur{unit,operation} pairs 
param : EQUIPMENT : dur :=
    Rctr1   Reaction        48
    Rctr1   Crystalization  12
    Rctr2   Reaction        48
    Rctr2   Crystalization  12
    Dstl1   Distillation    12
    Fltr1   Isolation       12 ;
    
set RECIPE := 
    1   Reaction
    2   Distillation
    3   Crystalization
    4   Isolation ;
    
end;
    