/* # Expansion of Giapetto's Workshop */

# Decision variables
var x1 >=0 integer;  # soldier
var x2 >=0 integer;  # train
var F >= 0; # additional finishing labor
var C >= 0; # additional carpentry labor

# Objective function
maximize profit: 3*x1 + 2*x2;

# Constraints
s.t. Finishing: 1.85*x1 + x2 <= 100 + F;
s.t. Carpentry: x1 + x2 <= 80 + C;
s.t. Demand: x1 <= 40;
s.t. AdditionalLabor: F + C <= 20;  # bound on the amount of extra labor

solve;

printf "Additional Finishing Labor: %g\n", F;
printf "Additional Carpentry Labor: %g\n", C;
printf "Profit: %g\n", profit;

end;
