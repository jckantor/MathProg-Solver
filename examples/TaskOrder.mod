/* Linear Ordering of Tasks

Example: TaskOrder.mod

Jeff Kantor
January 20, 2009 */

/* Problem data  */
param M;                                       # Number of Tasks
param saving{1..M,1..M};                       # Problem data

/* Define Sets */
set TASKS := 1..M;                             # Set of Tasks
set PAIRS := {a in TASKS, b in TASKS: a < b};  # Nonredundant Task Pairs

/* Decision Variables */
var before{(a,b) in PAIRS} binary;             # before[a,b] implies a is before b

/* Objective is to order variables to maximize time savings */
maximize savings: sum{(a,b) in PAIRS} 
    (saving[a,b]*before[a,b] + saving[b,a]*(1-before[a,b]));

/* Any ordering of tasks must be acyclic. The following constraints remove
3-cycles from the search space. See Grotschel, et al. (1984), equations 10-12. This
is sufficient to remove all cycles from the search space.*/

s.t. c1{a in TASKS, b in TASKS, c in TASKS: a < b and a < c and c < b}:
  before[a,b] - before[c,b] - before[a,c] <= 0;
s.t. c2{a in TASKS, b in TASKS, c in TASKS: a < b and a < c and b < c}:
  before[a,b] + before[b,c] - before[a,c] <= 1;

solve;

/* Postprocessing */

/* Compute position of each task in queue */
param position{a in TASKS} := M - sum{b in TASKS: a <> b} 
    if a < b then before[a,b] else (1-before[b,a]);

/* Compute realized savings */
param rs := sum{(a,b) in PAIRS} 
    (saving[a,b]*before[a,b] + saving[b,a]*(1-before[a,b]));
param ts := sum{(a,b) in PAIRS} (saving[a,b]+saving[b,a]);
param fs := rs/ts;

/* Display Problem Data */
printf "\nPROBLEM DATA";
printf "\n\nSavings for performing Task A before Task B\n\n A\\B";
printf {b in TASKS} "%3d",b ;
for {a in TASKS}{
    printf "\n %2d:",a;
    for {b in TASKS}{
        printf "%3d",saving[a,b];
    }
}

/* Display Solution */
printf "\n\nSOLUTION\n\n";
printf "   Potential Savings = %2d\n", ts;
printf "  Realizable Savings = %2d\n", rs;
printf " Fraction Realizable = %6.4f\n\n", fs;

printf "Task: Position\n";
printf {a in TASKS} "  %2d  :  %2d\n", a, position[a];

printf "\nPosition: Task\n";
printf {k in 1..M, a in TASKS: k = round(position[a])} " %3s  : %3s\n", k,a;

printf "\n\n Realized Savings\n\n  A   B: Saving\n";
printf {(a,b) in PAIRS: before[a,b]*saving[a,b] + (1-before[a,b])*saving[b,a] > 0} 
    "%3s %3s:  %3d\n",
    if before[a,b]*saving[a,b] > 0 then a else b,
    if before[a,b]*saving[a,b] > 0 then b else a,
    if before[a,b]*saving[a,b] > 0 then saving[a,b] else saving[b,a];

printf "\nBinary Ordering Variable [a,b] for a < b\n\n   ";
printf {b in TASKS} "%3d",b ;
for {a in TASKS}{
    printf "\n%2d:",a;
    for {(a,b) in PAIRS}{
        printf "%3d",before[a,b];
    }
}

printf "\n\n";

data;

param M := 15;

param saving default 0: 
        1   2   3   4   5   6   7   8   9  10  11  12  13  14  15 :=
    1   .   2   .   2   .   .   .   .   1   .   .   .   .   .   .
    2   2   .   .   .   .   .   .   .   .   .   .   .   .   .   3
    3   4   .   .   .   1   .   .   .   .   .   .   .   .   .   .
    4   1   .   1   .   2   .   .   .   .   1   .   .   .   .   .
    5   .   1   .   .   .   .   .   .   .   1   .   .   1   1   1
    6   .   .   .   1   .   .   .   1   .   .   2   .   .   .   1
    7   .   2   .   .   .   .   .   .   .   .   .   .   .   .   3
    8   .   .   .   .   4   .   .   .   .   .   1   .   .   .   .
    9   .   1   2   .   .   .   .   .   .   .   1   .   1   .   .
   10   .   .   .   .   .   .   .   .   .   .   4   .   .   .   1
   11   1   .   1   .   .   .   .   1   .   1   .   1   .   .   .
   12   3   .   .   1   .   .   .   .   .   .   1   .   .   .   .
   13   .   .   2   .   .   .   .   .   .   .   .   3   .   .   .
   14   .   .   1   .   .   1   1   1   .   .   .   1   .   .   .
   15   .   .   .   .   .   2   .   .   .   .   .   2   1   .   . ;

end;