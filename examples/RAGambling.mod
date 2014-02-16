/* Example:  RAGambling.mod Stochastic Dynamic Programming: Risk Averse Gambler

Jeff Kantor
December 18, 2009

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