# Example: DataReconciliation.mod

/* Sets */
set STREAMS;
set SENSORS;
set UNITS;

/* Mass Balances  Coefficients */
param A{UNITS,STREAMS} default 0;

/* Sensors Parameters */
param y{SENSORS} >= 0;        # Measurement Data
param s{SENSORS}  > 0;        # Stream measured by each sensor
param emax{SENSORS} >= 0;     # Bound on error for each sensor
param bigM := 100;            # Big M

/* Stream Variables */
var x{STREAMS} >= 0;

/* Sensor Variables */
var epos{SENSORS} >= 0;
var eneg{SENSORS} >= 0;
var gerr{SENSORS} binary;     # Gross Errors

/* Optimization Criterion */
minimize L1: sum {k in SENSORS} (epos[k]+eneg[k] + bigM*gerr[k]);

/* Mass Balances */
s.t. MASSBAL {i in UNITS}: sum{j in STREAMS} A[i,j]*x[j] = 0;

/* Error Model */
s.t. s_err {k in SENSORS}: y[k] =  x[s[k]] + epos[k] - eneg[k];
s.t. e_pos {k in SENSORS}: epos[k] <= emax[k] + bigM*gerr[k];
s.t. e_neg {k in SENSORS}: eneg[k] <= emax[k] + bigM*gerr[k];

/* Solve and Display Solution */
solve;

printf "Measurement Reconciliation";
printf "\n\n   Sensor    Measured     Reconciled    Difference    GrossError";
for {k in SENSORS}{
   printf "\n      %s      %7.2f       %7.2f      %7.2f",
      k,y[k],x[s[k]],(epos[k]-eneg[k]),gerr[k];
   printf "         %3s", if gerr[k]=1 then "X" else " ";
}
printf "\n\n\nStream Estimates";
printf "\n\n   Stream    Estimate";
printf {i in STREAMS} "\n      %s      %7.2f",i,x[i];

table tab1 {k in SENSORS} OUT "JSON" "Measurement Reconciliation" "ColumnChart":
    k~Sensor,
    y[k]~Measurement,
    x[s[k]]~Reconciled;

table tab2 {k in SENSORS} OUT "JSON" "Measurement Error" "ColumnChart":
    k~Sensor,
    (epos[k]-eneg[k])~Error;

data;

/* All of the relevant sensor information is given in the data section. The
relevant information includes the number of sensors, and a table indexed by 
sensor number k with information on which stream is measured (s[k]), the 
measurement (y[k]), and  'no-penalty' range for measurement errors (emax[k]). 
*/

set UNITS := SPLIT HTEXG VALVE MIXER;
set STREAMS := 1 2 3 4 5 6;

/* Mass Balance Coefficients */
param  A :
            1   2   3   4   5   6  :=
   SPLIT   -1   1   1   .   .   .
   HTEXG    .  -1   .   1   .   .
   VALVE    .   .  -1   .   1   .
   MIXER    .   .   .   1   1  -1 ;

/* Sensors and Measurement Data*/
param: SENSORS:   s      y     emax :=    
          1       1   101.91   1.75
          2       2    68.45   1.75
          3       4    64.20   1.75
          4       5    36.44   1.75
          5       6    98.88   1.75 ;

end;