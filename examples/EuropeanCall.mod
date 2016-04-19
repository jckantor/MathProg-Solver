/* # Binomial Pricing Model for a European Call Option

Determines the price of a European call option for an asset in which the
price model is a binomial tree. The option price is the minimum value
of a portfolio that replicates the option payoff at expiration.
*/

# Asset Model
param S0 := 100;         # initial price   
param r := 0.06;         # mean return (annualized)
param sigma := 0.3;      # volatility (annualized)

# Bond Price
param B0 := 1;           # initial value
param rf := 0.03;        # risk-free interest rate

# Option
param Kstrike := 110;    # strike price
param Tf := 1;           # time to expiration (years)

# Construct a recombining binomial tree
param nPeriods := 10;
set PERIODS := {0..nPeriods};
set STATES {p in PERIODS} := {0..p};
param u := exp(sigma*sqrt(Tf/nPeriods));
param d := 1/u;
param pr := (exp(r*Tf/nPeriods)-d)/(u-d);

param B {p in PERIODS, s in STATES[p]} := B0*(1 + rf*Tf/nPeriods)**p;
param S {p in PERIODS, s in STATES[p]} := S0*(d**(p-s))*(u**(s));

# Replicating Portfolio
var C{p in PERIODS, s in STATES[p]};
var x{p in PERIODS, s in STATES[p]};
var y{p in PERIODS, s in STATES[p]};

portfolio {p in PERIODS, s in STATES[p]}: C[p,s] = x[p,s]*B[p,s] + y[p,s]*S[p,s];

# Self financing constraints
do {p in PERIODS, s in STATES[p] : p < nPeriods}: 
    x[p,s]*B[p+1,s] + y[p,s]*S[p+1,s] >= C[p+1,s];
up {p in PERIODS, s in STATES[p] : p < nPeriods}: 
    x[p,s]*B[p+1,s+1] + y[p,s]*S[p+1,s+1] >= C[p+1,s+1];
    
# Payoff option value
Payoff {s in STATES[nPeriods]} : C[nPeriods,s] >= max(0, S[nPeriods,s] - Kstrike);

# Objective
minimize OptionPrice : C[0,0];
    
solve;

printf "Option Price Value = %.2f\n", C[0,0];

table results {p in PERIODS, s in STATES[p]} OUT "JSON" "Binomial Tree" "Table" :
    p~Period, s~State, B[p,s]~Bond, S[p,s]~Asset, C[p,s]~Option;

end;
