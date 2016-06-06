/* 
# Making Change

This `MathProg` model provides a simple demonstration of integer programming. The task is to 
find the minimum number of coins needed to represent a specified amount of money \\(a\\). The 
relevant constraint is

\\[ a = \sum_{c=1}^C v_c x_c\\]

where the sum is over the set of \\(C\\) possible coin types, \\(v_c\\) is the value of coin
type \\(c\\), and \\(x_c\\) is the number of coins of type \\(c\\).

*/

set COINS;
param values{COINS} > 0;
param amount >= 0;

var x{COINS} integer, >= 0;

subject to total : amount = sum{c in COINS} values[c]*x[c];

minimize number_of_coins : sum{c in COINS} x[c];

solve;

printf "Change for $%-5.2f: \n", amount;
printf {c in COINS : x[c] > 0} : "\t%d %s\n", x[c], c;

data;

param amount := 0.94;

param : COINS : values :=
    Half     0.50
    Quarter  0.25
    Dime     0.10
    Nickel   0.05
    Penny    0.01
;

end;
