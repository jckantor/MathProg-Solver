/* # Saving for Retirement

Retirement savings is an often neglected priority in personal finance. This model
        demonstrates the computation of a simple savings plan over a professional career
        that accommodates several major expenditures in addition to meeting a savings target
        equal to eight times salary at retirement.

The model assumes a constant
        rate of inflation <span class="math">\(r_f\)</span>, a constant rate of
        return on investments <span class="math">\(r_i\)</span>, and a salary model
        <span class="math">\[S_k = \frac{(1+r_f)^k (\alpha + \beta k)}{1 + \beta k}S_{\infty}\]</span>
        where <span class="math">\(k\)</span> denotes year, <span class="math">\(S_{\infty}\)</span>
        the ultimate salary, <span class="math">\(\alpha\)</span> is the starting salary as
        a fraction of the ultimate salary, and <span class="math">\(\beta\)</span> is a
        constant with units of inverse time reflecting the relative speed of career growth.
        Examples of additional expenses is a provision to cover the college tuition expenses
        of several children.

The optimization objective is to determine a bound on the fraction of salary that 
        needs to be saved to meet the projected expenses.

An interesting exercise is to modify the model to include other expenses typical of
        a professional career, such as the purchase of real estate, and the management of
        personal debt. But be careful not to read too much into the results of this type of
        modeling. This model is deterministic while real life is not!
*/

/* Investment Parameters */
param T := 40;                    # time Horizon (years)
param Nper := 1*T;                # total number of periods
param Ri := 0.05;                 # annual investment return
param Rf := 0.03;                 # annual inflation (discount)
param Wi := 0;                    # initial wealth

/* calculated quantities */
set N := 0..Nper;                 # index set
param dT := T/Nper;               # time step
param t{n in N} := n*dT;          # time
param ri := Ri*dT;                # investment return/period
param rf := Rf*dT;                # inflation/period

/* salary model */
param salary{n in N} := (150000*(1+rf)**n)*(0.4+0.1*t[n])/(1+0.1*t[n]);

/* saving decision variables */
var w{N} >= 0;                    # wealth at the start of period n
var u{N} >= 0;                    # savings in period n
var fSave;                        # fraction of salary saved

/* what things are we saving for? */
set EXPENSES := {"TuitionA","TuitionB","TuitionC"};
var x{N,EXPENSES} >=0;

/* retirement goal: savings equal to 8 times salary */
s.t. Retirement: w[Nper] = 8*salary[Nper];

/* tuition: present value of 40000/year for each child */
s.t. TuitionA {n in 18/dT..21/dT}: x[n,"TuitionA"] = 40000*(1+rf)**n;
s.t. TuitionB {n in 20/dT..23/dT}: x[n,"TuitionB"] = 40000*(1+rf)**n;
s.t. TuitionC {n in 22/dT..25/dT}: x[n,"TuitionC"] = 40000*(1+rf)**n;

/* wealth accumulation */
s.t. IC: w[0] = Wi;
s.t. FC {n in 1..Nper}: w[n] = (1+ri)*(w[n-1] + u[n-1]) - sum{e in EXPENSES}x[n,e];

/* Objective: Minimize fraction of the salary that is saved */
s.t. MaxSavings {n in 0..Nper}: u[n] <= fSave*salary[n];

/* minimize present value of the savings plan */
minimize SaveFraction: fSave;

solve;

table tab0 {n in 0..Nper} OUT "JSON" "Projected Wealth" "LineChart": 
    n~Year, w[n]~Wealth;

table tab1 {n in 0..Nper} OUT "JSON" "Salary, Savings, and Expenses" "LineChart": 
    n~Year, 
    salary[n]~Salary,
    u[n]~Savings,
    sum{e in EXPENSES}x[n,e]~MajoExpenses;

/* print table of results */
printf "Savings as fraction of Salary: %6.4f \n\n", fSave;
printf "  n   Year  Savings   Salary   fSave   Wealth ";
printf {e in EXPENSES}: " %10s", e;
printf "\n\n";

for {n in 0..Nper} {
    printf "%3d  %5.2f  %7.0f %8.0f  %6.4f %8.0f %8.0f",
            n, n*dT, u[n], salary[n], u[n]/salary[n], w[n];
    printf {e in EXPENSES}: " %10.0f", x[n,e];
    printf "\n";
}

end;
