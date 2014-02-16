/* citiloco.mod
Create a schedule of visits to places in a city subject to constraints
on cost, time, and time windows. A typical command line

glpsol -m citiloco.mod --mipgap 0.1

The results is a file citiloco.xml with a proposed schedule.
*/

#######################################################################
# specification of data values in citiloco.dat
#######################################################################

set PLACES;
param lat{PLACES};
param lng{PLACES};
param price{PLACES};
param time{PLACES};
param rating{PLACES};
param open{PLACES};
param close{p in PLACES} >= open[p] + time[p]/60;
param type{PLACES} symbolic;

# Maximum cost for an itinerary
param maxcost;

# Start and end times. Default is 9am to midnight
param starttime >= 0, default 9;
param endtime >= 0, >= starttime, default 20;

# start location
param start symbolic, default "Notre Dame Campus";

# set walking and driving travel speeds
param minspeed > 0, default 3;
param maxspeed > 0, default 30;

#######################################################################
# computed sets
####################################################################### 

set TYPES := setof {p in PLACES} type[p];

#######################################################################
# compute great circle distances (miles)
####################################################################### 

param earthRadius := 3963;
param d2r := 3.1415926/180;
param alpha{a in PLACES, b in PLACES} := sin(d2r*(lat[a]-lat[b])/2)**2 
    + cos(d2r*lat[a])*cos(d2r*lat[b])*sin(d2r*(lng[a]-lng[b])/2)**2;
param gcdist{a in PLACES, b in PLACES} := 
    2*earthRadius*atan(sqrt(alpha[a,b]),sqrt(1-alpha[a,b]));

#######################################################################
# schedule mechanics
#######################################################################

# x[i,j] = 1 if the link from i to j is included in the schedule
var x{PLACES, PLACES} binary;

# must leave the start node
s.t. lv1 : sum{b in PLACES} x[start,b] = 1;

# there is no arrival to the start node
s.t. ar1 : sum{a in PLACES} x[a,start] = 0;

# may arrive only once at any other node
s.t. ar2 {b in PLACES : b != start} : sum{a in PLACES} x[a,b] <= 1;

# can't leave from a node unless you've arrived there
s.t. lv3 {p in PLACES : p != start}: 
    sum{a in PLACES} x[a,p] >= sum{b in PLACES} x[p,b];

# Subtour elimination
s.t. st1 {p in PLACES}: x[p,p] = 0;
s.t. st2 {a in PLACES, b in PLACES : a != b} : x[a,b] + x[b,a] <= 1;
s.t. st3 {a in PLACES, b in PLACES, c in PLACES : (a!=b)&&(b!=c)&&(c!=a)}:
    x[a,b] + x[b,c] + x[c,a] <= 2;

#######################################################################
# cost constraints
#######################################################################

# z[a] = 1 if a is on the itinerary
var z{PLACES} binary;
s.t. it1 : z[start] = 1;
s.t. it2 {p in PLACES : p != start} : z[p] = sum{a in PLACES} x[a,p];

# cost constraint
var overbudget >= 0;
s.t. cost : sum{p in PLACES} price[p]*z[p] <= maxcost + overbudget;

#######################################################################
# time constraints
#######################################################################

# Travel time is the minimum of walking or driving time. Driving time
# includes an addition 0.2 hours to allow for parking, etc.

param bigM := 50;
var tar{PLACES};         # arrival
var tlv{PLACES};         # leave
var overtime >= 0;       # over time

s.t. t0 {a in PLACES} : tlv[a] = tar[a] + time[a]/60; 
s.t. t1 {a in PLACES, b in PLACES} : tar[b] >= tlv[a] - bigM*(1-x[a,b])
    + min(gcdist[a,b]/minspeed, 0.2 + gcdist[a,b]/maxspeed);
s.t. t2 {a in PLACES} : tar[a] >= open[a] - bigM*(1-z[a]);
s.t. t3 {a in PLACES} : tlv[a] <= close[a] + bigM*(1-z[a]);
s.t. t4 : tar[start] >= starttime;
s.t. t5 {a in PLACES} : tlv[a] <= endtime + overtime + bigM*(1-z[a]);

#######################################################################
# sequencing
#######################################################################

var seq{PLACES} >= 0;
s.t. sq1 : seq[start] = 1;
s.t. sq2 {a in PLACES : a != start } : seq[a] <= (card(PLACES)+1)*z[a];
s.t. sq3 {a in PLACES, b in PLACES : a != b } : 
    seq[b] >= 1 + seq[a] - bigM*(1-x[a,b]);
