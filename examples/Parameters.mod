/* # Working with Parameters */

/* Define sets */

set STUDENTS;
set COURSES;

/* Declare Parameters */

param credits{c in COURSES} >= 0;
param schedules{s in STUDENTS, c in COURSES} binary;

/* Computed Parameter */

param loads{s in STUDENTS} := sum{c in COURSES} schedules[s,c]*credits[c];

/* Report Results */

printf "STUDENTS\n";
printf {student in STUDENTS} "  %-10s  %3d  \n",student,loads[student];

printf "\nCOURSES\n";
printf {c in COURSES} "  %s\n",c;
printf "\n\n";

/* Data Section */

data;

set STUDENTS := Alex Brian Carl Diane Emil Francine;
set COURSES  := Math English Chemistry Physics;

param credits :=
   Math         3
   English      3
   Chemistry    4
   Physics      5 ;

param schedules: Math English Chemistry Physics :=
   Alex     1   1   0   0
   Brian    0   0   1   1
   Carl     1   0   0   1
   Diane    0   1   1   1
   Emil     1   0   1   0
   Francine 0   1   1   0 ;

end;