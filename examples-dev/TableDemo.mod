


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
end;

table B {s in S} OUT "JSON" "Atomic Mass" "LineChart": atomicNumber[s], amu[s];
