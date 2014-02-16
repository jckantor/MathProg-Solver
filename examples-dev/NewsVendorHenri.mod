# Example: Newsvendor.mod

/* Unit Price Data */
param r >= 0;                              # Price
param c >= 0;                              # Cost
param w >= 0;                              # Salvage value

/* Price data makes sense only if  Price > Cost > Salvage */
check: c <= r;
check: w <= c;

/* Probabilistic Demand Forecast */
set SCENS;                                 # Scenarios
param D{SCENS} >= 0;                       # Demand
param Pr{SCENS} >= 0;                      # Probability

/* Probabilities must sum to one. */
check: sum{k in SCENS} Pr[k] = 1;

/* Expected Demand */
param ExD := sum{k in SCENS} Pr[k]*D[k];

/* Lower Bound on Profit: Expected Value of the Mean Solution */
param EVM := -c*ExD + sum{k in SCENS} Pr[k]*(r*min(ExD,D[k])+w*max(ExD-D[k],0));

/* Upper Bound on Profit: Expected Value with Perfect Information */
param EVPI := sum{k in SCENS} Pr[k]*(r-c)*D[k];

/* Two Stage Stochastic Programming */
var x >= 0;                     # Stage 1 (Here and Now): Order Quqntity
var y{SCENS}>= 0;               # Stage 2 (Scenario Dep): Actual Sales
var ExProfit;                   # Expected Profit

/* Maximize Expected Profit */
maximize OBJ: ExProfit;

/* Goods sold are limited by the order quantities and the demand  */
s.t. PRFT: ExProfit = -c*x + sum{k in SCENS} Pr[k]*(r*y[k] + w*(x-y[k]));
s.t. SUPL {k in SCENS}: y[k] <= x;
s.t. DMND {k in SCENS}: y[k] <= D[k];

solve;

param html, symbolic, default "solution.html";

param header, symbolic, default """
<h4>%s</h5>
<table class="table table-condensed">
    <thead>
        <tr>
            <th>Scenario</th>
            <th>Prob</th>
            <th>Demand</th>
            <th>Order</th>
            <th>Sold</th>
            <th>Salvage</th>
            <th>Profit</th>
        </tr>
   </thead>
""";

param line, symbolic, default """
     <tr>
        <td>%s</td>
        <td>%.2f</td>
        <td>%.2f</td>
        <td>%.2f</td>
        <td>%.2f</td>
        <td>%.2f</td>
        <td>%.2f</td>
     </tr>
""";

param footer, symbolic, default """
        <tr class="info">
        <td>%s</td>
        <td/>
        <td>%.2f</td>
        <td>%.2f</td>
        <td>%.2f</td>
        <td>%.2f</td>
        <td>%.2f</td>
    </tr>
</table>
""";

# align col number on the right
printf """
<style>
    table td:not(:first-child),
    table th:not(:first-child)
    {text-align: right !important;}
</style>
""" >> html;

printf header, "Expected value of the mean solution" >> html;

printf {k in SCENS} line,
   k, Pr[k], D[k], ExD, min(ExD,D[k]), max(ExD-D[k],0),
   -c*ExD + r*min(ExD,D[k]) + w*max(ExD-D[k],0) >> html;

printf footer,
   'MEAN', ExD, ExD, sum{k in SCENS}Pr[k]*min(ExD,D[k]),
   sum{k in SCENS}Pr[k]*max(ExD-D[k],0),EVM >> html;

printf header, "Expected value with perfect information" >> html;

printf {k in SCENS} line,
   k, Pr[k], D[k], D[k], D[k], 0, -c*D[k] + r*D[k] >> html;
printf footer,
   'MEAN', ExD, ExD, ExD,0,EVPI >> html;

printf header, "Two stage stochastic programming" >> html;
printf {k in SCENS} line,
   k, Pr[k], D[k], x, y[k], x-y[k], -c*x + r*y[k] + w*(x-y[k]) >> html;
printf footer,
   'MEAN', ExD, x, sum{k in SCENS}Pr[k]*y[k],
   sum{k in SCENS}Pr[k]*(x-y[k]),ExProfit >> html;

printf """
    <ul>
        <li>Order Quantity = %g</li>
        <li>Expected Profit = %g</li>
        <li>Value of perfect information: %.2f</li>
        <li>Value of the stochastic solution: %.2f</li>
    </ul>
""",
x, ExProfit, EVPI - ExProfit, ExProfit - EVM >> html;

data;

/* Problem Data corresponds to a hypothetical case of selling programs prior 
to a home football game. */

param r := 10.00;                         # Unit Price
param c :=  6.00;                         # Unit Cost
param w :=  2.00;                         # Unit Salvage Value

param: SCENS:  Pr    D   :=
       HiDmd   0.25  250
       MiDmd   0.50  125
       LoDmd   0.25   75 ;

end;