
set S;
param a{S};

table tin IN "CSV" "test.csv" : S <- [Atom], a~amu;

table tout {s in S} OUT "JSON" "MyChart" "Table" : s, a[s];

end;