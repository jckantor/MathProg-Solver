/* # Risk Neutral Analysis for _American Idol_

_American Idol_ was a singing competition televised in the United States from 2002 to 
2016 in which the television audience voted for their favorite contestant in the final 
rounds. Each week the contestant with the lowest number of votes was dropped until a 
winner emerged in the final episode. The intense interest in  the singing competition 
attracted the attention of third-party agents who offered an opportunity to bet on the 
eventual winner. Here we analyze a sample of the betting market from Season 12 of the 
show prior to the episode featureing the final nine singers.

## Model for Maximum Risk Free Return

A betting agent will quote the payout for a wager on a particular contestant. Label the 
agent \\(a\\), the contestant \\(c\\), and the amount wagered as \\(P_{c,a}(0)\\) 
(typically $100). Let \\(n_{c,a}\\) denote the number of bets an investor places on 
contestant \\(c\\) with agent \\(a\\). We assume the agents will only accept non-negative 
wagers (i.e., no 'shorting') so that \\(n_{c,x} \geq 0\\). The total cost to the investor 
is
    
\\[w(0)=\sum_{c\in C}\sum_{a\in A}P_{c,a}(0)n_{c,a}\\]

If contestant \\(c\\) eventually wins, the payout quoted by agent \\(a\\) is
\\(P_{c,a}(1)\\), otherwise the payout is zero. If contestant \\(c\\) wins then the 
payoff from all agents is

\\[\sum_{a \in A} P_{c,a}(1) n_{c,a}\\]

A risk neutral investor seeks a betting strategy offering a risk-free regardless of which 
contestant wins. For every contestant

\\[\sum_{a\in A} P_{c,a}(1)n_{c,a} > (1+r_f)w(0) \qquad \forall c\in C \\]

where \\(r_f\\) is the risk-free return. After substitution

\\[\sum_{a\in A} P_{c,a}(1)n_{c,a} > (1+r_f)\sum_{c\in C}\sum_{a\in A}P_{c,a}(0)n_{c,a} 
  \qquad \forall c\in C \\]

The notation is simplified by introducing a variable \\(x_{c,a} = P_{c,a}(0)n_{c,a}\\) 
equal to the value of the wager placed on contestant \\(c\\) with agent \\(a\\). Then  
defining the total relative return for a wager on contestant \\(c\\).

\\[p_{c,a} = \frac{P_{c,a}(1)}{P_{c,a}(0)}\\]

leaves an inequality for each contestant that reads

\\[\sum_{a \in A} p_{c,a} x_{c,a} - (1 + r_f)\sum_{c\in C}\sum_{a\in A} x_{c,a} > 0 
  \qquad \forall c\in C\\]
   
At this stage we have a set of linear inequalities in the non-negative variables \\
(x_{c,a}\\). Given data on payoffs, the total amount of money to wager, and a risk-free 
rate \\(r_f\\), we can try to compute a solution that provides a return higher than the 
risk-free rate. If such a solution exists then there exists an arbitrage opportunity.

## Farka's Lemma

Arbitrages, however, are rare. When they arise it is likely investors will exploit the 
situation thereby driving the market back to a new price/demand equilibrium. So rather 
than seek solutions to a problem where a solution isn't likely to exist, we change the 
formulation using a version of Farka's lemma. 

Consider two sets of linear inequalities, the first written

\\[A \gg 0\\]
\\[x \geq 0 \\]

where the matrix/vector notation \\(A \gg 0\\) means a strict inequality between 
corresponding elements of vector quantities, and the second written as

\\[ A^Ty \leq 0 \\]
\\[ y \geq 0\\]

Farka's lemma states that one or the other of these two sets has a feasible solution, but 
not both. Applying this result, an arbitrage does not exist if there are variables 
\\(y_c \geq 0\\) such that

\\[p_{c,a}y_c - (1 + r_f)\sum_{c \in C}y_c \leq 0 \qquad \forall a \in A, \forall c \in C\\]

## Solution for Maximum Risk-Free Return

It's easy to see that if \\(r_f\\) is large enough, then an aribitrage can't exist.  The
smallest value for which an arbitrage does not exist (therefore an upper bound on the
attainable risk-free return obtained by any betting strategy) is given by 

\\[\min_{y_c \geq 0} r_f\\]

subject to

\\[p_{c,a}y_c \leq  (1 + r_f) \qquad \forall a \in A, \forall c \in C\\]
\\[\sum_{c \in C}y_c = 1\\]

The parameters \\(y_c\\) can be interpreted as a risk-neutral probability for 
contestant \\(c\\) to win the competition. The actual order of finish is listed
below for contestants in Season 12 of _American Idol_, so you can see how well this
works.
*/

set AGENTS;
set CONTESTANTS;
param payout{CONTESTANTS,AGENTS};
param finish{CONTESTANTS};

var x{CONTESTANTS,AGENTS} >= 0;
var y{CONTESTANTS} >= 0;
var rf;

s.t. total: sum{c in CONTESTANTS, a in AGENTS} x[c,a] = 1;
s.t. return {c in CONTESTANTS} : sum{a in AGENTS} payout[c,a]*x[c,a] >= 100*(1 + rf);

s.t. prob : sum{c in CONTESTANTS} y[c] = 1;
s.t. noarb {c in CONTESTANTS, a in AGENTS} : (1+rf)*100 >= payout[c,a]*y[c];

minimize obj: rf;

solve;

printf "Maximum risk-free return = %7.4f\n\n", rf;

printf "%15s      %6s", "CONTESTANT", "y[c]";
printf {a in AGENTS} : "%14s", a;
printf "\n";

for {c in CONTESTANTS} {
	printf "%15s(%1d)   %6.3f",c, finish[c], y[c];
	printf {a in AGENTS} : "        %6.2f", 100*x[c,a];
    printf "\n";
}
printf "%15s      %6s", "TOTALS", " ";
for {a in AGENTS} : printf "        %6.2f", sum{c in CONTESTANTS} 100*x[c,a];
data;

set AGENTS := 
Diamond  
SportsBetting
Bovada
;

param : CONTESTANTS : finish := 
'Candice Glover'    1
'Angela Miller'     3
'Kree Harrison'     2
'Amber Holcomb'     4
'Janelle Arthur'    5
'Lazaro Arbos'      6
'Burnell Taylor'    7
'Devin Velez'       8
'Paul Jolley'       9
;

param payout :   Diamond  SportsBetting  Bovada :=
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
