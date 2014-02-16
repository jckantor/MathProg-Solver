# American Idol Arbitrage

set AGENTS;
set CONTESTANTS;
param payout{CONTESTANTS,AGENTS};

var x{CONTESTANTS,AGENTS} >= 0;
var y{CONTESTANTS} >= 0;
var rf;

s.t. prob : sum{c in CONTESTANTS} y[c] = 1;
s.t. noarb {c in CONTESTANTS, a in AGENTS} : (1+rf)*100 <= payout[c,a]*y[c];

maximize obj: rf;

solve;

table tout {c in CONTESTANTS} OUT "GCHART" "Amounts" "Table" : 
    c~Contestent,
    y[c]~Probability;
    
table tout {c in CONTESTANTS} OUT "GCHART" "Amounts" "PieChart" :   c~Contestant,
    y[c]~Probability;


data;

set AGENTS := 
Diamond  
SportsbettingOnline  
Bovada
;

set CONTESTANTS := 
'Candice Glover'
'Angela Miller'
'Kree Harrison'
'Janelle Arthur'
'Lazaro Arbos'
'Amber Holcomb'
'Paul Jolley'
'Burnell Taylor'
'Devin Velez'
;

param payout :   Diamond  SportsbettingOnline  Bovada :=
'Candice Glover'     115      190      200
'Angela Miller'      125      180      225
'Kree Harrison'      230      180      275
'Janelle Arthur'    1100     1150     1200
'Lazaro Arbos'      1100      950     1400
'Amber Holcomb'     1100      800     1200
'Paul Jolley'       2800     4000     3300
'Burnell Taylor'    2100     2500     2500
'Devin Velez'       2600     3500     3300
;

end;
