# Binomial Options Pricing Model
#
# Determines the price of an option for an asset in which the underlying
# price model is a binomial tree. The option price is a bound on the
# initial value of a portfolio replicating the option payoff.

# Asset Price
param S0 := 100;
param r := 0.06;
param sigma := 0.3;

# Bond Price
param B0 := 1;
param rf := 0.03;

# Option Model
param Kstrike := 110;
param Tf := 1;

# Construct a recombining binomial tree
param nPeriods := 20;
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
sf_do {p in PERIODS, s in STATES[p] : p < nPeriods}: 
    x[p,s]*B[p+1,s] + y[p,s]*S[p+1,s] >= C[p+1,s];
sf_up {p in PERIODS, s in STATES[p] : p < nPeriods}: 
    x[p,s]*B[p+1,s+1] + y[p,s]*S[p+1,s+1] >= C[p+1,s+1];
    
# Payoff option value
Payoff {s in STATES[nPeriods]} : C[nPeriods,s] >= max(0, S[nPeriods,s] - Kstrike);

# Objective
minimize OptionPrice : C[0,0];
    
solve;

printf "Option Price Value = %.2f\n", C[0,0];

table results {p in PERIODS, s in STATES[p]} OUT "JSON" "Table" :
    p~Period, s~State, B[p,s]~Bond, S[p,s]~Asset, C[p,s]~Option;

end;
