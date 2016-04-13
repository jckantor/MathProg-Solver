/* # Project Management with the Critical Path Method

The Critical Path Method is a technique for calculating the shortest time span 
    needed to complete a series of tasks. The tasks are represented by nodes, each 
    labelled with the duration. The precedence order of the task is given by a set 
    of arcs.

Here we demonstrate the representation and calculation of the critical path. 
    Decision variables are introduced for

* Earliest Start
* Earliest Finish
* Latest Start
* Latest Finish
* Slack = Earliest Finish - Earliest Start = Latest Finish - Earliest  Finish

Tasks on the Critical Path have zero slack.
*/

set TASKS;
set ARCS within {TASKS cross TASKS};

/* Parameters are the durations for each task */
param dur{TASKS} >= 0;

/* Decision Variables associated with each task*/
var Tes{TASKS} >= 0;     # Earliest Start
var Tef{TASKS} >= 0;     # Earliest Finish
var Tls{TASKS} >= 0;     # Latest Start
var Tlf{TASKS} >= 0;     # Latest Finish
var Tsl{TASKS} >= 0;     # Slacks

/* Global finish time */
var Tf >= 0;

/* Minimize the global finish time and, secondarily, maximize slacks */
minimize ProjectFinish : card(TASKS)*Tf - sum {j in TASKS} Tsl[j];

/* Finish is the least upper bound on the finish time for all tasks */
s.t. Efnsh {j in TASKS} : Tef[j] <= Tf;
s.t. Lfnsh {j in TASKS} : Tlf[j] <= Tf;

/* Relationship between start and finish times for each task */
s.t. Estrt {j in TASKS} : Tef[j] = Tes[j] + dur[j];
s.t. Lstrt {j in TASKS} : Tlf[j] = Tls[j] + dur[j];

/* Slacks */
s.t. Slack {j in TASKS} : Tsl[j] = Tls[j] - Tes[j];

/* Task ordering */
s.t. Eordr {(i,j) in ARCS} : Tef[i] <= Tes[j];
s.t. Lordr {(j,k) in ARCS} : Tlf[j] <= Tls[k];

/* Compute Solution  */
solve;

/* Print Report */
printf 'PROJECT LENGTH = %8g\n',Tf;

/* Critical Tasks are those with zero slack */

/* Rank-order tasks on the critical path by earliest start time */
param r{j in TASKS : Tsl[j] = 0} := sum{k in TASKS : Tsl[k] = 0}
   if (Tes[k] <= Tes[j]) then 1;

printf '\nCRITICAL PATH\n';
printf '    TASK    DUR     Start    Finish\n';
printf {k in 1..card(TASKS), j in TASKS : Tsl[j]=0 && k==r[j]}
   '%8s %6g  %8g  %8g\n', j, dur[j], Tes[j], Tef[j];

/* Noncritical Tasks have positive slack */

/* Rank-order tasks not on the critical path by earliest start time */
param s{j in TASKS : Tsl[j] > 0} := sum{k in TASKS : Tsl[k] = 0}
   if (Tes[k] <= Tes[j]) then 1;

printf '\nNON-CRITICAL TASKS\n';
printf '                 Earliest  Earliest    Latest    Latest \n';
printf '    TASK    DUR     Start    Finish     Start    Finish     Slack\n';
printf {k in 1..card(TASKS), j in TASKS : Tsl[j] > 0 && k==s[j]}
   '%8s %6g  %8g  %8g  %8g  %8g  %8g\n', 
   j,dur[j],Tes[j],Tef[j],Tls[j],Tlf[j],Tsl[j];
printf '\n';

data;

/* Stadium Construction Example from Christelle Gueret, Christian Prins, 
Marc Sevaux, "Applications of Optimization with Xpress-MP," Chapter 5,
Dash Optimization, 2000. */ 

param : TASKS : dur :=
   T01   2.0
   T02  16.0
   T03   9.0
   T04   8.0
   T05  10.0
   T06   6.0
   T07   2.0
   T08   2.0
   T09   9.0
   T10   5.0
   T11   3.0
   T12   2.0
   T13   1.0
   T14   7.0
   T15   4.0
   T16   3.0
   T17   9.0
   T18   1.0 ;

set ARCS := 
   T01  T02
   T02  T03
   T02  T04
   T02  T14
   T03  T05
   T04  T07
   T04  T10
   T04  T09
   T04  T06
   T04  T15
   T05  T06
   T06  T09
   T06  T11
   T06  T08
   T07  T13
   T08  T16
   T09  T12
   T11  T16
   T12  T17
   T14  T16
   T14  T15
   T17  T18 ;

end;