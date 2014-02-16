# Example: PortfolioMAD.mod  Portfolio Optimization using Mean Absolute Deviation

/* Stock Data */

set S;                                    # Set of stocks
param r{S};                               # Means of projected returns
param cov{S,S};                           # Covariance of projected returns
param r_portfolio
    default (1/card(S))*sum{i in S} r[i]; # Lower bound on portfolio return

/* Generate sample data */

/* Cholesky Lower Triangular Decomposition of the Covariance Matrix */
param c{i in S, j in S : i >= j} := 
    if i = j then
        sqrt(cov[i,i]-(sum {k in S : k < i} (c[i,k]*c[i,k])))
    else
        (cov[i,j]-sum{k in S : k < j} c[i,k]*c[j,k])/c[j,j];

/* Because there is no way to seed the PRNG, a workaround */
param utc := prod {1..2} (gmtime()-1000000000);
param seed := utc - 100000*floor(utc/100000);
check sum{1..seed} Uniform01() > 0;

/* Normal random variates */
param N default 5000;
set T := 1..N;
param zn{j in S, t in T} := Normal(0,1);
param rt{i in S, t in T} := r[i] + sum {j in S : j <= i} c[i,j]*zn[j,t];

/* MAD Optimization */

var w{S} >= 0;                # Portfolio Weights with Bounds
var y{T} >= 0;                # Positive deviations (non-negative)
var z{T} >= 0;                # Negative deviations (non-negative)

minimize MAD: (1/card(T))*sum {t in T} (y[t] + z[t]);

s.t. C1: sum {s in S} w[s]*r[s] >= r_portfolio;
s.t. C2: sum {s in S} w[s] = 1;
s.t. C3 {t in T}: (y[t] - z[t]) = sum{s in S} (rt[s,t]-r[s])*w[s];

solve;

/* Report */

/* Input Data */
printf "Stock Data\n\n";
printf "         Return   Variance\n";
printf {i in S} "%5s   %7.4f   %7.4f\n", i, r[i], cov[i,i];

printf "\nCovariance Matrix\n\n";
printf "     ";
printf {j in S} " %7s ", j;
printf "\n";
for {i in S} {
    printf "%5s  " ,i;
    printf {j in S} " %7.4f ", cov[i,j];
    printf "\n";
}

/* MAD Optimal Portfolio */
printf "\nMinimum Absolute Deviation (MAD) Portfolio\n\n";
printf "  Return   = %7.4f\n",r_portfolio;
printf "  Variance = %7.4f\n\n", sum {i in S, j in S} w[i]*w[j]*cov[i,j];
printf "         Weight\n";
printf {s in S} "%5s   %7.4f\n", s, w[s];
printf "\n";

table tab0 {s in S} OUT "JSON" "Optimal Portfolio" "PieChart": 
    s, w[s]~PortfolioWeight;
    
table tab1 {s in S} OUT "JSON" "Asset Return versus Volatility" "ScatterChart":
    sqrt(cov[s,s])~StDev, r[s]~Return;
    
table tab2 {s in S} OUT "JSON" "Portfolio Weights" "ColumnChart": 
    s~Stock, w[s]~PortfolioWeight;
    
table tab3 {t in T} OUT "JSON" "Simulated Portfolio Return" "LineChart": 
    t~month, (y[t] - z[t])~PortfolioReturn;

/* Simulated Return data in Matlab Format */
/*
printf "\nrt = [ ... \n";
for {t in T} {
   printf {s in S} "%9.4f",rt[s,t];
   printf "; ...\n";
}
printf "];\n\n";
*/

data;

/* Data for monthly returns on four selected stocks for a three
year period ending December 4, 2009 */

param N := 200;

param r_portfolio := 0.01;

param : S : r :=
    AAPL    0.0308
    GE     -0.0120
    GS      0.0027
    XOM     0.0018 ;

param   cov : 
            AAPL    GE      GS      XOM  :=
    AAPL    0.0158  0.0062  0.0088  0.0022
    GE      0.0062  0.0136  0.0064  0.0011
    GS      0.0088  0.0064  0.0135  0.0008
    XOM     0.0022  0.0011  0.0008  0.0022 ;

end;