/* # Generation-Consumption Analysis of the Solvay Process
 
The Solvay process was invented in the mid-nineteenth century for the production
of soda ash (Sodium Carbonate) from sea salt (Sodium Chloride) and limestone 
(Calcium Carbonate). Soda ash is an essential raw material for the production of 
soap, glass, textiles, and numerous inorganic products. Prior to that time these
needs were met by the production of potash from trees, which led to the deforestation
of Europe, and later the production of soda ash from the noxious LeBlance process.
In a brilliant piece of early process engineering, Ernest Solvay utilized an 
ammonia based chemistry in which the necessary chemicals are regenerated within the
process.

The following model performs a generation/consumption analysis of the four chemical
reactions comprising the Solvay process. The objective function is to maximize the
atom efficiency, which is the fraction of the total mass of raw materials that
ends up in the desired product, in this case soda ash.
*/

set ATOMS;
set SPECIES;
set REACTIONS;

param amu{ATOMS} >= 0;
param name{SPECIES} symbolic;
param formula{SPECIES,ATOMS} >= 0;
param stoich{SPECIES,REACTIONS};

# Compute Molecular Weights
param mw{s in SPECIES} := sum{a in ATOMS} amu[a]*formula[s,a];

# Check for balanced reactions
check {a in ATOMS, r in REACTIONS}: sum{s in SPECIES} stoich[s,r]*formula[s,a] = 0;

# Generation/Consumption Analysis
set RAW_MATERIALS within SPECIES;
set PRODUCTS within SPECIES;
set BYPRODUCTS := (SPECIES diff RAW_MATERIALS diff PRODUCTS);

var x{REACTIONS};
var n{SPECIES};

s.t. A {s in SPECIES} : n[s] = sum{r in REACTIONS} stoich[s,r]*x[r];
s.t. B {s in RAW_MATERIALS}: sum{r in REACTIONS} n[s] <= 0;
s.t. C {s in SPECIES diff RAW_MATERIALS}: sum{r in REACTIONS} n[s] >= 0;
s.t. D : sum{s in RAW_MATERIALS} -n[s] <= 1;

maximize atom_efficiency: sum{s in PRODUCTS} mw[s]*n[s];

solve;

printf "Atom Efficiency = %6.4f\n\n", 
    (sum{s in PRODUCTS} mw[s]*n[s])/(sum{s in RAW_MATERIALS} -mw[s]*n[s]);

printf "Process Stoichiometry\n";
printf "%10s",' ';
printf {r in REACTIONS} "%7s", r;
printf "%7s\n", "NET";
printf "%-10s",'Rxn Wt.';
printf {r in REACTIONS} "%7.2g", x[r];
printf "\n";
for {s in SPECIES} {
    printf "%-10s", s;
    printf {r in REACTIONS} "%7g", stoich[s,r];
    printf "%7.2g", n[s];
    printf "\n";
}
    
table chrt2 {s in RAW_MATERIALS} OUT "GCHART" "Raw Materials Consumed" "PieChart" : 
    s, -mw[s]*n[s]~Consumed;
    
table chrt3 {s in SPECIES diff RAW_MATERIALS} OUT "GCHART" "Products and By-Products Generated " "PieChart" : 
    s, mw[s]*n[s]~Generated;

table tab1 {s in RAW_MATERIALS} OUT "GCHART" "Raw Materials" "Table" : 
    name[s]~Raw_Material, s~Formula, mw[s]~MolWt, 
    sum{r in REACTIONS} max(0,(mw[s]*stoich[s,r]*x[r]))~Generated,
    sum{r in REACTIONS} max(0,-(mw[s]*stoich[s,r]*x[r]))~Consumed,
    mw[s]*n[s]~Net;

table tab1 {s in PRODUCTS} OUT "GCHART" "Products" "Table" : 
    name[s]~Product, s~Formula, mw[s]~MolWt, 
    sum{r in REACTIONS} max(0,(mw[s]*stoich[s,r]*x[r]))~Generated,
    sum{r in REACTIONS} max(0,-(mw[s]*stoich[s,r]*x[r]))~Consumed,
    mw[s]*n[s]~Net;
    
table tab3 {s in BYPRODUCTS} OUT "GCHART" "Byproducts" "Table" : 
    name[s]~Byproduct, s~Formula, mw[s]~MolWt, 
    sum{r in REACTIONS} max(0,(mw[s]*stoich[s,r]*x[r]))~Generated,
    sum{r in REACTIONS} max(0,-(mw[s]*stoich[s,r]*x[r]))~Consumed,
    mw[s]*n[s]~Net;

data;

param : ATOMS : amu :=
    C    12.011
    Ca   40.08
    Cl   35.45
    H     1.0079
    N    14.0067
    Na   22.99
    O    15.99994 
    S    32.06 ;

param : SPECIES : name := 
    NH3       Ammonia
    NH4Cl     Ammonium_Chloride
    CaCO3     Calcium_Carbonate
    CaCl2     Calcium_Chloride
    NaCl      Sodium_Chloride
    CaO       Calcium_Oxide
    CO2       Carbon_Dioxide
    Na2CO3    Sodium_Carbonate
    NaHCO3    Sodium_Bicarbonate
    H2O       Water ;

set RAW_MATERIALS := NaCl CaCO3;
set PRODUCTS := Na2CO3;

param formula default 0:
              C  Ca Cl H  N  Na O :=
    NH3       .  .  .  3  1  .  .
    NH4Cl     .  .  1  4  1  .  .
    CaCO3     1  1  .  .  .  .  3
    CaCl2     .  1  2  .  .  .  .
    NaCl      .  .  1  .  .  1  .
    CaO       .  1  .  .  .  .  1
    CO2       1  .  .  .  .  .  2
    Na2CO3    1  .  .  .  .  2  3
    NaHCO3    1  .  .  1  .  1  3
    H2O       .  .  .  2  .  .  1 ;
    
set REACTIONS := R1 R2 R3 R4;

param stoich default 0:
              R1   R2   R3   R4 :=
    NH3       -1    .    2    .
    NH4Cl      1    .   -2    .
    CaCO3      .   -1    .    . 
    CaCl2      .    .    1    .
    NaCl      -1    .    .    .
    CaO        .    1   -1    .
    CO2       -1    1    .    1
    Na2CO3     .    .    .    1
    NaHCO3     1    .    .   -2
    H2O       -1    .    1    1 ;

end;