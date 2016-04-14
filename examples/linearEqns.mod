/* # Solving a System of Linear Equations

MathProg is a language for describing linear and discrete optimization problems.
A series of exercises described below will introduce MathProg by demonstrating 
how to solve to small system of linear equations.

Consider a set of three linear equations

\\[ 2x + y + z = 12\\]
\\[ x + 2y + z = 23 \\]
\\[ x + y + z = 10 \\]

in the three unknowns \\(x\\), \\(y\\), and \\(z\\).

To find a solution with MathProg you need to create a description of the problem.
For this case the description consists of

1. a description of the variables, 
2. a description of the equations,
3. additional keywords indicating the desired actions, and 
4. comments necessary for someone to understand the description. 

These points are demonstrated in the MathProg model shown below. 

Note the following points as you examine this model &mdash;

* The hashtags denote comments. Anything following the hashtag on the same line is ignored by MathProg.
* Semicolons separate statements in MathProg. A MathProg statement may continue over several lines.
* The statements starting with the keyword `var` describe variables appearing in the problem. There is a separate line for each variable.
* The next group of statements describe equations appearing in the problem. Each statement begins with a name of an equation separated by a colon from the equation itself. The equations are written in standard computer notation. Each equation must have a name.
* The keyword `solve` indicates a solution is to be computed.
* The keyword `end` indicates completion of the problem description.

Here are a few exercises to try 

1. Click the Solve button underneath the editor. Locate the solution for \\(x\\),
\\(y\\), and \\(z\\) in the tab labeled 'Variables'. In the constraints tab locate
the solution for each equation.
2. Change the equations. Explore how the solution changes depends on equation
parameters. See what happens when two of the equations are identical.
3. The Wikipedia page [Systems of Linear Equations](http://en.wikipedia.org/wiki/System_of_linear_equations) showes some example problems. Click `New Model`, then write a MathProg model from scratch to solve one of the examples.
*/



# List the variables
var x;
var y;
var z;

# List the equations
Eq1:  2*x +   y +  z = 12;
Eq2:    x + 2*y +  z = 23;
Eq3:    x +   y +  z = 10;

# Solve
solve;

end;