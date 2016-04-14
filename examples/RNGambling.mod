/*
## Stochastic Dynamic Programming: Risk Neutral Gambler

### Problem Statement

The risk neutral gambler enters a game with the idea of betting until 
he or she is either reaches a goal \\(N\\) or runs out of money.
Given a stake \\(x\\) and wager \\(u\\), the result is a stake that is either 
\\(x+u\\) with probability \\(p\\), or a stake \\(x-u\\) with probability \\(q\\).
The probabilities sastisfy the inequality

\\[p + q \leq 1\\]

The wager must be smaller than the stake or any maximum wager established for 
the game.  To encourage risk taking, the future value of money is discounted 
by a factor \\(a \leq 1\\).  

Given an initial stake \\(x < N\\), what is the optimal gambling strategy?

### Formulation

This classic problem in Dynamic Programming is discussed, for example, by 
Sutton and Barto in "Reinforcement Learning" (MIT Press, 1998). The function
\\(V(k,x)\\) is the expected value of the game after the kth wager and with a
stake \\(x\\). If the gambler reaches the goal of winning a stake \\(N\\) at
\\(k\\) then the value of the game is \\(V(k,N) = N\\). Or if the gamble
loses everything, then \\(V(k,0) = 0\\). Otherwise, for \\(x < N\\), the
Bellman equation for optimality provides the recursion

\\[V(k-1,x) = a \max_u  [ p V(k,x+u) + q V(k,x-u) ]\\]

where \\(a\\) is the discount factor for future values. The maximization is
over the set of possible bets ranging from \\(0\\) to the minimum of \\(x\\),
\\(N-x\\), or the bet limit \\(B\\). Note that the state space and set of
control actions are finite.

### Solution by Linear Programming

The optimality equation can be solved by well known methods for policy 
iteration.  Alternatively, as shown for example by Ross in "Introduction to 
Stochastic Dynamic Programming" (Academic Press, 1983), an exact solution can 
be found by linear programming. We seek a stationary solution \\(V[x]\\) by 
minimizing \\(\sum_{x \in 0..N} V[x]\\)  subject to 

\\[V[x] \geq a (p V[x + u] + q V[x-u])\\]

for all feasible bets and all \\(x \\in 1..N-1\\) with boundary conditions \\(V[0] = 0\\) 
and \\(V[N] = N\\).  The set of optimal wagers \\(u[x]\\) are found by determing the
constraints that are active at optimality.  \\(u[x]\\) may have multiple values.*/

/* Problem Parameters.  Any of these can be adjusted in a data section.  */

param N default 100, >= 1;               # Goal
param p default 0.25, >= 0, <= 1;        # Winning probability
param q default 1-p, >= 0, <= 1-p;       # Losing probability
param B default N, >= 1, <= N;           # Maximum wager size
param a default 1, >= 0, <= 1;           # Discount factor

/* Set of States */

set X:= 0..N;

/* Sets of possible wagers. These are parameterized by the State */

set U{x in X} := 1..min(B,min(N-x,x));

/* Value function */

var V{X};

/* Exact Linear Program Equivalent of the DP */

minimize OBJ: sum{x in X} V[x] ;

s.t. C1 {x in 1..N-1, u in U[x]}: V[x] >=  a*(p*V[x+u] + q*V[x-u]);
s.t. C2: V[0] = 0;
s.t. C3: V[N] = N;

solve;

table tab1 {x in X} OUT "JSON" "Expected Value of the Initial Stake" "LineChart" : 
    x~Stake, V[x]~ExpectedValue;

printf "               Goal = %4d", N;
printf "\n        Maximum Bet = %4d", B;
printf "\nWinning Probability = %8.3f", p ;
printf "\n Losing Probability = %8.3f", q ;
printf "\n    Discount Factor = %8.3f", a;
printf "\n\n %7s  %10s   %4s\n",'x','V[x]','u[x]: Optimal Wagers';
printf     " %7s  %10s   %4s"  ,'-','----','---------------------';
for {x in X}{
   printf "\n %7d  %10.4f  ",x, V[x];
   printf {u in U[x]: abs(-V[x] + a*(p*V[x+u] + q*V[x-u])) < 0.00001} " %3d",u;
}

end;
