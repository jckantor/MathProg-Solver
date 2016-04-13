/* 
# Giapetto's Workshop

Find the optimal solution maximizing Giapetto's profit.
*/

# Decision variables
var x1 >=0 integer;  # soldier
var x2 >=0 integer;  # train

# Objective function
maximize profit: 3*x1 + 2*x2;

# Constraints
s.t. Finishing: 2*x1 + x2 <= 100;
s.t. Carpentry: x1 + x2 <= 80;
s.t. Demand: x1 <= 40;

solve;

display x1, x2, profit;
display Finishing, Carpentry, Demand;

end;

