

set S;
param a{S};
param amu{S};
param name{S} symbolic;
param bp{S};
param mp{S};

table tin IN "JSON" "PeriodicTable" : 
    S<-[Symbol], 
    a~Atomic_Number, 
    amu~Atomic_Weight,
    bp~Boiling_Point,
    mp~Melting_Point;
    
table tout {s in S} OUT "JSON" "Atomic Weight" "LineChart" : 
    a[s]~Atomic_Number, mp[s]~Melting_Point, bp[s]~Boiling_Point;

end;