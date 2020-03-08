*! 1.13  08 Mar 2020
program define restrand, rclass byable(recall)
  version 13
  syntax varlist(num fv) [if] [in], Constrain(numlist >=0) [Arms(int 2) SEed(int 0) n(int 0) SAmple(int 0) Count Verbose(int 0)]
  
  if (`arms' < 2){
     di as error "Number of arms < 2"
	         exit 459
  }  

  if (`n' < 0){
     di as error "n should be >= 0"
     exit 411
  }  

  if "`s(fvops)'" == "true" {
       fvexpand `varlist'  
       local varlist `r(varlist)'
  }

  local nvars: word count `varlist'
  local nres: word count `constrain'
  if (`nvars' != `nres'){
     di as error "Number of variables != number of constrain"
	         exit 459
  }

  marksample touse, novarlist 

  foreach v in `varlist' {
     qui count if missing(`v') & `touse'
     if r(N) > 0 error 416
  }
  
  qui count if `touse'
  if(r(N) < 2){
     exit 2001
  }
  if (`n' != 0 & r(N) < `arms' * `n'){
     di as error "Product of arms and obs per arm is < number of obs"
	         exit 459
  }
  
  /* change the seed (only in the first recall if used with by:) */ 
  if _byindex() == 1 {
	if _by() {
		local cmdline "by `_byvars':"   /* store by: part of command line */
	}
	local cmdline `cmdline' restrand `0'    /* store command line */
    	if (`seed' == 0){
		local timeseed = mod(Clock("$S_DATE $S_TIME" , "DMYhms")/1000, 10000000)
		set seed `timeseed'
		local timeseed = round(runiform() * 10000000)
		local seed = `timeseed'
		local cmdline `cmdline' seed(`seed')   /* store seed in command line if seed argument is 0*/
	}
	if (`seed' >= 0) set seed `seed'
	if (`seed' < 0) local cseed = c(seed)
	qui: cap gen _arm = .
	qui: sum _arm 
	if (r(N) > 0) di as smcl "Note: variable _arm exists and has non-missing values"  
	/* assign command line to variable label and note*/
	qui: label variable _arm "`cmdline'"
	qui: notes drop _arm 
	notes _arm : `cmdline' @ TS
	di as smcl as txt "{p}"
	if (`seed' >= 0) di as smcl "Seed set to: `seed'"  
	if (`seed' < 0) di as smcl "Seed remained unchanged"  
	di as smcl "{p_end}"
        return scalar seed = `seed' 	
	return local cseed "`cseed'"
  }

  mata: checkpermute("`varlist'", "`constrain'", `arms', `n', "`count'", `verbose', `sample', "`touse'")
  
  /* print means per arm */
  if (validseq > 0 & `verbose' >= 0) {
      qui: levelsof _arm, local(armlevels) 
      di %30s _newline " arm # "  _continue  
      foreach l of local armlevels{
             di  %9.0g = `l' _continue
      }   
      foreach v in `varlist' {
         local vtxt = substr("`v'", 1, 24)
         di %30s _newline  "mean `vtxt' "   _continue  
         foreach l of local armlevels {
             sum `v' if _arm == `l' & `touse', meanonly
             di %9.0g = r(mean) _continue  
         }
      }
  }
  if (validseq == 0)  di as error "No valid Sequence identified - relax constraints"
  return scalar Nvalidseq = validseq 
  return matrix diag diagnostic 
  return matrix alloc allocation     
end

version 13
mata:
void function checkpermute(string scalar varlist, 
                           string matrix constraints,
			   real scalar arms,
			   real scalar n,
			   string matrix asCount,
			   real scalar verbose,
			   real scalar nSample,
			   string scalar touse) 
{
	transmorphic info /* cvpermutesetup */ 
	real matrix rd, diagMat, meanMat, symDiag /* rd = data diagMat = diagnostics */ 
	real matrix allo, allocSeq, p
	real matrix ru /* single uniform random number */
	real rowvector covCon, difMean /* covCon = constraints as numbers */
	real scalar i, j, counter, misValue, rnd, valid 
	real scalar nObs, nPerArm, remain, nPerm, nValid, stopSeq 
	string displ, cnames, rnames, adv
	
	
	/* some basic calculations (obs per arm, ...) */
	covCon = strtoreal(tokens(constraints))
	rd = st_data(., varlist, touse)
	nObs = rows(rd)
	if(n == 0) {
		nPerArm = nObs/arms
		remain = mod(nObs, arms)
		/* calculate number of permutations (multinomial coefficient Nobs!/(N1! * ... * Nn!) */
		nPerm = round(exp(lnfactorial(nObs)),1)
		for (i = 1; i <= (arms-remain); i++) {
		    nPerm = nPerm/round(exp(lnfactorial(trunc(nPerArm))),1)
		}
	    for (i = 1; i <= remain; i++) {
		    nPerm = nPerm/round(exp(lnfactorial(ceil(nPerArm))),1)
		}
		remain = 0
	}
	if(n != 0) {
		nPerArm = n
		remain = nObs - n * arms
		/* calculate number of permutations (multinomial coefficient Nobs!/(N1! * ... * Nn!) */
		nPerm = round(exp(lnfactorial(nObs)),1)
		for (i = 1; i <= arms; i++) {
			nPerm = nPerm/round(exp(lnfactorial(nPerArm)),1)
		}
		nPerm = nPerm/round(exp(lnfactorial(remain)),1)
	}
	
	/* set up the initial allocation sequence (if possible with symmetry) */
	allo = J(1, 1, 1..nObs)
	allo = ceil(allo/nPerArm)
	allo = colshape(allo,1)  
	if(remain > 0) {
		misValue = arms/2+.1
		for (i = 1; i <= nObs; i++) {
			if(allo[i,1] > arms) allo[i,1] = misValue
		}
	}
	if((remain > 0 & mod(arms,2) == 1) | mod(nPerm, 2) == 1) {	
		stopSeq = nPerm	
	} else {
		printf("{txt}Note: half of potential allocation sequences are dropped because of symmetry.\n")
		stopSeq = nPerm/2
	}
	allo = sort(allo, 1)

	/* display some info */
	printf("{txt}Number of units to randomize: %f\n", nObs)
	printf("{txt}Number of trial arms: %f\n", arms)
	printf("{txt}Number of units per arm: %f\n", round(nPerArm, .1))
	printf("{txt}Number of permutations : %14.0f\n",  stopSeq)
	if(nSample > 0){
		printf("{txt}Number of random samples : %14.0f\n",  nSample)
	}
	if(nSample == 0 & stopSeq > 5000000){
		printf("{txt}Note: Many permutations - consider option 'sample'\n")
	}	
	stata(`"display `"Start time: $S_DATE $S_TIME"'"') 
 
	allocSeq = J(1, nObs, .) // initialisation of allocSeq to missing
	diagMat = J(nObs, nObs, 0) // initialisation of diagnostic matrix with 0's
	counter = 1
	nValid = 0
	
	/* allo' */ //start sequence
	
	/* random sample instead of all permutations */ 

	if(nSample > 0) {
		while (counter <= nSample) {
			p = jumble(allo)
			meanMat = J(arms, cols(rd),  .)
			for (i=1; i<=cols(rd); i++){
				for (j=1; j<=arms; j++){
					meanMat[j, i] = mean(rd[., i], (p:== j))
				}
			}
			difMean = colmax(meanMat)-colmin(meanMat) 
			valid = covCon - difMean 
          
			if(min(valid) >= 0) {   /* valid combination */
				nValid++
				ru = runiform(1,1)
				if(ru[1,1] < 1/nValid) { /* repace current seq by new sequence */
					allocSeq = p
				}
				for(i = 1; i <= nObs; i++){
					for(j = (i+1); j <= nObs; j++){
						if(p[i] == p[j]) diagMat[j,i] = diagMat[j,i]+1
					}
				}
			}	
			if(verbose > 0) {
				if(mod(counter, verbose)==0) {
					displ = " Seq " + strofreal(counter) + ": "
					for (i = 1; i <= nObs; i++) {
						if(p[i,1] == misValue) p[i,1] = .
						displ = displ + strofreal(p[i,1]) + " "
					}
					
					displ = displ + " Dif: "
					
					for(i = 1; i <= cols(meanMat); i++){
						
						displ = displ + strofreal(round(difMean[i], .01)) + " "
					}
					if(min(valid) >= 0){
						displ = displ + "balance\n" 
					} else {
						displ = displ + "imbalance\n" 
					}

					printf(displ)
				}
			} else {
				if(mod(counter, 10000)==0) {
					printf(". ")
					displayflush()
					if(mod(counter, 200000)==0){
						adv = strofreal(100 * counter/nSample, "%12.0f")  
						display(adv + "%; valid seq: " + strofreal(nValid))
					}
				}
			}	
		counter++
		}
	printf("\nNumber of allocation sequences satisfying constraints: %f\n", nValid)
	} else {
		
		info = cvpermutesetup(allo)
		while (counter <= stopSeq) {
			p = cvpermute(info)
			meanMat = J(arms, cols(rd),  .)
			for (i = 1; i <= cols(rd); i++) {
				for (j = 1; j <= arms; j++) {
					meanMat[j, i] = mean(rd[., i], (p:== j))
				}
			}
			difMean = colmax(meanMat)-colmin(meanMat) 
			valid = covCon - difMean 
			if(min(valid) >= 0) {
				nValid++
				ru = runiform(1,1)
				if(ru[1,1] < 1/nValid){
					allocSeq = p
				}
				for(i = 1; i <= nObs; i++){
					for(j = (i+1); j <= nObs; j++){
						if(p[i] == p[j]) diagMat[j, i] = diagMat[j, i]+1
					}
				}  
			}
			if(verbose > 0){
				if(mod(counter, verbose)==0) {
					displ = " Seq " + strofreal(counter) + ": "
					for (i = 1; i <= nObs; i++) {
						if(p[i,1] == misValue) p[i,1] = .
						displ = displ + strofreal(p[i,1]) + " "
					}
					
					displ = displ + " Dif: "
					
					for(i = 1; i <= cols(meanMat); i++){
						
						displ = displ + strofreal(round(difMean[i], .01)) + " "
					}
					if(min(valid) >= 0){
						displ = displ + "balance\n" 
					} else {
						displ = displ + "imbalance\n" 
					}

					printf(displ)
				}
			} else {
				if(mod(counter, 10000)==0) {
					printf(". ")
					displayflush()
					if(mod(counter, 200000)==0) {
						adv = strofreal(counter/stopSeq*100, "%12.0f")  
						display(adv + "%; Sequences satifying restrictions: " + strofreal(nValid))
					}
				}
			}	
		counter++
		}
	printf("\nNumber of allocation sequences satisfying constraints: %f\n", nValid)
	}		
	


	if(remain > 0) {
		for (i = 1; i <= nObs; i++){
			if(allocSeq[i] == misValue) allocSeq[i] = .
		}
	}
	
    /* shuffle arms to ensure randomness in case only half of all permutations have been invetigated */
	rnd = jumble(1::arms)
	
	for(i = 1; i <= nObs; i++){
		if(mod(allocSeq[i], 1) == 0){
			allocSeq[i] = rnd[allocSeq[i]]
		} else {
			allocSeq[i] = .
		}
	}

	if(nValid > 0){
		st_store(., "_arm", touse, allocSeq)
		printf("Randomly selected sequence:")
		allocSeq = colshape(allocSeq, nObs)
		cnames = J(nObs, 2, " ")
		rnames = J(1, 2, " ")
		_matrix_list(allocSeq, rnames, cnames)
	}
	
	/* diagnostics */  
	for(i=1; i<=nObs; i++){
			diagMat[i,i] = .
	}
	
	symDiag = makesymmetric(diagMat)
	
	if(nValid > 0 ){
	        if(verbose >= 0){
		   printf("\nDiagnostics:\n")
		   round(symDiag / nValid * 100)
                }
		if(strmatch(asCount, "")){
			symDiag = round(symDiag / nValid * 100, .1)
		}
	}	
	
	/* return scalar and diagnostic matrix to stata */
	st_numscalar("validseq", nValid)
	st_matrix("diagnostic", symDiag)
	st_matrix("allocation", allocSeq')
}
end
