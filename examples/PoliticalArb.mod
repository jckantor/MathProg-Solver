/* # Arbitrage in Political Prediction Markets

 An arbitrage is an opportunity for an investor to allocate money 
 among set of investments such that there is non-negative return for all
 outcomes. This situation is demonstrated below using data collected on
 September 27, 2008 at 10:30am EST for in 2008 US Presidential Election
 prediction markets. The outcomes, which are assumed to exhaust all 
 possibilities, are:
 
      1 The Democratic Party Candidate wins the U.S. Election
      2 The Republican Party Candidate wins the U.S. Election
      
 Prices and payouts are gathered for these outcomes from three markets:

      1 Intrade (Buy price for a $10 pay out) 
      2 IEM (Ask price for $1 pay out)
      3 Betfair (Odds less 5% commission on winnings for a $1 bet)
      
 Prices and payoffs are net of any transaction or trading costs.
*/

# Data
set CONTRACTS dimen 2;
param price{CONTRACTS};
param payout{CONTRACTS};

# Exact markets and events from set of contracts
set MARKETS := setof {(m,e) in CONTRACTS} m;
set EVENTS := setof {(m,e) in CONTRACTS} e;

# The decision variables are the amount invested in each contract.
# The non-negativity condition means no shorting is allowed.
var x{CONTRACTS} >= 0;

# The total investment is limited to $1,000
s.t. investment : sum{(m,e) in CONTRACTS} price[m,e]*x[m,e] <= 1000;

# The objective is maximize the worst-case payout
var minpayout >= 0;
s.t. arbitrage {e in EVENTS} : sum {m in MARKETS} payout[m,e]*x[m,e] >= minpayout;

maximize obj: minpayout;

solve;

printf "Market     Contract           Price  Payout   Units    Cost   Payout\n"
    >> 'Summary for a $1,000 Investment';
printf "------     --------           -----  ------   -----    ----   ------\n"
    >> 'Summary for a $1,000 Investment';
printf {(m,e) in CONTRACTS} 
    "%-10s %-16s  %6.2f  %6.2f  %6.2f  %6.2f %8.2f\n",
    m, e, price[m,e], payout[m,e], x[m,e], price[m,e]*x[m,e], 
    payout[m,e]*x[m,e] >> 'Summary for a $1,000 Investment';
    
table tout {(m,e) in CONTRACTS : x[m,e] > 0} OUT "GCHART" "Arbitrage" "PieChart" : 
    (m&"-"&e)~Contract,
    x[m,e];

data;

param : CONTRACTS :                 price  payout :=
    Intrade    'Democrat Wins'       5.59   10.00
    Intrade    'Republican Wins'     4.30   10.00
    IEM        'Democrat Wins'       0.64    1.00
    IEM        'Republican Wins'     0.36    1.00
    Betfair    'Democrat Wins'       1.00    1.48
    Betfair    'Republican Wins'     1.00    2.95
;

end;
