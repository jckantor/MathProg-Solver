/* Cloud Balancing 
http://docs.jboss.org/drools/release/5.4.0.Final/drools-planner-docs/html_single/#d0e1094
*/

set PROCESSES;
param Pcpu{PROCESSES};
param Pmem{PROCESSES};
param Pnbw{PROCESSES};

set COMPUTERS;
param Ccpu{COMPUTERS};
param Cmem{COMPUTERS};
param Cnbw{COMPUTERS};
param Ccst{COMPUTERS};

var x{COMPUTERS,PROCESSES} binary;

s.t. assign {p in PROCESSES} : sum {c in COMPUTERS} x[c,p] <= 1;
s.t. cpu {c in COMPUTERS} : sum {p in PROCESSES} x[c,p]*Pcpu[p] <= Ccpu[c];
s.t. mem {c in COMPUTERS} : sum {p in PROCESSES} x[c,p]*Pmem[p] <= Cmem[c];

maximize score : sum{c in COMPUTERS, p in PROCESSES} x[c,p];

solve;

data;

param : PROCESSES : Pcpu  Pmem  Pnbw :=
    A    5   5  0
    B    4   3  0
    C    2   3   0
    D    2   1   0
;

param : COMPUTERS : Ccpu  Cmem Cnbw :=
    X    7   6  0
    Y    6   6  0
;

end;
