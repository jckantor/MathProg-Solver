/* # Vehicle Routing Problem with Time Windows

 A set of airplanes are initially distributed among a set of
 starting locations. They are to be assigned routes to collectively
 visit a specified set of customers then return the the planes to
 designated finishing locations within designated time windows.

 The data consists of a set of locations with latitude and longitude
 information, a list of customers and their respective locations, and
 a set of aircraft and their starting and finishing locations, and 
 the start and of associated time windows. The aircraft must start 
 and finish at different locations (if needed, dummy locations with
 the same latitude and longitude can be included in the list of 
 locations). Plane speed is constrained to between upper and lower
 bounds.

 The time windows are implemented as 'soft' constraints. Additional
 decision variables are

   * tar[name,loc]  arrival time at (name,loc) 
   * tlv[name,loc]  departure time from (name,loc)
   * tea[name,loc] >= 0  for arrival before the time window
   * tla[name,loc] >= 0  for arrival after the time window
   * ted[name,loc] >= 0  for departure before the time window
   * tld[name,loc] >= 0  for departure after the time window

  A weighted some of tea, tla, ted, and tld constitutes a time 
  penalty which is zero if there is a feasible solution.

  The objective function is weighted sum of the time penalty and
  total route distance.

 Jeffrey Kantor
 March, 2013
*/

# DATA SETS (TO BE GIVEN IN THE DATA SECTION)

param maxspeed > 0;
param minspeed > 0, <= maxspeed;

# CUSTOMERS is a set of (name,location) pairs 
set CUSTOMERS dimen 2;
param T1{CUSTOMERS};
param T2{(name,loc) in CUSTOMERS} >= T1[name,loc];

# PLANES is a set of (name, start_location, finish_location) triples
set PLANES dimen 3;
param S1{PLANES};
param S2{(p,sLoc,fLoc) in PLANES} >= S1[p,sLoc,fLoc];
param F1{PLANES};
param F2{(p,sLoc,fLoc) in PLANES} >= F1[p,sLoc,fLoc];

# set of locations
set LOCATIONS;
param lat{LOCATIONS};
param lng{LOCATIONS};

# DATA PREPROCESSING

# set of planes
set P := setof {(p,sLoc,fLoc) in PLANES} p;

# compute START as (plane,startlocation) pairs with time windows
set START := setof {(p,sLoc,fLoc) in PLANES} (p,sLoc);
param TS1{(p,sLoc) in START} := 
    max{ (q,tLoc,fLoc) in PLANES : (p=q) && (sLoc=tLoc) } S1[p,sLoc,fLoc];
param TS2{(p,sLoc) in START} := 
    min{ (q,tLoc,fLoc) in PLANES : (p=q) && (sLoc=tLoc) } S2[p,sLoc,fLoc];

# compute FINISH as (plane,finishlocation) pairs with  time windows
set FINISH := setof {(p,sLoc,fLoc) in PLANES} (p,fLoc);
param TF1{(p,fLoc) in FINISH} := 
    max{ (q,sLoc,gLoc) in PLANES : (p=q) && (fLoc=gLoc) } F1[p,sLoc,fLoc];
param TF2{(p,fLoc) in FINISH} := 
    min{ (q,sLoc,gLoc) in PLANES : (p=q) && (fLoc=gLoc) } F2[p,sLoc,fLoc];

# create a complete of nodes as (name, location) pairs
set N := CUSTOMERS union (START union FINISH);

# great circle distances between locations
param d2r := 3.1415926/180;
param alpha{a in LOCATIONS, b in LOCATIONS} := sin(d2r*(lat[a]-lat[b])/2)**2 
    + cos(d2r*lat[a])*cos(d2r*lat[b])*sin(d2r*(lng[a]-lng[b])/2)**2;
param gcdist{a in LOCATIONS, b in LOCATIONS} := 
    2*6371*atan( sqrt(alpha[a,b]), sqrt(1-alpha[a,b]) );

# DECISION VARIABLES

# x[p,a,aLoc,b,bLoc] = 1 if plane p flies from (a,aLoc) to (b,bLoc)
var x{P, N, N} binary;

# START AND FINISH CONSTRAINTS

# no planes arrive at the start nodes
s.t. sf1 {p in P, (a,aLoc) in  N, (b,bLoc) in START} : 
        x[p,a,aLoc,b,bLoc] = 0;

