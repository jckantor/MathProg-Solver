/*  # Generating Random Numbers for a Multivariate Normal Distribution

Applications of optimization in finance and other fields often require
sampling of a multivariate normal distribution. We demonstrate a simple
technique for generating samples in GMPL. 

The data section defines an index set \\(I\\), population mean \\(\mu\{I\}\\),
and population covariance \\(\Sigma\{I,I\}\\).  Optionally the data section can
specify the number of samples to use in verifying the distribution.
*/

/*
Jeff Kantor 
December 4, 2009 
Revised: December 7, 2009 to add a 'seeding' of the PRNG
*/

/* Index Set */
set I;

/* Return and Covariance parameters */
param Mu {I};
param Sigma {I,I};

/* Simulation Parameters */
param N >= 1, default 50;
set T := 1..N;

/* Cholesky lower triangular decomposition */
param Chol{i in I, j in I : i >= j} := 
    if i = j then
        sqrt(Sigma[i,i]-(sum {k in I : k < i} (Chol[i,k]*Chol[i,k])))
    else
        (Sigma[i,j]-sum{k in I : k < j} Chol[i,k]*Chol[j,k])/Chol[j,j];

/* Because there is no way to seed the PRNG, a workaround */
param utc := prod {1..2} (gmtime()-1000000000);
param seed := utc - 100000*floor(utc/100000);
check sum{1..seed} Uniform01() > 0;

/* Compute Multivariate Normal Samples */
param z{i in I, t in T} := Normal(0,1);
param x{i in I, t in T} := Mu[i] + sum {j in I : i >= j} Chol[i,j]*z[j,t];

/* Compare sample with population statistics */
param xbar{i in I} := (1/card(T))*sum {t in T} x[i,t];
param Cov{i in I, j in I} := 
    (1/card(T))*sum {t in T} (x[i,t]-xbar[i])*(x[j,t]-xbar[j]);

/* Show results */
printf "POPULATION PARAMETERS\n\n";
printf "Mu\n";
printf {i in I} "%5s   %7.4f\n", i, Mu[i];

printf "\nSigma\n";
printf "     ";
printf {j in I} " %7s ", j;
printf "\n";
for {i in I} {
    printf "%5s  " ,i;
    printf {j in I} " %7.4f ", Sigma[i,j];
    printf "\n";
}

printf "\n\nSAMPLE STATISTICS (N = %d)\n\n",N;
printf "Mean\n";
printf {i in I} "%5s   %7.4f\n", i, xbar[i];

printf "\nCovariance\n";
printf "     ";
printf {j in I} " %7s ", j;
printf "\n";
for {i in I} {
    printf "%5s  " ,i;
    printf {j in I} " %7.4f ", Cov[i,j];
    printf "\n";
}

data;
/* Data from 3 years of monthly returns for four selected stocks. */

/* Index set I, and parameter Mu of population means */
param : I : Mu :=
    AAPL    0.0308
    GE     -0.0120
    GS      0.0027
    XOM     0.0018 ;

/* Positive Definite Sigma */
param   Sigma : 
            AAPL    GE      GS      XOM  :=
    AAPL    0.0158  0.0062  0.0088  0.0022
    GE      0.0062  0.0136  0.0064  0.0011
    GS      0.0088  0.0064  0.0135  0.0008
    XOM     0.0022  0.0011  0.0008  0.0022 ;

end;
