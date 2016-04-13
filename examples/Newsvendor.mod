/* # The Newsvendor Problem

The newsvendor problem is a two stage decision problem with recourse. The 
    vendor needs to decide how much inventory to order today to fulfill an 
    uncertain demand. The data includes the unit cost, price, and salvage value of 
    the product being sold, and a probabilistic forecast of demand. The objective 
    is to maximize expected profit.

As shown in lecture, this problem can be solved with a plot, and the solution
    interpreted in terms of a cumulative probability distribution. The advantage
    of a MathProg model is that additional constraints or other criteria may be 
    considered, such as risk aversion.

There is an extensive literature on the newsvendor problem which has been 
    studied since at least 1888. See 
    <a rel="external" href="http://www.isye.umn.edu/courses/ie5551/additional%20materials/newsvendort.pdf">here</a> for a thorough discussion.
*/

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

table Table_EVM {k in SCENS} OUT "JSON" "Expected Value for the Mean Scenario" "Table":
   k~Scenario,
   Pr[k]~Probability, 
   D[k]~Demand, 
   ExD~Order, 
   min(ExD,D[k])~Sold,
   max(ExD-D[k],0)~Salvage, 
   -c*ExD + r*min(ExD,D[k]) + w*max(ExD-D[k],0)~Profit;
   
table Table_EVPI {k in SCENS} OUT "JSON" "Expected Value of Perfect Information" "Table":
   k~Scenario,
   Pr[k]~Probability, 
   D[k]~Demand, 
   D[k]~Order, 
   D[k]~Sold,
   0~Salvage, 
   -c*D[k] + r*D[k]~Profit;
   
table Table_SP {k in SCENS} OUT "JSON" "Expected Value by Stochastic Programming" "Table":
   k~Scenario,
   Pr[k]~Probability, 
   D[k]~Demand, 
   x~Order, 
   y[k]~Sold,
   x-y[k]~Salvage, 
   -c*x + r*y[k] + w*(x-y[k])~Profit;
   
table Summary {k in 1..1} OUT "JSON" "Summary" "Table":
   EVPI-ExProfit~Value_of_Perfect_Information,
   ExProfit - EVM~Value_of_Stochastic_Solution; 

printf "EXPECTED VALUE OF THE MEAN SOLUTION\n" >> "EVM";
printf "\nSCENARIO     PROB   DEMAND    ORDER     SOLD  SALVAGE   PROFIT\n" >> "EVM";
printf {k in SCENS} "%s     %7.2f  %7.2f  %7.2f  %7.2f  %7.2f  %7.2f\n",
   k, Pr[k], D[k], ExD, min(ExD,D[k]), max(ExD-D[k],0), 
   -c*ExD + r*min(ExD,D[k]) + w*max(ExD-D[k],0) >> "EVM";
printf "\n%s               %7.2f  %7.2f  %7.2f  %7.2f  %7.2f\n",
   'MEAN', ExD, ExD, sum{k in SCENS}Pr[k]*min(ExD,D[k]),
   sum{k in SCENS}Pr[k]*max(ExD-D[k],0),EVM >> "EVM";

printf "EXPECTED VALUE WITH PERFECT INFORMATION\n" >> "EVPI";
printf "\nSCENARIO     PROB   DEMAND    ORDER     SOLD  SALVAGE   PROFIT\n" >> "EVPI";
printf {k in SCENS} "%s     %7.2f  %7.2f  %7.2f  %7.2f  %7.2f  %7.2f\n",
   k, Pr[k], D[k], D[k], D[k], 0, -c*D[k] + r*D[k] >> "EVPI";
printf "\n%s               %7.2f  %7.2f  %7.2f  %7.2f  %7.2f\n",
   'MEAN', ExD, ExD, ExD,0,EVPI >> "EVPI";

printf "TWO STAGE STOCHASTIC PROGRAMMING\n\n" >> "SP";
printf " Order Quantity = %g\n", x >> "SP";
printf "Expected Profit = %g\n", ExProfit >> "SP";
printf "\nSCENARIO     PROB   DEMAND    ORDER     SOLD  SALVAGE   PROFIT\n" >> "SP";
printf {k in SCENS} "%s     %7.2f  %7.2f  %7.2f  %7.2f  %7.2f  %7.2f\n",
   k, Pr[k], D[k], x, y[k], x-y[k], -c*x + r*y[k] + w*(x-y[k]) >> "SP";
printf "\n%s               %7.2f  %7.2f  %7.2f  %7.2f  %7.2f\n",
   'MEAN', ExD, x, sum{k in SCENS}Pr[k]*y[k],
   sum{k in SCENS}Pr[k]*(x-y[k]),ExProfit >> "SP";

printf "    VALUE OF PERFECT INFORMATION = %7.2f\n",EVPI-ExProfit >> "Summary";
printf "VALUE OF THE STOCHASTIC SOLUTION = %7.2f\n",ExProfit - EVM >> "Summary"; 

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