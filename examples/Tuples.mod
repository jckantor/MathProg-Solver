/* # Tuples

Tuples a valuable tool for managing the relationship between multiple
    sets as found, for example, in network and transportation problems. 
    A surprising rich range of computations can be done with tuples and
    set operations.
*/

# Example: Tuples.mod

set ORIG2 := {'New York','Boston','Miami'};
set DEST2 := {'London','Rome'};
set LINKS2 := {
	('New York','London'),
	('New York','Rome'),
	('Boston','London'),
	('Miami','Rome')
};

printf "\nFeasible (Origin,Destination) pairs:\n";
printf {o in ORIG2, d in DEST2 : (o,d) in LINKS2} "(%s,%s)\n",o,d;

printf "\n\nDestinations accessible from New York:\n";
printf {d in DEST2 : ('New York',d) in LINKS2} "(%s)\n",d;

# Constructing Tuples

set ORIG := {'New York','Boston','Miami'};
set DEST := {'London','Rome'};
set LINKS := {ORIG,DEST};

printf "\nAll possible (Origin,Destination) pairs:\n";
printf {(o,d) in LINKS} "(%s,%s)\n",o,d;

# Constructing Tuples with logical comparison

set C := {a in A, b in B: 10*a <= b};

printf "\n\n";
display {(a,b) in C} (a,b);

# Inferring Sets from Tuples using SETOF

set LINKS3 := {
	('New York','London'),
	('Boston','Rome'),
	('Miami','Amsterdam')
};

set ORIG3 := setof {(o,d) in LINKS3} o;
set DEST3 := setof {(o,d) in LINKS3} d;

printf "%8s"," ";
printf {d in DEST3} "%12s ",d;

printf "\n";
for {o in ORIG3}{
	printf "%8s   ",o;
	printf {d in DEST3} "%8s   ", if (o,d) in LINKS3 then "X" else "-";
	printf "\n";
}

# Working with Indexed Sets

set I := 1..2;
set J := 1..2;
set D{i in I,j in J} := {(i,j),(i,10+i*j)};

display{i in I, j in J, (a,b) in D[i,j]} (a,b);

# Set Data with a default

set MONTHS default {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep',
	'Oct','Nov','Dec'};

display {m in MONTHS} m;

# Indexed Sets. Show that sets can be read and other sets inferred

set SPORTS;
set TEAMS{s in SPORTS};

set PLAYERS := setof {s in SPORTS, p in TEAMS[s]} p;

display{s in SPORTS, p in TEAMS[s]} (s,p);

/*
 Data Section.  Here we can omit the quotes ('') defining set elements.
 Elements of the set are declared in the "data" section or a separate
 file. While this may seem indirect, separation of problem definition and
 data provides a powerful means to apply a problem definition to new
 applications.
*/

data;

set MONTHS := JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC;

set SPORTS := Baseball Hockey Soccer;
set TEAMS[Baseball] := Alex Brian Mary John;
set TEAMS[Hockey] := Brian Alex Diane Jessica;
set TEAMS[Soccer] := Mary John Jessica;

end;