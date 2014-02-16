/* Change for a dollar */

set COINS;
param values{COINS} > 0;

data;

param : COINS : values :=
    Half     0.50
    Quarter  0.25
    Dime     0.10
    Nickel   0.05
    Penny    0.01
;

end;
