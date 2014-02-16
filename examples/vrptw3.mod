# Vehicle Routing Problem with Time Windows

# set of locations
set LOCATIONS;
param lat{LOCATIONS};
param lng{LOCATIONS};

# schedule is a set of name,loc pairs 
set SCHEDULE dimen 2;
param T1{SCHEDULE};
param T2{SCHEDULE};

# start is a set of plane,loc pairs
set START dimen 2;
param S1{START};
param S2{START};

# finish is a set of plane, loc pairs
set FINISH dimen 2;
param F1{FINISH};
param F2{FINISH};

# create set of planes
set P := setof {(p,loc) in START} p;

# create set of all nodes
set N := SCHEDULE union (START union FINISH);
printf {(name,loc) in N} "%-6s %-3s\n", name, loc;


# x[p,a,aLoc,b,bLoc] = 1 if plane p flies from (a,aLoc) to (b,bLoc)
var x{P, N, N} binary;

# start and finish constraints

# no planes arrive at the start nodes
s.t. sf1 {p in P, (a,aLoc) in  N, (b,bLoc) in START} : x[p,a,aLoc,b,bLoc] = 0;

# no planes leave the finish nodes
s.t. sf2 {p in P, (a,aLoc) in FINISH, (b,bLoc) in N} : x[p,a,aLoc,b,bLoc] = 0;

# planes must leave from their own start nodes
s.t. sf3 {p in P, (a,aLoc) in START, (b,bLoc) in N : p != a} : x[p,a,aLoc,b,bLoc] = 0;

# planes must return to their own finish nodes
s.t. sf4 {p in P, (a,aLoc) in N, (b,bLoc) in FINISH : p != b} : x[p,a,aLoc,b,bLoc] = 0;

# network constraints

# one plane arrives at each schedule and finish node
s.t. ar1 {(b,bLoc) in (SCHEDULE union FINISH)} : 
        sum {p in P, (a,aLoc) in (SCHEDULE union START)} x[p,a,aLoc,b,bLoc] = 1;

# one plane leaves each start and schedule node
s.t. lv1 {(a,aLoc) in (START union SCHEDULE)} :
        sum {p in P, (b,bLoc) in (SCHEDULE union FINISH)} x[p,a,aLoc,b,bLoc] = 1;






# 
#s.t. ar3 {p in P, (b,bLoc) in FINISH : p = b} : 
#        sum{(a,aLoc) in (SCHEDULE union START)} x[p,a,aLoc,b,bLoc] = 1;

solve;

printf {p in P, (a,aLoc) in N, (b,bLoc) in N : x[p,a,aLoc,b,bLoc] = 1} 
    "Plane %-6s  Depart %-6s  %-3s  Arrive %-6s  %-3s\n",p,a,aLoc,b,bLoc;

/*

# create schedule nodes for start and finish locations for each plane
set S := setof {(plane,sLoc,fLoc) in PLANES} (plane,sLoc);
set F := setof {(plane,sLoc,fLoc) in PLANES} (plane,fLoc);
param Ts{(plane,sLoc) in S} := max {(plane,sLoc,fLoc) in PLANES} S1[plane,sLoc,fLoc];
param Tf{(plane,fLoc) in F} := min {(plane,sLoc,fLoc) in PLANES} S2[plane,sLoc,fLoc];

# create set of all nodes
set N := SCHEDULE union (START union FINISH);
set P := setof {(plane,sLoc,fLoc) in PLANES} plane;



/*


s.t. lv1 {p in P, (a,aloc) in N, (b, bloc) in N} : x


/*
# compute great circle distances
param minspeed;
param maxspeed; 
param d2r := 3.1415926/180;
param alpha{a in PLACES, b in PLACES} := sin(d2r*(lat[a]-lat[b])/2)**2 
      + cos(d2r*lat[a])*cos(d2r*lat[b])*sin(d2r*(lng[a]-lng[b])/2)**2;
param gcdist{a in PLACES, b in PLACES} := 2*6371*atan( sqrt(alpha[a,b]), sqrt(1-alpha[a,b]) );

# Path constraints
var x{PLANES, PLACES, PLACES} binary;

# must leave from all nodes except the finish node
#s.t. lv1 {a in PLACES : a != floc[p]}: sum{p in PLANES, b in PLACES} x[p,a,b] = 1;
#s.t. lv2 {p in PLANES}: sum{b in PLACES} x[p,floc[p],b] = 0;

# must arrive at all places except the start node
#s.t. ar1 {a in PLACES : a != start}: sum{b in PLACES} x[b,a] = 1;
#s.t. ar2 : sum{b in PLACES} x[b,start] = 0;

# subtour elimination using an idea from Andrew O. Makhorin
#var y{PLANES, PLACES, PLACES} >= 0, integer;
#s.t. capbnd {a in PLACES, b in PLACES} : y[a,b] <= (card(PLACES)-1)*x[a,b];
#s.t. capcon {a in PLACES} : sum{b in PLACES} y[b,a] 
#         + (if a=start then card(PLACES)) = 1 + sum{b in PLACES} y[a,b];

#minimize obj: sum{p in PLANES, a in PLACES} ;

minimize obj: sum{p in PLANES, a in PLACES, b in PLACES} gcdist[a,b]*x[p,a,b];

solve;

for {p in PLANES} {
    for {a in PLACES, b in PLACES : x[p,a,b] = 1} {
        printf "%s  %s\n", a, b;
    }
}

*/

data;

#param minspeed := 800;
#param maxspeed := 900;

# Locations

param : LOCATIONS : lat           lng :=
        ATL  33.6366995   -84.4278639
        BOS  42.3629722   -71.0064167
        DEN  39.8616667  -104.6731667
        DFW  32.8968281   -97.0379958
        JFK  40.6397511   -73.7789256
        LAX  33.9424955  -118.4080684
        ORD  41.9816486   -87.9066714
        STL  38.7486972   -90.3700289
; 

param : SCHEDULE : T1     T2 :=
        N1  ATL   8.0   24.0
        N2  BOS   8.0    9.0
        N3  DEN  12.0   15.0
        N4  DFW  12.0   13.0
        N5  JFK  18.0   20.0
        N6  LAX  12.0   16.0
        N7  ORD  20.0   24.0
        N8  STL  11.0   13.0
;

param : START :    S1     S2 :=
        P1  ATL   8.0   24.0
        P2  STL   8.0   24.0
;

param : FINISH :   F1     F2 :=
        P1  LAX   8.0   24.0
        P2  ORD   8.0   24.0
;

end;
