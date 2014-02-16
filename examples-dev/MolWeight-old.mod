
set SPECIES;
param MW{SPECIES};

printf {s in SPECIES}: "%s  %6.2f\n", s, MW[s];

data;

param: SPECIES : MW :=

CH4   16.1
H2O  18.0;



end;