# no planes leave the finish nodes
s.t. sf2 {p in P, (a,aLoc) in FINISH, (b,bLoc) in N} : 
        x[p,a,aLoc,b,bLoc] = 0;

# planes must leave from their own start nodes
s.t. sf3 {p in P, (a,aLoc) in START, (b,bLoc) in N : p != a} : 
        x[p,a,aLoc,b,bLoc] = 0;

# planes must return to their own finish nodes
s.t. sf4 {p in P, (a,aLoc) in N, (b,bLoc) in FINISH : p != b} : 
        x[p,a,aLoc,b,bLoc] = 0;

# NETWORK CONSTRAINTS

# one plane arrives at each customer and finish node
s.t. nw1 {(b,bLoc) in (CUSTOMERS union FINISH)} : 
        sum {p in P, (a,aLoc) in (CUSTOMERS union START)} x[p,a,aLoc,b,bLoc] = 1;

# one plane leaves each start and customer node
s.t. nw2 {(a,aLoc) in (START union CUSTOMERS)} :
        sum {p in P, (b,bLoc) in (CUSTOMERS union FINISH)} x[p,a,aLoc,b,bLoc] = 1;

# planes entering a customer node must leave the same node
s.t. nw3 {p in P, (a,aLoc) in CUSTOMERS} : 
    sum {(b,bLoc) in (CUSTOMERS union START)} x[p,b,bLoc,a,aLoc]
        = sum {(b,bLoc) in (CUSTOMERS union FINISH)} x[p,a,aLoc,b,bLoc];

# no self loops
s.t. nw4 {p in P, (a,aLoc) in N, (b,bLoc) in N : (a=b) && (aLoc=bLoc)} :
    x[p,a,aLoc,b,bLoc] = 0;

# SUBTOUR ELIMINATION CONSTRAINTS

var y{P,N,N} >= 0;

# route capacity
s.t. sb1 {p in P, (a,aLoc) in N, (b,bLoc) in N} : 
    y[p,a,aLoc,b,bLoc] <= card(CUSTOMERS)*x[p,a,aLoc,b,bLoc];

# allocate tokens to links from the start nodes
s.t. sb2 : sum {p in P, (a,aLoc) in START, (b,bLoc) in N } y[p,a,aLoc,b,bLoc] 
               = card(CUSTOMERS);

# decrease tokens for each step on a path
s.t. sb3 {(a,aLoc) in CUSTOMERS} : 
    sum{p in P, (b,bLoc) in (CUSTOMERS union START)} y[p,b,bLoc,a,aLoc] 
        = 1 + sum{p in P, (b,bLoc) in (CUSTOMERS union FINISH)} y[p,a,aLoc,b,bLoc];

# TIME WINDOW CONSTRAINTS
param bigM := 50;
var tar{N};
var tlv{N};
var tea{N} >= 0;
var tla{N} >= 0;
var ted{N} >= 0;
var tld{N} >= 0;

s.t. t00 {(a,aLoc) in N} : tlv[a,aLoc] >= tar[a,aLoc];
s.t. t01 {p in P, (a,aLoc) in N, (b,bLoc) in N} : tar[b,bLoc] >= tlv[a,aLoc] 
        + gcdist[aLoc,bLoc]/maxspeed - bigM*(1-x[p,a,aLoc,b,bLoc]);
s.t. t02 {p in P, (a,aLoc) in N, (b,bLoc) in N} : tar[b,bLoc] <= tlv[a,aLoc] 
        + gcdist[aLoc,bLoc]/minspeed + bigM*(1-x[p,a,aLoc,b,bLoc]);
s.t. t03 {(a,aLoc) in CUSTOMERS} : tea[a,aLoc] >= T1[a,aLoc] - tar[a,aLoc];
s.t. t04 {(a,aLoc) in FINISH} :    tea[a,aLoc] >= TF1[a,aLoc] - tar[a,aLoc];
s.t. t05 {(a,aLoc) in CUSTOMERS} : tla[a,aLoc] >= tar[a,aLoc] - T2[a,aLoc];
s.t. t06 {(a,aLoc) in FINISH} :    tla[a,aLoc] >= tar[a,aLoc] - TF2[a,aLoc];
s.t. t07 {(a,aLoc) in START} :     ted[a,aLoc] >= TS1[a,aLoc] - tlv[a,aLoc];
s.t. t08 {(a,aLoc) in CUSTOMERS} : ted[a,aLoc] >= T1[a,aLoc] - tlv[a,aLoc];
s.t. t09 {(a,aLoc) in START} :     tld[a,aLoc] >= tlv[a,aLoc] - TS2[a,aLoc];
s.t. t10 {(a,aLoc) in CUSTOMERS} : tld[a,aLoc] >= tlv[a,aLoc] - T2[a,aLoc];

