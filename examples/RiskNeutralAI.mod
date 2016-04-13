/* # Risk Neutral Analysis for American Idol

American Idol is a U.S. based televised singing competition in
    which the audience votes for their favorite contestant in the
    final rounds. Each week the contestant with the lowest votes
    is dropped until a winner emerges in the last week. The 
    intense interest in the singing competition has attracted
    the attention of third-party agents who offer an opportunity
    to bet on the eventual winner. Here we analyze a sample of the
    betting market to show just how bad an 'investment' it can be.

A typical betting agent will quote the payout for a $100
    on a particular contestant. Label the agent \(a\), the contestant
    \(c\), and the face value of the corresponding bet \(P_{c,a}(0)\) 
    (in this case $100). Let \(x_{c,a}\) denote the number of bets an
    investor places on contestant \(c\) with agent \(a\). The total
    cost to the investor is then
    \[w(0)=\sum_{c\in\cal{C}}\sum_{a\in\cal{A}}P_{c,a}(0)x_{c,a}\]
    The payout of a bet with agent \(a\) at the end of the contest is
    \(P_{c,a}(1)\) if contestant \(c\) wins, otherwise the payout is 
    zero. 

A risk neutral investor seeks a betting strategy offering a
    risk-free return under all outcomes, that is
    \[\sum_{a\in\cal{A}}P_{c,a}(1)x_{c,a} \geq (1+r_f)w(0) \qquad 
    \forall c\in\cal{C} \]
    where \(r_f\) is the risk free return. Later we'll see that
    betting agents prefer to keep profits to themselves, and that
    the maximum value for \(r_f\) is generally negative. That will
    be the unavoidable cost of participating in the betting markets.

Substitution yields
    \[(1+r_f)\sum_{c\in\cal{C}}\sum_{a\in\cal{A}}P_{c,a}(0)x_{c,a} 
    - \sum_{a\in\cal{A}}P_{c,a}(1)x_{c,a} \leq 0 \qquad \forall 
    c\in\cal{C}\]
    Gordan's theorem (a version of Farka's lemma) tells us either
    \(Ax < 0\) has a solution \(x\) or else \(y^TA = 0\) has a solution
    \(y\geq 0\). 

We introduce variables \(y_c \geq 0\) such that
    \[(1+r_f)\]\sum_{c\in\cal{C}}
    
    <h3>Risk Neutral Analysis for American Idol</h3>
<p>
    American Idol is a U.S. based televised singing competition in
    which the audience votes for their favorite contestant in the
    final rounds. Each week the contestant with the lowest votes
    is dropped until a winner emerges in the last week. The 
    intense interest in the singing competition has attracted
    the attention of third-party agents who offer an opportunity
    to bet on the eventual winner. Here we analyze a sample of the
    betting market to show just how bad an 'investment' it can be.
</p>
<p>
    A typical betting agent will quote the payout for a $100
    on a particular contestant. Label the agent \(a\), the contestant
    \(c\), and the face value of the corresponding bet \(P_{c,a}(0)\) 
    (in this case $100). Let \(x_{c,a}\) denote the number of bets an
    investor places on contestant \(c\) with agent \(a\). The total
    cost to the investor is then
    \[w(0)=\sum_{c\in\cal{C}}\sum_{a\in\cal{A}}P_{c,a}(0)x_{c,a}\]
    The payout of a bet with agent \(a\) at the end of the contest is
    \(P_{c,a}(1)\) if contestant \(c\) wins, otherwise the payout is 
    zero. 
</p>
<p>
    A risk neutral investor seeks a betting strategy offering a
    risk-free return under all outcomes, that is
    \[\sum_{a\in\cal{A}}P_{c,a}(1)x_{c,a} \geq (1+r_f)w(0) \qquad 
    \forall c\in\cal{C} \]
    where \(r_f\) is the risk free return. Later we'll see that
    betting agents prefer to keep profits to themselves, and that
    the maximum value for \(r_f\) is generally negative. That will
    be the unavoidable cost of participating in the betting markets.
</p>
<p>
    Substitution yields
    \[(1+r_f)\sum_{c\in\cal{C}}\sum_{a\in\cal{A}}P_{c,a}(0)x_{c,a} 
    - \sum_{a\in\cal{A}}P_{c,a}(1)x_{c,a} \leq 0 \qquad \forall 
    c\in\cal{C}\]
    Gordan's theorem (a version of Farka's lemma) tells us either
    \(Ax < 0\) has a solution \(x\) or else \(y^TA = 0\) has a solution
    \(y\geq 0\). 
*/

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