s.t. sq4 {a in PLACES, b in PLACES : a != b } : 
    seq[b] <= 1 + seq[a] + bigM*(1-x[a,b]);

#######################################################################
# preference constraints
#######################################################################

s.t. food : sum{a in PLACES : type[a] = 'dining'} z[a] <= 2;
s.t. drink: sum{a in PLACES : type[a] = 'bar'} z[a] <= 1;

#######################################################################
# objective
#######################################################################

param r{p in PLACES} := Uniform(0,1); 
var srate >= 0;
s.t. r1 : srate = sum{p in PLACES} (rating[p]+r[p])*z[p];
minimize rate : 100*(overtime + overbudget) - srate;
solve;

#######################################################################
# diagnostic output
#######################################################################

printf "\n";
printf "    Budget = %6.2f\n", maxcost;
printf "Start Time = %6.2f\n", starttime;
printf "  End Time = %6.2f\n", endtime;

printf "\n";
printf "    %-35s %6s %6s %6s %6s %6s %6s %6s\n", 
    'Name', 'Price', 'Stars', 'Time', 'Open', 'Close', 'Arr', 'Lv';
for {k in 1..card(PLACES)} {
    printf {p in PLACES : abs(k -seq[p]) < 0.1}
        "%2d) %-35s %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n", 
        seq[p], p, price[p], rating[p], time[p]/60, open[p], close[p], tar[p], tlv[p];
}
printf "\n";
printf "  Actual Expense = %6.2f\n", sum {p in PLACES : (z[p]=1)} price[p];
printf "\n";

#######################################################################
# write xml output file
#######################################################################

param xmlout symbolic := "citiloco.xml";
printf "<schedule>\n"  > xmlout;
for {k in 1..card(PLACES)} {
    for {a in PLACES : (abs(k-seq[a]) < 0.1) } {
        printf "<option>\n"  >> xmlout;
        printf "    <location>\n" >> xmlout;
        printf "        <name>%s</name>\n",a >> xmlout;
        printf "        <price>%6.2f</price>\n",price[a] >> xmlout;
        printf "        <time>%6.2f</time>\n",time[a] >> xmlout;
        printf "        <lat>%9.6f</lat>\n",lat[a] >> xmlout;
        printf "        <lng>%9.6f</lng>\n",lng[a] >> xmlout;
        printf "    </location>\n" >> xmlout;
        printf "    <startTime>%6.2f</startTime>\n",tar[a] >> xmlout;
        printf "    <endTime>%6.2f</endTime>\n",tlv[a] >> xmlout;
        printf "</option>\n" >> xmlout;
    }
}
printf "</schedule>\n" >> xmlout;

#######################################################################
# data section
#######################################################################

data;

param maxcost := 60;

param : PLACES :                    price	open	close	time	lat			lng			type	rating :=
'Fiddlers Hearth'                   16.00	11.00	23.00	89.00	41.67733	-86.25218	dining	4
'The Vine'                          25.00	11.00	21.00	89.00	41.67774	-86.25143	dining	3.5
'Siam Thai Restaurant'              14.00	17.00	21.00	89.00	41.67822	-86.25222	dining 	2.5
'Cambodian Thai'                    8.00	11.50	21.00	89.00	41.67464	-86.25033	dining 	1.5
'Trios Restaurant and Jazz Club'	25.00	17.00	23.00	89.00	41.67743	-86.25059	dining 	4.0
'Cafe Navarre'                     18.00	17.00	22.00	89.00	41.67671	-86.25044	dining	3.2
'Madison Oyster Bar'               10.00	11.00	27.00	89.00	41.67743	-86.25219	bar		3.3
'Main Street Coffee House'          7.00	6.50	22.00	45.00	41.67654	-86.25182	coffee	3.4
'Notre Dame Campus'                  0.00	0.00	24.00	90.00	41.69954	-86.23826	attraction	2.3
'Studebaker National Museum'         8.00	10.00	17.00	40.00	41.67459	-86.26185	attraction	3.4
'South Bend Museum of Art'           0.00	9.50	19.00	35.00	41.66961	-86.24989	attraction	2.3
'Snite Museum of Art'                0.00	1.00	17.00	35.00	41.69959	-86.23273	attraction	4.5
'Healthworks Kids Museum'            6.00	9.00	16.00	60.00	41.67513	-86.25174	attraction	2.3
'South Bend Chocolate Company Tour'  4.00	9.00	16.00	45.00	41.66470	-86.29472	attraction	4.0
;

end;
