/* Chart Gallery
 The table driver GCHART creates charts using Google Chart Tools. The chart
 options are specified using the MathProg table syntax 
 
   table tname {x in X} OUT "GCHART" title chartType options : x~fld, y[x]~Y, ...
 
 where 
 
        title: A required string to be used a title of the chart
    chartType: An optional string specifying the chart type.  Consult the Google
               Chart Tools documentation for a list of valid types.
      options: An optional string in JSON format of options. Consult the Google
               Chart Tools for documentation.
 
 Consult the GMPL Language Reference for details regarding MathProg's table
 statement.
*/
      
# Line Chart
table t01 {x in 0..10 by 0.1} OUT "GCHART" "Mathematical Functions" "LineChart" : 
    x~Radians, sin(x), cos(x);

# Table
set MONTHS;
param Temp{MONTHS};
param Precip{MONTHS};
table t02 {m in MONTHS} OUT "GCHART" "Weather for International Falls, MN, USA" "Table":
    m~Month, Temp[m]~Temperature, Precip[m]~Precipitation;

# Column Chart with options
table t04 {m in MONTHS} OUT "GCHART" 
    "International Falls, MN, USA" 
    "ColumnChart" 
    "{vAxis: {title: 'Temperature (C)'}}" : 
    m~Month, (5/9)*(Temp[m]-32)~Temperature;
   
# Bar Chart
table t05 {m in MONTHS} OUT "GCHART" "International Falls, MN, USA" "BarChart" "{height: 400}":
    m~Month, Temp[m]~Temperature;

# Combo Chart with multiple options in a symbolic parameter
param cc_options symbolic := """
   { legend: {position: 'in'},
     seriesType: 'bars',
     vAxes: {0: {title: 'Temperature (F)'}, 
             1: {title: 'Precipitation (in)'}},
     series: {0: {type: 'bar'}, 
              1: {type: 'area', targetAxisIndex: 1}}
    }  """;
table tab6 {m in MONTHS} OUT "GCHART" "International Falls, MN, USA" "ComboChart" cc_options: 
    m~Month, 
    Temp[m]~Temperature,
    Precip[m]~Precipitation;
    
# Pie Chart
table t07 {m in {'Jun','Jul','Aug'}} OUT "GCHART" "Summer Precipitation" "PieChart" : 
    m~Month, Precip[m]~Precipitation;

# Scatter Chart with options in a symbolic parameter
param sc_options symbolic := """
    { vAxis: {title: 'Temperature (F)'},
      hAxis: {title: 'Precipitation (inches)'},
      height: 480, 
      width: 640 } """;
table t08 {m in MONTHS} OUT "GCHART" "Precipitation vs. Temperature" "ScatterChart" sc_options: 
    Temp[m]~Temperature,
    Precip[m]~Precipiation;
    
# Gauge with computed variables
set DATA := {'AveTemp (F)', 'AnnPrecip (in)'};
var x{DATA};
s.t. A: x['AveTemp (F)'] = (sum {m in MONTHS} Temp[m])/card(MONTHS);
s.t. B: x['AnnPrecip (in)'] = sum {m in MONTHS} Precip[m];
solve;
table tab9 {d in DATA} OUT "GCHART" "Annual Weather Summary" "Gauge" : d, x[d];
    
# Geo Chart for regions
set BRIC := {'Brazil','Russia','India','China'};
table tab10 {s in BRIC} OUT "GCHART" "BRIC Countries" "GeoChart" : s, Uniform(1,2)~Data;

# Geo Chart with markers
set ACC := {
   'Atlanta','Blacksburg','Boston','Chapel Hill','Charlottesville',
   'Clemson','College Park','Durham','Miami','Pittsburgh','Syracuse',
   'Raleigh','South Bend','Tallahassee','Winston-Salem'};
param g_options symbolic := """
    { region: 'US',
      displayMode: 'markers',
      colorAxis: {colors: ['green', 'blue']} }""";
table tab11 {s in ACC} OUT "GCHART" "Atlantic Coast Conference" "GeoChart" g_options: s;

data;

# Monthly Weather Data for International Falls, MN, USA
#   Temp: degrees F
#   Precip: inches
param : MONTHS : Temp Precip :=
      Jan       1.0      0.9
      Feb       7.7      0.6
      Mar      22.1      1.1
      Apr      39.0      1.6
      May      52.1      2.5
      Jun      61.4      3.9
      Jul      66.7      3.6
      Aug      63.7      3.1
      Sep      53.4      3.1
      Oct      42.4      2.0
      Nov      24.9      1.1
      Dec       7.2      0.8 ;
 
end;
