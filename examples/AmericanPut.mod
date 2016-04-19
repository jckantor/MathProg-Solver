/* # Binomial Pricing Model for an American Put Option

Determines the price of an American put option for an asset in which the
price model is a binomial tree. The option price is the minimum value
of a portfolio that replicates the option payoff at expiration, and can
payoff the early exercise of the option. (Data is from Hull, Sec 11.7).
*/

# Asset Model
param S0 := 50;          # initial price   
param r := 0.06;         # mean return (annualized)
param sigma := 0.3;      # volatility (annualized)

# Bond Price
param B0 := 1;           # initial value
param rf := 0.05;        # risk-free interest rate

# Option
param Kstrike := 52;     # strike price
param Tf := 2;           # time to expiration (years)

# Construct a recombining binomial tree
param nPeriods := 2;
set PERIODS := {0..nPeriods};
set STATES {p in PERIODS} := {0..p};
param u := exp(sigma*sqrt(Tf/nPeriods));
param d := 1/u;
param pr := (exp(r*Tf/nPeriods)-d)/(u-d);

param B {p in PERIODS, s in STATES[p]} := B0*(1 + rf*Tf/nPeriods)**p;
param S {p in PERIODS, s in STATES[p]} := S0*(d**(p-s))*(u**(s));

# Replicating Portfolio
var P{p in PERIODS, s in STATES[p]};
var x{p in PERIODS, s in STATES[p]};
var y{p in PERIODS, s in STATES[p]};

portfolio {p in PERIODS, s in STATES[p]}: P[p,s] = x[p,s]*B[p,s] + y[p,s]*S[p,s];

# Self financing constraints
do {p in PERIODS, s in STATES[p] : p < nPeriods}: 
    x[p,s]*B[p+1,s] + y[p,s]*S[p+1,s] >= P[p+1,s];
up {p in PERIODS, s in STATES[p] : p < nPeriods}: 
    x[p,s]*B[p+1,s+1] + y[p,s]*S[p+1,s+1] >= P[p+1,s+1];

# Finance early exercise option
edo{p in PERIODS, s in STATES[p] : p < nPeriods}: 
    x[p,s]*B[p+1,s] + y[p,s]*S[p+1,s] >= Kstrike - S[p+1,s];
eup{p in PERIODS, s in STATES[p] : p < nPeriods}: 
    x[p,s]*B[p+1,s+1] + y[p,s]*S[p+1,s+1] >= Kstrike - S[p+1,s+1];
    
# Payoff option value
Payoff {s in STATES[nPeriods]} : P[nPeriods,s] >= max(0, Kstrike - S[nPeriods,s]);

# Objective
minimize OptionPrice : P[0,0];
    
solve;

printf "Option Price Value = %.2f\n", P[0,0];
    
table results {p in PERIODS, s in STATES[p]} OUT "JSON" "Binomial Tree" "Table" :
    p~Period, s~State, B[p,s]~Bond, S[p,s]~Asset, P[p,s]~Option;

end;
