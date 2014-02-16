/* Pickup and Delivery

 This is a proof-of-concept model for a pickup and delivery service.
 The model describes how a set of drivers would handle a predetermined
 set of orders where each order consists of a pickup location and
 delivery location with accompanying time windows. The drivers have
 home locations and commission periods during which they are available.
 Location data is used to compute a distance matrix among all
 locations.  Drivers can pickup and deliver multiple orders. The
 objective is to minimize total drive time, where drive time is a
 proxy for total cost. 

 This is a proof of concept model. As such, a number of important
 features have not been included. Among these are

     * graceful handling of infeasibile solutions.  Currently the solver
       simply fails. The problem statement should be updated to
       include soft constraints for time windows.
     * car capacity constraints
     * priority weights for drivers, customers, and orders
     * time variable aggregation
     * additional modeling of subtour elimination constraints
     * allowing for multiple departures for the same car from the
       pickup locations. 

 An important simplification was to model only a single departure time
 for each car from each location. A driver can pick up multiple packages
 from a location, and multiple drivers can service the pickup location,
 but this model provides for only a single visit for each driver to each
 location.

 The immediate priority should be handling feasibility, and performance
 testing for small and medium scale application.

*/

# Locations
set P;  # pickup locations
set D;  # delivery locations
set S;  # car start and finish locations

# Distance Matrix
set N := P union D union S;
param lat{N};
param lng{N};
param dist{i in N, j in N} := sqrt((lat[i]-lat[j])**2 + (lng[i]-lng[j])**2);
param dur{i in N, j in N} := dist[i,j]/10;

# Orders with Pickup and Delivery windows
set ORDERS within P cross D;
param Tp1{ORDERS};
param Tp2{(p,d) in ORDERS} >= Tp1[p,d];
param Td1{(p,d) in ORDERS} >= Tp1[p,d];
param Td2{(p,d) in ORDERS} >= Td1[p,d];

# Cars 
set K;  # set of cars
param Tk1{K};
param Tk2{k in K} >= Tk1[k];

# DECISION VARIABLES

# x[i,j,k] = 1 if car k travels from location i to location j
var x{N,N,K} binary;

# Arrival and Departure times for car k at location n
var Tar{N,K};
var Tlv{N,K};

## MODEL FOR DRIVER BEHAVIORS

# Each car starts at their home location and goes to a pickup
s.t. SF01 {k in K} : sum{j in P} x[k,j,k] = 1;
s.t. SF02 {k in K, j in D} : x[k,j,k] = 0;
s.t. SF03 {k in K, j in S : j!=k} : x[k,j,k] = 0;

# Each car finishes at their home location following a delivery
s.t. SF04 {k in K} : sum{j in D} x[j,k,k] = 1;
s.t. SF05 {k in K, j in P} : x[j,k,k] = 0;
s.t. SF06 {k in K, j in S : j!= k} : x[j,k,k] = 0;

# A car enters and leaves a location the same number of times
s.t. SF07 {k in K, i in N} : sum{j in N} x[j,i,k] = sum{j in N} x[i,j,k];

# A car does not return immediately to the same location
s.t. SF08 {k in K, i in N} : x[i,i,k] = 0;

# Drivers do not enter or leave home locations of other drivers
s.t. SF09 {k in K, i in N, j in S : j!=k } : x[i,j,k] = 0;
s.t. SF10 {k in K, i in S, j in N : i!=k } : x[i,j,k] = 0;

## ORDER HANDLING

# Assign one car to pickup an order and take it somewhere
s.t. RH1 {(p,d) in ORDERS} : sum{k in K, j in P union D} x[p,j,k] = 1;

# If car k picks up order (p,d) then it also visits the delivery node
s.t. RH2 {(p,d) in ORDERS, k in K} : (sum{j in N} x[p,j,k]) = (sum{i in N} x[i,d,k]);

param bigM := 10;

# Cars leave home and arrive back within their commission period
s.t. TM00 {k in K} : Tlv[k,k] >= Tk1[k];
s.t. TM01 {k in K} : Tar[k,k] <= Tk2[k];

# For all other nodes the leave time is after the arrival time
s.t. TM02 {k in K, i in P union D} : Tlv[i,k] >= Tar[i,k];

# Account for travel time
s.t. TM03 {i in N, j in N, k in K : j!=k } : Tar[j,k] >= Tlv[i,k] + dur[i,j] - bigM*(1-x[i,j,k]);

