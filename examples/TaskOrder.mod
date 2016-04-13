/* # Linear Ordering of Tasks

The 'Linear Ordering Problem' has a wide range of applications such as 
    ranking teams in sports, reordering rows and columns of tables 
    (triangulation problem), and ordering individual preferences. These are
    known to be an NP hard problems but state of the art algorithms provide
    practical solution for meaningful applications.

Here we use an <a rel="external" href="http://www.jstor.org/pss/170944">older 
    formulation</a> suited to an MIP implementation to solve a problem 
    that was posed some time ago on the help-glpk mail list (slightly 
    edited): 

> I am modelling a project in which doing some tasks before others will
> save time. The project I am working on is an application to manage 
> Windows printing. The reason why doing some tasks makes other tasks 
> easier (hence quicker) is that a lot of it entails interaction with 
> the operating system: changes have to be made to the registry in 
> multiple modules, the Active Directory (AD) has to be modified so 
> that users have extra fields, entries to the print queue have to be 
> paused, then they have to be queried to find the owner, who then has
> to be located in the AD via an LDAP query, and the print job has to
> be priced by printer, print type and number of pages, then if that
> user is online, a pop-up must appear for them to release the print 
> job (if they have sufficient funding in their account), then the 
> funding in their account has to be updated. It's a complicated task 
> (if you ever try to build such an application, you'll realise that for
> something that looks simple, a large number of factors have to be 
> considered), but it entails a lot of OS callswhich are easier when 
> similar work has been done  already.

> I think that the model is correct - but even though I have only entered
> the savings for 1 task into the objective function, it is taking too
> long to run. I believe that the problem lies in my "before1" and 
> "before2" conditions, each of which contain 15^4=50625 modelling 
> variables. These conditions are needed to enable the before[] variable, 
> where before[a,b]=1 means that task a will be completed before task b.

> * if position[a] > position[b], then before[a,b] = 0</li>
> * if position[a] < position[b], then before[a,b] = 1</li>

> The variable position[] is working correctly (position[5]=3 means that
        task five will be done third). I could eliminate the huge amount of 
        work being done in the "before1" and "before2" conditions if I could 
        make use of these position variables. Could anyone advise me how I can
        achieve the following, please?
    </p>
    <p>
        Thanks for any suggestions!
    </p>
</blockquote>
<blockquote>
<pre>

Model appended below:

      The project consists of 15 tasks. Completion of any of these tasks will 
      save time on other tasks in the project as follows:

      Task 1 savings: 2 hours on task 2: 2 hours on task 4: 1 hours on task 9
      Task 2 savings: 2 hours on task 1: 3 hours on task 15
      Task 3 savings: 4 hours on task 1: 1 hours on task 5
      Task 4 savings: 1 hours on task 1: 1 hours on task 3: 2 hours on task 5:    
                      1 hours on task 10
      Task 5 savings: 1 hours on task 2: 1 hours on task 10: 
                      1 hours on task 15
      Task 6 savings: 1 hours on task 4: 1 hours on task 8:
                      2 hours on task 11: 1 hours on task 15
      Task 7 savings: 2 hours on task 2: 3 hours on task 15
      Task 8 savings: 4 hours on task 5: 1 hours on task 11
      Task 9 savings: 1 hours on task 2: 2 hours on task 3:
                      1 hours on task 11: 1 hours on task 13
      Task 10 savings: 4 hours on task 11: 1 hours on task 15
      Task 11 savings: 1 hours on task 1: 1 hours on task 3: 
                       1 hours on task 8: 1 hours on task 10:
                       1 hours on task 12
      Task 12 savings: 3 hours on task 1: 1 hours on task 4: 
                       1 hours on task 11
      Task 13 savings: 2 hours on task 3: 3 hours on task 12
      Task 14 savings: 1 hours on task 3: 1 hours on task 6: 
                       1 hours on task 7: 1 hours on task 8: 
                       1 hours on task 12
      Task 15 savings: 2 hours on task 6: 2 hours on task 12:
                       1 hours on task 13 
</pre>
</blockquote>
<p>
    The original message included a sample gmpl file that is not included 
    here.
</p>
<p>
    The problem data consists of a matrix saving[a,b] that provides the savings
    resulting from scheduling task a before task b for a set of M tasks.
</p>
<p>
    The poster's  modeling strategy  is to  define  a two-dimensional  array 
    of binary decision variables before[a,b] such that before[a,b] = 1 means
    that task a is completed before task b. We use the relationship 
    before[a,b] = 1 - before[b,a] to avoid redundant decision variables and
    constraints. We don't care about diagonal elements before[a,a] because 
    they have no meaning for the problem.
</p>
<p>
    The poster suggests a second vector of decision variables position[a] 
    denoting the position of task a in the overall queue.  However, because 
    this can be computed from the binary decision variables, we leave the it
    to the post-processing step.
</p> 
<p>
    With this solution strategy the model easily runs in less than 1 second on
    a laptop computer which meets the poster's requirements.

Ref: Martin Grotschel, Michael Junger, and Gerhard Reinelt, "A Cutting Plane
    Algorithm for the Linear Ordering Problem," Operations Research, 32(6), pp.
    1195-1220, 1984.
*/

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