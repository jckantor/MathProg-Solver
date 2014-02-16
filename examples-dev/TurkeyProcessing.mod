
set BIRDS;
set RAWMEATS;
set PROCESSES;

param yield{PROCESSES,RAWMEATS};
param sales{RAWMEATS};

var x{BIRDS,PROCESSES} >= 0;

s.t. S{r in RAWMEATS}: sum{p in PROCESSES, b in BIRDS} yield[p,r]*x[b,p] >= sales[r];
s.t. a1: x["Type_2","P1"] = 0;
s.t. a2: x["Type_2","P1"] = 0;
s.t. a3: x["Type_1","P2"] = 0;

minimize obj: sum{b in BIRDS, p in PROCESSES} x[b,p];
solve;

printf "        ";
printf {p in PROCESSES}: "  %8s", p;
printf "\n";
for {b in BIRDS} : {
    printf "%8s", b;
    printf {p in PROCESSES} : "  %8.2f", x[b,p];
    printf "\n";
}
data;

set BIRDS := Type_1 Type_2;
set RAWMEATS := RM1 RM2 RM3 RM4;
set PROCESSES := P1 P2 P3 P4;

param yield : 
          RM1    RM2   RM3    RM4:=
    P1    0.3    0.7   0.0    0.0
    P2    0.0    0.9   0.1    0.0 
    P3    0.6    0.0   0.0    0.4
    P4    0.8    0.1   0.3    0.1 ;
    
param sales :=
    RM1    500
    RM2    300 
    RM3    800
    RM4   1000 ;

end;