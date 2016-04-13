/* # Jesuit Volunteer Corps

The following problem was formulated by Tomas C. (ND '09) who was working with 
the Jesuit Volunteer Corp in 2009-2010. Here was his problem:

> There are 7 of us in the house. We have broken down the chores into 4 
> major sections: 1) Kitchen, 2) Bathroom, 3) Common Area, 4) Trash. The 
> trash is the only task that needs only one person to accomplish, the 
> other 3 tasks have 2 people assigned to them. Each person needs to rotate
> through each task twice and the trash only once. The assignments rotate 
> each week. Each person needs to have a new partner each week and no 
> person can have more than one task in a week.

In the formulation below we require every possible pair to do at least one task 
together. This is different that requiring a new partner each week, but Tomas
said later that this would meet their needs.

This a challenging computation, depending on your computer this may take a few seconds
to a few minutes to complete a solution.
*/

/* Number of weeks to schedule */
param T :=  7;

/* Numeric labels for volunteers facilitate creating non-replicated pairs */
set VOLS := 1..7;
set TASKS := {'Kitchen', 'Bathroom', 'Commons', 'Trash'};
set WEEKS := 1..T;

/* Compute all pairs of volunteers */
set PAIRS := setof{u in VOLS, v in VOLS: u < v} (u,v);

/* x[v,t,w] = 1 if volunteer v is assigned task t in week w */
var x{v in VOLS, t in TASKS, w in WEEKS} binary;

/* p[u,v,t,w] = 1 if volunteers u and v are paired together on t in week w */
var p{(u,v) in PAIRS, t in TASKS, w in WEEKS} binary;

/* The objective will be the number of times anyone has to do the trash */
var z integer;

minimize obj: z;

/* Each volunteer each week must be assigned one task */
s.t. fa{v in VOLS, w in WEEKS}: sum {t in TASKS} x[v,t,w] = 1;

/* Except for Trash, each task each week must be assigned two volunteers */
s.t. fb{w in WEEKS}: sum {v in VOLS} x[v,'Trash',w] = 1;
s.t. fc{t in TASKS, w in WEEKS : t <> 'Trash'}: sum {v in VOLS} x[v,t,w] = 2;

/* Each volunteer must cycle through each task twice (except trash) */
s.t. fd{t in TASKS, v in VOLS : t <> 'Trash'}: sum {w in WEEKS} x[v,t,w] >= 2;

/* Minimize number of times anyone has to do trash */
s.t. fz{v in VOLS}: sum {w in WEEKS} x[v,'Trash',w] <= z;

/* Pair p(u,v,t,w) is 1 if u and v worked together on Week w and Task t */
s.t. ga{t in TASKS, w in WEEKS, (u,v) in PAIRS}: p[u,v,t,w] <= x[u,t,w];
s.t. gb{t in TASKS, w in WEEKS, (u,v) in PAIRS}: p[u,v,t,w] <= x[v,t,w];
s.t. gc{t in TASKS, w in WEEKS, (u,v) in PAIRS}: 
   p[u,v,t,w] >= x[u,t,w] + x[v,t,w] - 1;

/* Each possible pair must do at least one task together. */
s.t. gd{(u,v) in PAIRS}: sum{t in TASKS, w in WEEKS} p[u,v,t,w] >= 1;

solve;

printf "Volunteer Assignments by Weeks";
for {w in WEEKS}{
   printf "\n\nWeek: %2s\n",w;
   printf "Volunteer:";
   printf {v in VOLS} "%3s",v;
   for {t in TASKS}{
      printf "\n%9s:",t;
      printf {v in VOLS} "%3s", if x[v,t,w]=1 then "X" else "-";
   }
}

printf "\n\n\n Analysis of Volunteer Pairs";
for{(u,v) in PAIRS}{
   printf "\n\nPair: (%s,%s)\n",u,v;
   printf "     Week:";
   printf {w in WEEKS} "%3s",w;
   for {t in TASKS}{
      printf "\n%9s:",t;
      printf {w in WEEKS} "%3s", if p[u,v,t,w]=1 then "X" else "-";
   }
}

end;