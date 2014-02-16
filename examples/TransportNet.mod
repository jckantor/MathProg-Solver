# Example: TransportNet.mod

/* Model  Section */

set SOURCES;
set CUSTOMERS;

param Demand {CUSTOMERS} >= 0;
param Supply {SOURCES}   >= 0;
param Tcost {CUSTOMERS, SOURCES} default 1000;

var x {CUSTOMERS, SOURCES} >= 0;

/* Minimize total shipping costs */
minimize Cost: sum{c in CUSTOMERS, s in SOURCES} Tcost[c,s]*x[c,s];

/* Total shipped from each source must be less than source capacity */
s.t. SRC {s in SOURCES}: sum {c in CUSTOMERS} x[c,s] <= Supply[s];

/*  Total received must equal customer demand */
s.t. DST {c in CUSTOMERS}: sum {s in SOURCES} x[c,s] = Demand[c];

solve;

data;
/* 
Problem Data from Chapter 5 of Johannes Bisschop, "AIMMS Optimization Modeling",
Paragon Decision Sciences, 1999. The following data details supply, demand, and
shipping costs among a set of 8 European cities
*/

param: CUSTOMERS: Demand :=
   Lon   125        # London
   Ber   175        # Berlin
   Maa   225        # Maastricht
   Ams   250        # Amsterdam
   Utr   225        # Utrecht
   Hag   200 ;      # The Hague

param: SOURCES: Supply :=
   Arn   550        # Arnhem
   Gou   650 ;      # Gouda

param Tcost : Arn   Gou :=
   Lon        .    2.5
   Ber       2.5    .
   Maa       1.6   2.0
   Ams       1.4   1.0
   Utr       0.8   1.0
   Hag       1.4   0.8 ;

end;