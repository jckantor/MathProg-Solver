/* Stoichiometry */

set STRMS := {"feed", "out"};
set UNITS := {"Mixer","Rctr"};
set COMPS := {"CH4","O2","CO","CO2","H2O"};

var n{COMPS,STRMS} >= 0;




end;
