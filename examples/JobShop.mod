/* # Job Shop Scheduling

A simple job shop consists of a set of different machines that process jobs. 
Each job consists of series of tasks that must be completed in specified order
on the machines. The problem is to schedule the jobs on the machines to minimize 
makespan.

Data consists of two tables. The first table is decomposition of the jobs into
a series of tasks. Each task lists a job name, name of the required machine, 
and task duration.  The second table list task pairs where the first task must 
be completed before the second task can be started. This formulation is quite 
general, but can also specify situations with no feasible solutions.
*/

/* Data Table 1. Tasks consist of Job, Machine, Dur data*/
set TASKS dimen 2;
param dur{TASKS};

/* Data Table 2 */
set TASKORDER within {TASKS,TASKS};

/* JOBS and MACHINES are inferred from the data tables*/
set JOBS := setof {(j,m) in TASKS} j;
set MACHINES := setof {(j,m) in TASKS} m;

/* Decision variables are start times for tasks, and the makespan */
var start{TASKS} >= 0;
var makespan >= 0;

/* BigM is set to be bigger than largest possible makespan */
param BigM := 1 + sum {(j,m) in TASKS} dur[j,m];

/* The primary objective is to minimize makespan, with a secondary
objective of starting tasks as early as possible */
minimize OBJ: BigM*makespan + sum{(j,m) in TASKS} start[j,m];

/* By definition, all jobs must be completed within the makespan */
s.t. A {(j,m) in TASKS}: start[j,m] + dur[j,m] <= makespan;

/* Must satisfy any orderings that were given for the tasks. */
s.t. B {(k,n,j,m) in TASKORDER}: start[k,n] + dur[k,n] <= start[j,m];

/* Eliminate conflicts if tasks are require the same machine */
/* y[i,m,j] = 1 if Job i is scheduled before job j on machine m*/
var y{(i,m) in TASKS,(j,m) in TASKS: i < j} binary;
s.t. C {(i,m) in TASKS,(j,m) in TASKS: i < j}:
   start[i,m] + dur[i,m] <= start[j,m] + BigM*(1-y[i,m,j]);
s.t. D {(i,m) in TASKS,(j,m) in TASKS: i < j}:
   start[j,m] + dur[j,m] <= start[i,m] + BigM*y[i,m,j];

solve;

printf "Makespan = %5.2f\n",makespan;

/* Post solution, compute finish times for each task to use in report */
param finish{(j,m) in TASKS} := start[j,m] + dur[j,m];

/* Task Summary Report */
printf "\n                TASK SUMMARY\n";
printf "\n     JOB   MACHINE     Dur   Start  Finish\n";
printf {(i,m) in TASKS} "%8s  %8s   %5.2f   %5.2f   %5.2f\n", 
   i, m, dur[i,m], start[i,m], finish[i,m];

/* Schedule of activities for each job */
set M{j in JOBS} := setof {(j,m) in TASKS} m;
param r{j in JOBS, m in M[j]} := 
   1+sum{n in M[j]: start[j,n] < start[j,m] || start[j,n]==start[j,m] && n < m} 1;
printf "\n\n           JOB SCHEDULES\n";
for {j in JOBS} {
   printf "\n%s:\n",j;
   printf "         MACHINE   Start   Finish\n";
   printf {k in 1..card(M[j]), m in M[j]: k==r[j,m]} 
      " %15s   %5.2f    %5.2f\n",m, start[j,m],finish[j,m];
}

/* Schedule of activities for each machine */
set J{m in MACHINES} := setof {(j,m) in TASKS} j;
param s{m in MACHINES, j in J[m]} := 
   1+sum{k in J[m]: start[k,m] < start[j,m] || start[k,m]==start[j,m] && k < j} 1;
printf "\n\n         MACHINE SCHEDULES\n";
for {m in MACHINES} {
   printf "\n%s:\n",m;
   printf "             JOB   Start   Finish\n";
   printf {k in 1..card(J[m]), j in J[m]: k==s[m,j]} 
      " %15s   %5.2f    %5.2f\n",j, start[j,m],finish[j,m];
}

data;

/* Job shop data from Christelle Gueret, Christian Prins,  Marc Sevaux,
"Applications of Optimization with Xpress-MP," Chapter 5, Dash Optimization, 2000. */

/* Jobs are broken down into a list of tasks (j,m), each task described by
job name j, machine name m, and duration dur[j,m] */

param: TASKS: dur :=
   Paper_1  Blue    45
   Paper_1  Yellow  10
   Paper_2  Blue    20
   Paper_2  Green   10
   Paper_2  Yellow  34
   Paper_3  Blue    12
   Paper_3  Green   17
   Paper_3  Yellow  28 ;

/* List task orderings (k,n,j,m) where task (k,n) must proceed task (j,n) */

set TASKORDER :=
   Paper_1 Blue    Paper_1 Yellow
   Paper_2 Green   Paper_2 Blue
   Paper_2 Blue    Paper_2 Yellow
   Paper_3 Yellow  Paper_3 Blue
   Paper_3 Blue    Paper_3 Green ;

end;