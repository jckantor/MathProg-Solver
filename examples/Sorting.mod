/* # Sorting in MathProg

MathProg is a lean language with a limited number of functions and 
    utilities. Demonstrated below  are several techniques for sorting sets 
    by value of parameters or decision variables. These techniques may be 
    useful in other contexts.

These ideas are attributable to xypron and Andrew Makhorin on the 
    help-glpk mail list.
*/

set I;
param a{I};

/* Unordered Set */

printf "\nUnordered Set\n";
printf {i in I} "     %8s  %7.4f\n", i, a[i];

/* Set in Ascending Order.  r[i] computes the rank-order of corresponding 
elements in a[i].  The list is then scanned in the domain of a printf 
statement. This is an order n^3 technique which appears to be the best one can 
do in GMPL. */

printf "\nAscending Order\n";
param r{i in I} := 1 + sum {j in I} if (a[j] < a[i] || a[j] == a[i] && j < i) then 1;
printf {k in 1..card(I), i in I: k == r[i]}  "%3d: %8s  %7.4f\n", r[i], i, a[i];

/* Set in Descending Order with comparison within the domain spec */

printf "\nDescending Order\n";
param s{i in I} := 1 + sum {j in I : a[i] < a[j] || a[i] == a[j] && i < j} 1;
printf {k in 1..card(I), i in I: k == s[i]}  "%3d: %8s  %7.4f\n", s[i], i, a[i];

/* There may be instances where it would be useful to compute rank-order  in 
the optimization model, such as portfolio optimization with a VaR constraint, 
for example.  */

param BigM := 1 + sum{i in I} abs(a[i]);

var y{i in I, j in I : i<>j } binary;    # y[i,j] = 0 if a[i] <= a[j]
var t{i in I};                           # rank-order of a[i]

/* Pair of disjunctive constraints to force ordering of a[i] */
s.t. A{i in I, j in I : i<>j}: a[i] <= a[j] + BigM*y[i,j];
s.t. B{i in I, j in I : i<>j}: a[j] <= a[i] + BigM*(1-y[i,j]);

/* Forces a tie breaker if a[i] = a[j] */
s.t. C{i in I, j in I : i<>j}: y[i,j] + y[j,i] = 1;

/* t[i] is rank-order could be computed post-solution */
s.t. D{i in I}: t[i] = 1 + sum{j in I: i<>j} y[i,j];           

solve;

printf "\nAscending Order by Optimization\n";
printf {k in 1..card(I), i in I: k ==t[i]}  "%3d: %8s  %7.4f\n", t[i], i, a[i];

data;

param: I: a :=
   alpha    1
   beta     2
   gamma    2
   delta   -1.2
   chewy   -1.3
   fruity   3
   gummy   10
   doug    -3 ;

end;