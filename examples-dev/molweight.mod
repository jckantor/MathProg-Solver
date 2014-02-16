# Computing Molecular Weights

set ATOMS;
set SPECIES;
set REACTIONS;

param amu{ATOMS};
param name{SPECIES} symbolic;
param formula{SPECIES,ATOMS};
param stoich{SPECIES,REACTIONS};

param mw{s in SPECIES} := sum{a in ATOMS} amu[a]*formula[s,a];

printf {s in SPECIES}: "%-10s   %8.4f\n", s, mw[s];
table tab1 {s in SPECIES} OUT "JSON" "Table" : name[s], s~Species, mw[s];

data;

param : ATOMS : amu :=
    H     1.0079
    C    12.011
    N    14.0067
    O    15.99994 
    S    32.06 ;

param : SPECIES : name := 
    CH4   Methane
    CO    Carbon_Monoxide
    CO2   Carbon_Dioxide
    H2    Hydrogen
    H2O   Water
    O2    Oxygen ;

param formula default 0:
          C   H   O   N   S :=
    CH4   1   4   .   .   .
    CO    1   .   1   .   .
    CO2   1   .   2   .   .
    H2    .   2   .   .   .
    H2O   0   2   1   .   . 
    O2    .   .   2   .   . ;
    
set REACTIONS := R1 R2 R3;

param stoich default 0:
          R1   R2   R3 :=
    CH4   -1   -1    .
    CO     .    1    . ;

end;