/* # Set Operations in MathProg

Sets are a basic concept in mathematical programming languages. Sets are 
used to define the objects of discourse in a particular application. A 
convenient notation to is name sets in all caps so they are readily 
distinguished from variables and parameters appearing in an application.

This example demonstrates several basic and useful set manipulations in
MathProg:

* `union`: the union of sets
* `card` : the cardinality (i.e, number of elements) of a set
* : intersection of sets
* : difference of sets
* : symmetric difference of sets

*/

set DOGS := {'Beagle','Labrador','Shepherd','Boxer'};
set CATS := {'Tiger','Lion'};
set FISH := {'Goldfish','Guppy','Shark'};

# Union of Sets

set PETS := DOGS union CATS union FISH;

printf "PETS: ";
for {pet in PETS} printf "%4s ", pet;

# Cardinality of a Set

printf "\n\nNumber of Pets: %d", card(PETS);

set DANGEROUS := {'Tiger','Lion','Shark','Crocodile'};

# Intersection

# Difference of Sets

set SAFE := PETS diff DANGEROUS;

printf "\n\nSAFE: ";
for {pet in SAFE} printf "%4s ",pet;

# Symmetric Difference of Sets

printf "\n\n";
end;