
# Given Data
param xLB  :=  2;
param xUB  := 10;

set X := -1..xUB by 0.01;


var a{X} binary;
var b{X} binary;


# Linearize a*b*x by substituting z where
var z{X};
s.t. A{x in X}: z[x] <= a[x]*xUB;
s.t. B{x in X}: z[x] <= b[x]*xUB;
s.t. C{x in X}: z[x] >= a[x]*xLB;
s.t. D{x in X}: z[x] >= b[x]*xLB;

# Demonstration
minimize obj: sum{x in X} z[x];
s.t. E{x in X}: z[x] >= x;

solve;

# Visualization
table plot {x in X} OUT "GCHART" "Linearization of z = a*b*x" "LineChart" : x, z[x], a[x], b[x];

end;