# OBJECTIVE
# The objective function is a weighted sum of violations of the time window
# constraints and the total distance traveled. 

var routeDistance{P} >= 0;
s.t. ob1 {p in P} : routeDistance[p] 
        = sum{(a,aLoc) in N, (b,bLoc) in N} gcdist[aLoc,bLoc]*x[p,a,aLoc,b,bLoc];

var totalDistance >= 0;
s.t. ob2 : totalDistance = sum{p in P} routeDistance[p];

var timePenalty >= 0;
s.t. ob3 : timePenalty = 
    sum{(a,aLoc) in N} (tea[a,aLoc] + 2*tla[a,aLoc] + 2*ted[a,aLoc] + tld[a,aLoc]);

minimize obj: 5*timePenalty + totalDistance/maxspeed;

solve;

# OUTPUT POST-PROCESSING

param routeTime{p in P} := 
    sum{(a,aLoc) in N, (b,bLoc) in N} (tar[b,bLoc]-tlv[a,aLoc])*x[p,a,aLoc,b,bLoc];

param routeLegs{p in P} :=
    sum{(a,aLoc) in START, (b,bLoc) in N} y[p,a,aLoc,b,bLoc];

for {p in P} {
    printf "\nRouting for %s\n-------------------\n", p;
    printf "%-24s  %-24s  %7s %5s %6s \n", 
        'Depart','Arrive','Dist.','Time','Speed';
    for {k in routeLegs[p]..0 by -1} {
        printf {(a,aLoc) in N, (b,bLoc) in N : 
            (x[p,a,aLoc,b,bLoc] = 1) && (abs(y[p,a,aLoc,b,bLoc]-k)<0.001)} 
            "%-12s %-4s %5.2f%1s  %-12s %-4s %5.2f%1s  %7.1f %5.2f %6.1f\n",
            a, aLoc, tlv[a,aLoc], 
            if (ted[a,aLoc] > 0) then "E" else (if (tld[a,aLoc] > 0) then "L" else " "),
            b, bLoc, tar[b,bLoc],
            if (tea[b,bLoc] > 0) then "E" else (if (tla[b,bLoc] > 0) then "L" else " "),
            gcdist[aLoc,bLoc], tar[b,bLoc]-tlv[a,aLoc], 
            if (gcdist[aLoc,bLoc] > 0) then gcdist[aLoc,bLoc]/(tar[b,bLoc]-tlv[a,aLoc]) else 0;
    }
    printf "%50s  %7s %5s\n", '', '-------','-----';
    printf "%50s  %7.1f %5.2f\n\n", 'Totals:', routeDistance[p], routeTime[p];
}

# DATA SECTION

data;

param maxspeed := 800;
param minspeed := 600;

param : CUSTOMERS :            T1      T2 := 
        'Atlanta'      ATL     8.0    24.0
        'Boston'       BOS     8.0     9.0
        'Denver'       DEN    12.0    15.0
        'Dallas'       DFW    12.0    13.0
        'New York'     JFK    18.0    20.0
        'Los Angeles'  LAX    12.0    16.0
        'Chicago'      ORD    20.0    24.0
        'St. Louis'    STL    11.0    13.0
;

param : PLANES :                     S1     S2     F1     F2 :=
        'Plane 1'    ORD    ORD_    8.0   24.0    8.0   24.0
        'Plane 2'    DFW    DRW_    8.0   24.0    8.0   24.0
;

param : LOCATIONS : lat           lng :=
        ATL   33.6366995   -84.4278639
        BOS   42.3629722   -71.0064167
        DEN   39.8616667  -104.6731667
        DFW   32.8968281   -97.0379958  # start location
        DRW_  32.8968281   -97.0379958  # finish location
        JFK   40.6397511   -73.7789256
        LAX   33.9424955  -118.4080684
        ORD   41.9816486   -87.9066714  # start location
        ORD_  41.9816486   -87.9066714  # finish location
        STL   38.7486972   -90.3700289
; 

end;
