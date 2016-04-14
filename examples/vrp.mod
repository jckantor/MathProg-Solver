/* # Vehicle Routing Problem

 A set of airplanes are initially distributed among a set of
 starting locations. They are to be assigned routes to collectively
 visit a specified set of customers then return the the planes to
 designated finishing locations. The optimization objective is to
 minimize the total great circle distance.

 The data consists of a set of locations with latitude and longitude
 information, a list of customers and their respective locations, and
 a set of aircraft and their starting and finishing locations. The
 aircraft must start and finish at different locations (if needed,
 dummy locations with the same latitude and longitude can be 
 included in the list of locations).
 */

# Jeffrey Kantor
# March, 2013

# DATA SETS (IN THE DATA SECTION)

# CUSTOMERS is a set of (name,location) pairs 
set CUSTOMERS dimen 2;

# PLANES is a set of (name, start_location, finish_location) triples
set PLANES dimen 3;

# set of locations
set LOCATIONS;
param lat{LOCATIONS};
param lng{LOCATIONS};

# DATA PREPROCESSING

# create a set of planes
set P := setof {(p,sLoc,fLoc) in PLANES} p;

# create a set of all nodes as (name, location) pairs
set START := setof {(p,sLoc,fLoc) in PLANES} (p,sLoc);
set FINISH := setof {(p,sLoc,fLoc) in PLANES} (p,fLoc);
set N := CUSTOMERS union (START union FINISH);

# compute great circle distances [km] between locations from latitude,
# longitude data using Haversine formula
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
s.t. sf1 {p in P, (a,aLoc) in  N, (b,bLoc) in START} : x[p,a,aLoc,b,bLoc] = 0;

# no planes leave the finish nodes
s.t. sf2 {p in P, (a,aLoc) in FINISH, (b,bLoc) in N} : x[p,a,aLoc,b,bLoc] = 0;

# planes must leave from their own start nodes
s.t. sf3 {p in P, (a,aLoc) in START, (b,bLoc) in N : p != a} : x[p,a,aLoc,b,bLoc] = 0;

# planes must return to their own finish nodes
s.t. sf4 {p in P, (a,aLoc) in N, (b,bLoc) in FINISH : p != b} : x[p,a,aLoc,b,bLoc] = 0;

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

var y{P,N,N} integer, >= 0;

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

# OBJECTIVE

# route distance for each plane
var routeDistance{P} >= 0;
s.t. ob1 {p in P} : routeDistance[p] 
        = sum{(a,aLoc) in N, (b,bLoc) in N} gcdist[aLoc,bLoc]*x[p,a,aLoc,b,bLoc];

# number of legs on the route for each plane
var routeLegs{P} >= 0;
s.t. ob2 {p in P} : routeLegs[p] = sum{(a,aLoc) in START, (b,bLoc) in N} y[p,a,aLoc,b,bLoc];

# maximum distance on the route of any plane
var maxDistance >= 0;
s.t. ob3 {p in P} : routeDistance[p] <= maxDistance;

# maximum number of legs on the route of any plane
var maxLegs >= 0;
s.t. ob4 {p in P} : routeLegs[p] <= maxLegs;

# pick an objective. Here we minimize total route distance.
minimize distance : sum{p in P} routeDistance[p];

solve;

# OUTPUT POST-PROCESSING

for {p in P} {
    printf "\nRouting for %s\n-------------------\n", p;
    printf "%-20s  %-20s  %10s   \n", 'Depart','Arrive','Dist.';
    for {k in routeLegs[p]..0 by -1} {
       printf {(a,aLoc) in N, (b,bLoc) in N : 
           (x[p,a,aLoc,b,bLoc] = 1) && (y[p,a,aLoc,b,bLoc]=k)} 
	       "%-12s  %-5s   %-12s  %-5s   %10.1f km\n",a,aLoc,b,bLoc,gcdist[aLoc,bLoc];
    }
    printf "%42s  %13s\n", '', '---------';
    printf "%42s  %10.1f km\n\n", 'GC Distance Traveled:', routeDistance[p];
}

# DATA SECTION

data;

set CUSTOMERS := 
       ( 'Atlanta',     ATL )
       ( 'Boston',      BOS )
       ( 'Denver',      DEN )
       ( 'Dallas',      DFW )
       ( 'New York',    JFK )
       ( 'Los Angeles', LAX )
       ( 'Chicago',     ORD )
       ( 'St. Louis',   STL ) 
;

set PLANES :=
       ( 'Plane 1', ORD, ORD_)  # use a duplicate location to return place to ORD
       ( 'Plane 2', DFW, DRW_)  # use a duplicate location to return plane to DFW
;

param : LOCATIONS : lat           lng :=
        ATL   33.6366995   -84.4278639
        BOS   42.3629722   -71.0064167
        DEN   39.8616667  -104.6731667
        DFW   32.8968281   -97.0379958
        DRW_  32.8968281   -97.0379958  # duplicate PLANES
        JFK   40.6397511   -73.7789256
        LAX   33.9424955  -118.4080684
        ORD   41.9816486   -87.9066714
        ORD_  41.9816486   -87.9066714  # duplicate PLANES
        STL   38.7486972   -90.3700289
; 

end;
