# Vehicle Routing Problem with Time Windows

set PLACES;
param lat{PLACES};
param lng{PLACES};
param start symbolic;
param finish symbolic;

param S1{PLACES};
param S2{p in PLACES} >= S1[p];

set PLANES;
param sloc{PLANES} symbolic;
param floc{PLANES} symbolic;
param T1{PLANES};
param T2{PLANES};

# compute great circle distances
param minspeed;
param maxspeed;
param d2r := 3.1415926/180;
param alpha{a in PLACES, b in PLACES} := sin(d2r*(lat[a]-lat[b])/2)**2 
      + cos(d2r*lat[a])*cos(d2r*lat[b])*sin(d2r*(lng[a]-lng[b])/2)**2;
param gcdist{a in PLACES, b in PLACES} := 2*6371*atan(sqrt(alpha[a,b]),sqrt(1-alpha[a,b]));

# Path constraints
var x{PLANES, PLACES, PLACES} binary;

# must leave from all nodes except the finish node
s.t. lv1 {a in PLACES : a != floc[p]}: sum{p in PLANES, b in PLACES: } x[p,a,b] = 1;
s.t. lv2 {p in PLANES}: sum{b in PLACES} x[p,floc[p],b] = 0;

# must arrive at all places except the start node
s.t. ar1 {a in PLACES : a != start}: sum{b in PLACES} x[b,a] = 1;
s.t. ar2 : sum{b in PLACES} x[b,start] = 0;

# subtour elimination using an idea from Andrew O. Makhorin
var y{PLANES, PLACES, PLACES} >= 0, integer;
s.t. capbnd {a in PLACES, b in PLACES} : y[a,b] <= (card(PLACES)-1)*x[a,b];
s.t. capcon {a in PLACES} : sum{b in PLACES} y[b,a] 
         + (if a=start then card(PLACES)) = 1 + sum{b in PLACES} y[a,b];

# Time Constraints
param bigM := 50;
var tar{PLANES,PLACES};         # arrival
var tlv{PLANES,PLACES};         # departure
var tea{PLANES,PLACES} >= 0;    # early arrival
var tla{PLANES,PLACES} >= 0;    # late arrival
var ted{PLANES,PLACES} >= 0;    # early departure
var tld{PLANES,PLACES} >= 0;    # late departure

s.t. t1 {p in PLANES, a in PLACES} : tlv[p,a] >= tar[p,a]; 
s.t. t2 {pa in PLACES, b in PLACES} : 
    tar[p,b] >= tlv[p,a] + gcdist[a,b]/maxspeed - bigM*(1-x[p,a,b]);
s.t. t3 {p in PLANES, a in PLACES, b in PLACES} : 
    tar[p,b] <= tlv[p,a] + gcdist[a,b]/minspeed + bigM*(1-x[p,a,b]);
s.t. t4 {p in PLANES, a in PLACES} : tea[p,a] >= S1[a] - tar[p,a];   # early arrival
s.t. t5 {p in PLANES, a in PLACES} : tla[p,a] >= tar[p,a] - S2[a];   # late arrival
s.t. t6 {p in PLANES, a in PLACES} : ted[p,a] >= S1[a] - tlv[p,a];   # early departure
s.t. t7 {p in PLANES, a in PLACES} : tld[p,a] >= tlv[p,a] - S2[a];   # late departure

minimize obj: sum{p in PLANES, a in PLACES} (tea[p,a] + tla[p,a] + ted[p,a] + tld[p,a]);

solve;

printf "%6s  %6s  %6s  %6s  %6s  %6s  %6s  %6s  %6s  %6s  %6s\n", 
    'Depart', 'at', 'Arrive', 'at','T_ED','T_LD','T_EA','T_LA','Dist','Time','Speed';

for {k in card(PLACES)-1..0 by -1} {
    printf {a in PLACES, b in PLACES : (y[p,a,b]=k) && (x[p,a,b]=1)}
        "%6s  %6.2f  %6s  %6.2f  %6.2f  %6.2f  %6.2f  %6.2f  %6.1f  %6.2f  %6.1f\n", 
        a, tlv[a], b, tar[b], ted[a], tld[a], tea[b], tla[b], gcdist[a,b],
        (tar[b]-tlv[a]), gcdist[a,b]/(tar[b]-tlv[a]);
}

data;

param start := 'ATL';
param finish := 'ORD';
param minspeed := 800;
param maxspeed := 900;

param : PLACES :         lat            lng       S1       S2 :=
        ATL       33.6366995    -84.4278639      8.0     24.0
        BOS       42.3629722    -71.0064167      8.0      9.0
        DEN       39.8616667   -104.6731667     12.0     15.0
        DFW       32.8968281    -97.0379958     12.0     13.0
        JFK       40.6397511    -73.7789256     18.0     20.0
        LAX       33.9424955   -118.4080684     12.0     16.0
        ORD       41.9816486    -87.9066714     20.0     24.0
        STL       38.7486972    -90.3700289     11.0     13.0
; 

param : PLANES :  sloc   floc   T1    T2:=
       N0001      ATL    ORD    8.0   24.0
       N0002      STL    DEN    8.0   24.0
;

end;
