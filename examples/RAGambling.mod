/* # Stochastic Dynamic Programming: The Risk Averse Gambler

## Problem Statement

A risk averse gambler with enters a game with the idea
    of betting for a fixed number of rounds \\(T\\). With a stake \\(x\\) and wager
    \\(u\\), the resulting state is either \\(x+u\\) with probability \\(p\\), or 
    \\(x-u\\) with probability \\(q\\) where \\[p + q \leq 1\\] The wager must be
    an integer smaller than the current stake or the maximum wager established
    for the game. The total stake is limited to an amount \\(N\\). The gambler
    is risk averse where utility of the final stake is \\(\log(x)\\). Given an
    initial stake \\(x < N\\), calculate a strategy that maximizes the expected
    utility at the end of the game.

## Formulation of a Solution

This is a classic problem in Stochastic Dynamic Programming. The 
    function \\(V(k,x)\\) is the expected utility after of stake \\(x\\) after the 
    \\(k^{th}\\) wager. The expected utility satisfies the optimality equation
    \\[V(k,x) = max_u [ p V(k+1,x+u) + q V(k+1,x-u) ]\\] where \\(V(T,x) = 
    \log(x)\\). The maximization is over the set of possible bets ranging from 
    \\(0\\) to the minimum of \\(x\\), \\(N-x\\), or the bet limit \\(B\\). Note that 
    the state space and set of control actions are finite.


## Solution by Linear Programming

The optimality equation can be solved by well known methods for policy 
    iteration.  Alternatively, as shown for example by Ross in "Introduction to 
    Stochastic Dynamic Programming" (Academic Press, 1983), an exact solution can 
    be found by linear programming. We seek a solution \\(V[k,x]\\) minimizing
    \\[\sum_{k=0}^{T-1}\sum_{x=0}^N V[k,x]\\]  subject to 
    \\[V[k,x] \geq p V[k+1,x+u] + q V[k+1,x-u]\\]
    for all feasible bets and boundary condition \\(V[T,x] = \log(x)\\). The set of 
    optimal wagers \\(u[x]\\) are found by determining the constraints that are 
    active at optimality.
*/

/*
Jeff Kantor
December 18, 2009
*/

/* Problem Parameters.  Any of these can be adjusted in a data section.  */

param T default 5 >= 1;              # Stages
param N default 50, >= 1;            # Maximum Stake (reduce if computations are slow)
param p default 0.55, >= 0, <= 1;    # Winning probability
param q default 1-p, >= 0, <= 1-p;   # Losing probability
param B default N, >= 1, <= N;       # Maximum wager size

/* Set of States */

set X:= 1..N;

/* Sets of possible wagers. These are parameterized by the State */

set U{x in X} := 0..min(B,min(N-x,x-1));

/* Value function */

var V{0..T,X}>=0;

/* Exact Linear Program Equivalent of the DP */

minimize OBJ: sum{t in 0..T-1, x in X} V[t,x] ;

s.t. C1 {t in 0..T-1, x in 1..N, u in U[x]}:
   V[t,x] >=  p*V[t+1,x+u] + q*V[t+1,x-u];
s.t. C2 {x in X}: V[T,x] = log(x);

solve;

/* Find Optimal Wager */
param w{t in 0..T-1,x in 1..N} := 
   if x==N then 0
   else min{u in U[x]:
      abs(-V[t,x]+p*V[t+1,x+u]+q*V[t+1,x-u])<0.000001} u;

table tab1 {x in X} OUT "JSON" "Optimal Wager" "LineChart" : 
    x, w[T-1,x]~Wager;
    
table tab2 {x in X} OUT "JSON" "Expected Utility of the Initial Stake" "LineChart" :
    x, exp(V[T-1,x])~ExpectedUtility;

printf "   Number of Wagers = %4d\n", T;
printf "      Maximum Stake = %4d\n", N;
printf "        Maximum Bet = %4d\n", B;
printf "Winning Probability = %8.3f\n", p ;
printf " Losing Probability = %8.3f\n", q ;
printf "\n  %7s ",' ';
printf {t in 0..T-1} "   Wager %2s  ", t+1;
printf "\n %7s ",'Stake';
printf {t in 0..T-1} "   CE[x] u[x]";
printf "\n %7s ",'-----';
printf {t in 0..T-1} "   %9s ", '---------';
for {x in X}{
   printf "\n %7d", x;
   printf {t in 0..T-1} "   %6.2f %3d", exp(V[t,x]), w[t,x];
}

end;