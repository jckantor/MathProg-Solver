/* # Linear Program in Two Variables

Write a MathProg model to find the maximum value of \\(z=3x + 4y\\) 
subject to the following set of constraints

\\[x + 2y  \leq 14 \\]
\\[3x - y  \geq 0 \\]
\\[x - y  \leq 2 \\]
    
The maximum value of \\(z\\) is 34.  What are the corresponding values of 
\\(x\\) and \\(y\\)? What is the minimum value of \\(z\\)?
*/

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