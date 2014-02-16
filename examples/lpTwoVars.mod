# Example: lpTwoVars.mod  Solution to Linear Program in Two Variables 

# Define Variables
var x;
var y;

# Define Constraints
s.t. A: x + 2*y <= 14;
s.t. B: 3*x - y >= 0;
s.t. C: x - y <= 2;

# Define Objective
maximize z: 3*x + 4*y;

# Solve
solve;
end;