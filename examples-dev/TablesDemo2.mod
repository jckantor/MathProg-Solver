


set S;
param formula{S} symbolic;
param atomicNumber{S};
param amu{S};
param mp{S};
param bp{S};

table tab IN "JSON" "MathProgData" "0AkMTIvpa1TdgdFBIUFFIOFdmckhrRkd5bzgxRjNqNXc" : 
    S <- [Name],
    atomicNumber~Atomic_Number,
    amu~Atomic_Mass,
    mp~Melting_Point,
    bp~Boiling_Point;

table A {s in S} OUT "JSON" "Melting Boiling Points" "LineChart": atomicNumber[s], mp[s], bp[s];

table B {s in S} OUT "JSON" "Atomic Mass" "LineChart": atomicNumber[s], amu[s];

set N;
param date{N} symbolic;
param aapl{N};

table tab2 IN "JSON" "AAPL" "0AkMTIvpa1TdgdGFWUGVOYVV3M3JsOTJUdTFRNWo0Q0E" "Table" : 
  N<-[Row], aapl~Close;

table tab3 {n in N} OUT "JSON" "APPL Close" "ColumnChart" : n, aapl[n];

param return{n in N};

end;