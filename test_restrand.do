/*************************************
    testing stability and features of restrand 
    last update 08.03.2020
	Jan Hattendorf
***************************************/	

	
/* check 1: command should stop with error 109 if not all variables are numeric */ 	
clear
sysuse bpwide
gen a = "text"
/* set _rc to 0 */
cap: assert 1 == 1
cap: restrand sex a bp_before if mod(_n, 6)==2, constrain(0.1 0.1 0.1) seed(1103)
if _rc == 109 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 2: command should stop with error 416 if any missing */ 	
clear
sysuse bpwide
keep if mod(_n, 6)==2
replace sex = . in 1
/* set _rc to 0 */
cap: assert 1 == 1
cap: restrand sex bp_before , constrain(0.1 0.1) seed(1103)
if _rc == 416 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 3: command should not stop with error 416 if missing is excluded by [in] */ 	
clear
sysuse bpwide
keep if mod(_n, 7)==2
replace sex = . in 1
/* set _rc to 0 */
cap: assert 1 == 1
cap noisily: restrand sex bp_before in 2/`=_N', constrain(0.1 0.1) seed(1103) verb(-1)
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 4: command should not stop with error 416 if missing is excluded by [if] */ 	
clear
sysuse bpwide
keep if mod(_n, 7)==2
replace sex = . in 1
/* set _rc to 0 */
cap: assert 1 == 1
cap noisily: restrand sex bp_before if _n > 1, constrain(0.1 0.1) seed(1103) verb(-1)
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 5: command should not stop with error 459 if N variables != N constraints */ 	
clear
sysuse bpwide
keep if mod(_n, 7)==2
/* set _rc to 0 */
cap: assert 1 == 1
cap noisily: restrand sex bp_before, constrain(0.1 0.1 0.1) seed(1103) verb(-1)
if _rc == 459 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 6: command should not stop with error 459 if n * arms > _N */ 	
clear
sysuse bpwide
/* set _rc to 0 */
cap: assert 1 == 1
cap noisily: restrand sex bp_before, constrain(0.1 0.1) seed(1103) verb(-1) arms(11) n(11)
if _rc == 459 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 7: run plain command */ 	
clear
sysuse bpwide
keep if mod(_n, 9)==2
cap noisily: restrand bp_before, constrain(1) verbose(1) 
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 8: check formatting of mean output  */ 	
clear
qui: sysuse bpwide
qui: keep if mod(_n, 9)==2
gen  ABCDE6789012345678901234567890 = sqrt(2)
restrand bp_before sex ABCDE6789012345678901234567890, constrain(100 100 1) arms(7) sample(30000)


/* check 9: check that proportion of co-occurence is = (n - k) / (n * k - k) 
            if all sequences are valid */ 	
forvalues k = 2/4{
  local maxn = 10-2*`k'
  forvalues n = 2/`maxn'{
    local N = `n' * `k'
    clear
    qui: sysuse bpwide
    qui: keep if _n <= `N'
    cap: restrand sex, constrain(100) verbose(-1) arms(`k')
    matrix P = r(diag)
    local P = P[2, 1]
    di "N: `N', K: `k', Pobs: `P', Pcalc:" round((`N' - `k') / (`N' * `k' - `k')*100, .1)
    if (round(`P',.1) == round((`N' - `k') / (`N' * `k' - `k')*100, .1)) local pass "`pass' OK"
    else local pass "`pass' fail"
  }
 }

  
/* check 10: check error code 0 but error message if no sequence is valid */
clear
qui: sysuse bpwide
qui: keep if mod(_n, 9)==2
cap noisily: restrand bp_before sex, constrain(0 0) 
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 11: stratification with by: 
             code should continue even if there are strata with no valid sequence */
clear
qui: sysuse bpwide
qui: keep if mod(_n, 3)==2
cap noisily: bysort agegrp sex: restrand bp_before, constrain(1) 
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 12: check by combined with if */
clear
qui: sysuse bpwide
qui: keep if mod(_n, 6)==2
gen odd = mod(_n, 2)
cap noisily: bysort sex: restrand bp_before if odd == 1, constrain(1) 
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 13: check xi: 
             Number of constrains has to be 1-number of dummies */
clear
qui: sysuse bpwide
qui: keep if mod(_n, 8)==2
cap noisily: xi: restrand i.agegrp bp_before, constrain(0.1 0.1 1) seed(1103)
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"
/* see if result is the same with if */
matrix A = r(alloc)
tab agegrp _arm 


/* check 14: check xi: combined with if 
             Number of constrains has to be 1-number of dummies */
clear
qui: sysuse bpwide
cap noisily: xi: restrand i.agegrp bp_before if mod(_n, 8)==2, constrain(0.1 0.1 1) seed(1103)
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"

/* check if check 13 and 14 are comming to the same results */
local isdif = mreldif(A, r(alloc))
if "`isdif'" == "0" local pass "`pass' OK"
else local pass "`pass' fail"


/* check 15: check i. operator (without xi) 
             Number of constrains should equal number of dummies */
clear
qui: sysuse bpwide
qui: keep if mod(_n, 7)==1
cap noisily: restrand i.agegrp bp_before, constrain(0 0 0 1) seed(1103)
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"
tab agegrp _arm 
mean agegrp, over(_arm agegrp)

