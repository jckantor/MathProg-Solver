# Loan Planner

set LOANS;

param nPer := 6.5*12;
#param rate := 0.04875/12;
param rate := 0.03875/12;
param amt := 104410.21;

set N := 0..nPer;

var bal{N} >= 0;
var int{N} >= 0;
var prn{N} >= 0;
var minPay;

# Initial conditions
s.t. IC1: bal[0] = amt - prn[0];
s.t. IC2: int[0] = 0;
s.t. IC3: prn[0] = 0;

# Payments
s.t. PY1 {n in 1..nPer}: bal[n] = (1+rate)*bal[n-1] - int[n] - prn[n];
s.t. PY2 {n in 1..nPer}: int[n] = rate*bal[n-1];
s.t. PY3 {n in 1..nPer}: int[n] + prn[n] <= minPay; # 1565.44;

# Final conditions
s.t. FC1: bal[nPer-3] = 0;

minimize payment: minPay;

solve;

printf "Minimum Payment = %.2f\n", minPay;
table b {n in N} OUT "JSON" "Balance" "LineChart" : n, bal[n];
table p {n in 1..nPer} OUT "JSON" "Payments" "LineChart" : n, minPay, int[n], prn[n];

table a {n in N} OUT "JSON" "Balance" "Table" : n, minPay, int[n], prn[n], bal[n];

end;