# Time window for pickup. Cannot leave until the window starts, must arrive before it ends
s.t. TM04 {(p,d) in ORDERS, j in N, k in K} : Tlv[p,k] >= Tp1[p,d] - bigM*(1-x[p,j,k]);
s.t. TM05 {(p,d) in ORDERS, j in N, k in K} : Tar[p,k] <= Tp2[p,d] + bigM*(1-x[p,j,k]);

# Time window for delivery. Must arrive during the time window.
s.t. TM06 {(p,d) in ORDERS, j in N, k in K} : Tar[d,k] >= Td1[p,d] - bigM*(1-x[j,d,k]);
s.t. TM07 {(p,d) in ORDERS, j in N, k in K} : Tar[d,k] <= Td2[p,d] + bigM*(1-x[j,d,k]);

## OBJECTIVE: Select routes minimizing overall drive time of all drivers

var Tf{K};
var Cost;

s.t. OBJ01 {k in K, i in N, j in N} : Tf[k] >= Tar[j,k] - bigM*(1-x[i,j,k]);
s.t. OBJ02 : Cost = sum{i in N, j in N, k in K} x[i,j,k]*dur[i,j];

minimize obj: bigM*Cost + sum{k in K} Tf[k];

solve;

printf "\n\nORDERS\n";
printf "%-12s  %6s  %6s        %-12s  %6s  %6s\n",
       "Pickup", "Start", "End", "Delivery", "Start", "End";
printf {(p,d) in ORDERS} "%-12s  %6.2f  %6.2f        %-12s  %6.2f  %6.2f\n", 
    p, Tp1[p,d], Tp2[p,d], d, Td1[p,d], Td2[p,d];

printf "\n\nPICKUPS\n";
printf "%-12s  %-12s  %-12s  %6s  %6s  %6s\n", 
       "Driver", "Pickup", "Delivery", "Start", "End", "Est.";
printf {(p,d) in ORDERS, j in N, k in K : x[p,j,k] = 1}
    "%-12s  %-12s  %-12s  %6.2f  %6.2f  %6.2f\n", 
    k, p, d, Tp1[p,d], Tp2[p,d], Tar[p,k];

printf "\n\nDELIVERIES\n"; 
printf "%-12s  %-12s  %-12s  %6s  %6s  %6s\n", 
       "Driver", "Pickup", "Delivery", "Start", "End", "Est.";
printf {(p,d) in ORDERS, j in N, k in K : x[j,d,k] = 1}
    "%-12s  %-12s  %-12s  %6.2f  %6.2f  %6.2f\n", 
    k, p, d, Td1[p,d], Td2[p,d], Tar[d,k];

printf "\n\nROUTING\n";
printf "%-12s  %-12s  %-12s  %6s  %6s  %6s\n",
       "Driver", "Start", "End", "Leave", "Arrive", "Travel";
printf {k in K, i in N, j in N : x[i,j,k] = 1}
    "%-12s  %-12s  %-12s  %6.2f  %6.2f  %6.2f\n",
    k, i, j, Tlv[i,k], Tar[j,k], dur[i,j];
printf "\n";

data;

set P := 'Bed Bath' 'Home Depot' 'Ikea';
set D := 'Daphne' 'Jeff' 'Tim' 'Tom';
set S := 'Alex' 'Brian';

param : lat lng :=
    'Alex'        25.00  25.00
    'Brian'       25.00  25.00
    'Ikea'        20.22  20.40
    'Bed Bath'    29.30  24.00
    'Home Depot'  21.20  30.00
    'Jeff'        20.34  28.00
    'Tim'         20.34  23.00
    'Tom'         23.03  20.00
    'Daphne'      25.00  25.00  ;
    
param :  ORDERS :                   Tp1     Tp2     Td1     Td2 :=
    'Ikea'            'Tim'         9.5    17.0    11.0    16.0
    'Ikea'            'Daphne'      9.0    17.0    11.0    16.0
    'Home Depot'      'Jeff'       10.0    14.0    10.5    15.5
    'Bed Bath'        'Tom'        10.0    17.0    12.5    16.5 
    'Bed Bath'        'Jeff'       10.5    12.0    11.5    12.5 ;
     
param : K :     Tk1      Tk2 :=
     'Alex'     8.0     12.5
     'Brian'   10.0     15.0 ;

end;