/* check 16: check i. operator (without xi) 
             Number of constrains should equal number of dummies */
clear
qui: sysuse bpwide
cap noisily: restrand i.agegrp bp_before if mod(_n, 7)==1, constrain(0.1 0.1 0.1 1) seed(1103)
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"
tab agegrp _arm 


/* check 17: check i. operator with by and if
             Number of constrains should equal number of dummies */
clear
qui: sysuse bpwide
cap noisily: bysort sex: restrand i.agegrp bp_before if mod(_n, 5)==1, constrain(0.1 0.1 0.1 1) seed(1103)
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"
tab agegrp _arm 


/* check 18: check diverse nonsense values in the options */
clear
qui: sysuse bpwide
keep if mod(_n, 6) == 1
cap noisily: restrand bp_before, constrain(1) seed(1103) arms(1)
if _rc == 459 local pass "`pass' OK"
else local pass "`pass' fail"
cap noisily: restrand bp_before, constrain(1) seed(1103) n(-1)
if _rc == 411 local pass "`pass' OK"
else local pass "`pass' fail"
cap noisily: restrand bp_before, constrain(1) seed(1103) n(2.4) 
if _rc == 198 local pass "`pass' OK"
else local pass "`pass' fail"
cap noisily: restrand bp_before, constrain(1)  seed(2.45) 
if _rc == 198 local pass "`pass' OK"
else local pass "`pass' fail"
cap noisily: restrand bp_before, constrain(-1) seed(1103) seed(2.45) 
if _rc == 125 local pass "`pass' OK"
else local pass "`pass' fail"
cap noisily: restrand bp_before if _n < 1, constrain(1) seed(1103) 	
if _rc == 2001 local pass "`pass' OK"
else local pass "`pass' fail"	
cap noisily: restrand bp_before if sex > 2 , constrain(1) seed(1103) 	
if _rc == 2001 local pass "`pass' OK"
else local pass "`pass' fail"	


/* check 19: check that option count works */
clear
qui: sysuse bpwide
keep if mod(_n, 7) == 1
cap noisily: restrand bp_before, constrain(5) seed(1103) count verb(-1)
matrix P = r(diag)
local isTrue = P[2, 1] > 100  	
if "`isTrue'" == "1" local pass "`pass' OK"
else local pass "`pass' fail"
cap noisily: restrand bp_before, constrain(5) seed(1103) count verb(0)
matrix P = r(diag)
local isTrue = P[2, 1] > 100  	
if "`isTrue'" == "1" local pass "`pass' OK"
else local pass "`pass' fail"
cap: restrand bp_before, constrain(5) seed(1103) count verb(1)
matrix P = r(diag)
local isTrue = P[2, 1] > 100  	
if "`isTrue'" == "1" local pass "`pass' OK"
else local pass "`pass' fail"


/* check 20: check option seed */
clear
qui: sysuse bpwide
keep if mod(_n, 8) == 1
cap: restrand bp_before, constrain(5) seed(0) 
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"
cap: restrand bp_before, constrain(5) seed(-5)
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 21: pseudo pair matching 
             note has not really practical implication
			 would include all covariates in PSM for pairing*/
clear
qui: sysuse bplong
keep if patient <= 8
cap noisily: restrand i.patient bp, constrain(0 0 0 0 0 0 0 0 5) seed(1103) 
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"


/* check 22: multi arm and n */
clear
qui: sysuse bpwide
keep in 1/22
cap noisily: restrand bp_before, constrain(5) seed(1103) arms(4) n(4) sample(30000)	
if _rc == 0 local pass "`pass' OK"
else local pass "`pass' fail"
keep in 1/10
cap noisily: restrand bp_before, constrain(5) seed(1103) arms(3) n(3) 
tab _arm
	

/* check 23: check that it is a random allocation if all sequences are valid*/	
clear
sysuse bpwide
keep in 1/7
restrand bp_before, con(50) arms(2) 
di r(Nvalidseq)
set matsize 800
matrix a = J(800, 7, 0)
forvalues i = 1/800{
 qui restrand bp_before, con(50) arms(2) verb(-1) seed(`i')
 matrix a[`i',1] = r(alloc)' 
 }
 svmat a
 forvalues i = 1/7{
    table a`i'
 }
 			
			
/* check 24: parallel processing 
             Note: no _rc code returned if the process fails! */
capture which parallel
if _rc==111 {
   local pass "`pass' unknown"
}   
else {
 clear
 qui: sysuse bpwide
 qui: keep if mod(_n, 2)==1
 gen odd = mod(_n,2) == 1
 parallel setclusters 3
 sort agegrp sex
 parallel, by(agegr) seed(21031 41031 31031): by agegr : restrand bp_before, constr(2) arms(2) seed(-1) 
 tab _arm
 cap drop _arm
 sort agegrp sex
 parallel, by(agegrp sex) seed(1 2 3): by agegrp sex: restrand bp_before, constr(2) arms(2) seed(-1) 
 mean bp_before, over(agegrp sex _arm)
 sort sex
 cap drop _arm
 parallel setclusters 2
 parallel, by(sex) seed(21031 41031): by sex: restrand i.agegrp bp_before if odd==1, constr(0.2 0.2 0.2 2) arms(2) seed(-1) 
 tab _arm
 }  

	
di "`pass'"
