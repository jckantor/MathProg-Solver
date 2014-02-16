set LOANS;

param amt{LOANS} >= 0;
param aRate{LOANS} >= 0;
param months{LOANS} >= 1;
param minPay{LOANS} >= 0;

param N;




data;

param N := 240;

param : LOANS :         amt     aRate   months    minPay :=
        Home      103410.21     4.875       78      1565
        Cabin     201096.11     4.625      138      1800
        Equity     82530.42     2.75       360       180 ;

end;