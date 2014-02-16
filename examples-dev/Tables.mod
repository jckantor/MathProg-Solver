

/* Loading CSV

table tname IN "CSV" fileurl option : idx <- [fld1, fld2, ..], 
       tname: symbolic name
    filename: file name
      option: if present, 

*/

# Load a csv table from a url within the same domain
set KEY;
param value{KEY};
table t1 IN "CSV" "examples/test.csv" "local": 
    KEY <- [Atom],
    value~amu;
    
# Loading a table from Google Spreadsheets



end;
