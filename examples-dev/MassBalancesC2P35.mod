/* Problem 2.35 Murphy */

set STRMS := 1..5;
set COMPS := {"Solids","Water","Sugar"};

var m{COMPS,STRMS} >= 0;

/* Feed Composition Specifications */
s.t. cherries1: m["Solids",1] = 0.18*sum{c in COMPS} m[c,1];
s.t. cherries2: m["Water",1] = 0.82*sum{c in COMPS} m[c,1];
s.t. sugar: m["Sugar",2] = sum{c in COMPS} m[c,2];

/* Feed ratio specification */
s.t. recipe: m["Sugar",2] = 2 * sum{c in COMPS} m[c,1];

/* Production specification */
s.t. production: 10 = sum{c in COMPS} m[c,5];

/* Mass Balances */
s.t. mixer{c in COMPS}: 0 = m[c,1] + m[c,2] - m[c,3];
s.t. evaporator{c in COMPS}: 0 = m[c,3] - m[c,4] - m[c,5];

/* Evaporator Specification */
s.t. evapperf: m["Water",4] = (2/3)*m["Water",3];

/* Set all unspecified flows to zero */
minimize flow: sum{c in COMPS, s in STRMS} m[c,s];

solve;

printf "Feed Rate of Cherries = %6.2f lb/h\n", sum{c in COMPS} m[c,1];
printf "\n";

printf "             ";
printf {s in STRMS}: "Strm %2s    ", s;
printf "\n";
for {c in COMPS}: {
    printf "%8s  ", c;
    printf {s in STRMS} "%8.2f   ", m[c,s];
    printf "\n";
}

end;
