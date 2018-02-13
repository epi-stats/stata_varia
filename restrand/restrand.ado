
*! version 1.03 SRH 13 Feb 2018
program define restrand, rclass
  version 14
  syntax varlist(num) , Restriction(numlist) [Arms(int 2) SEed(int 0) n(int 0)]
  foreach v of varlist `varlist' {
     if missing(`v') error 416
  }
  local nvars: word count `varlist'
  local nres: word count `restriction'
  if (`nvars' != `nres'){
     di as error "Number of variables != number of restrictions"
	         exit 459
  }
  if (`seed' == 0){
     local timeseed = mod(Clock("$S_DATE $S_TIME" , "DMYhms")/1000, 10000000)
	 set seed `timeseed'
	 local timeseed = round(runiform() * 10000000)
	 local seed = `timeseed'
  }
   if (`n' != 0 & _N < `arms' * `n'){
     di as error "Product of arms and obs per arm is < number of obs"
	         exit 459
  } 
  di "Seed set to: `seed'"  
  set seed `seed'
  qui: gen _arm = .
  mata: checkpermute("`varlist'", "`restriction'", `arms', `n')
  return scalar seed = `seed' 
  return scalar Nvalidseq = validseq 
  return matrix diag diagnostic 
  
end

 
version 14
mata:
void function checkpermute(string scalar varlist, 
                           string matrix restrict,
						   real scalar arms,
						   real scalar n)
{
  real matrix rd, mdiag
  real rowvector rest, difmean
  real scalar i, j, k, m, count, nobs, nperarm, remain, nperm, nvalid
  
  /* same basic calculations obs per arm, etc */
  rest = strtoreal(tokens(restrict))
  rd = st_data(., varlist)
  nobs = rows(rd)
  if(n == 0){
    nperarm = floor(nobs/arms)
    remain = mod(nobs, arms)
  }
  if(n != 0){
    nperarm = n
    remain = nobs - n * arms
  } 
  nperm = exp(lnfactorial(nobs))
  for (i=1; i<=arms; i++){
    nperm = nperm/exp(lnfactorial(nperarm))
  }
  nperm = nperm/exp(lnfactorial(remain))

  /* set up the initial allocation sequence. If possible in a symmetric way */
  if(remain > 0 & mod(arms, 2) == 1){
    printf("Note: Algorithm can't identify duplicate sequences if (number of arms is odd and not all units are randomized).\n")
    allo = J(1, 1, 1..nobs)
    allo = ceil(allo/nperarm)
    allo = mm_cond(allo:> arms, 0, allo)
    allo = colshape(allo,1)
    stopseq = nperm
  } else 
  {
    printf("Note: half of potential allocation sequences are dropped because of symmetry.\n")
    allo = J(1, 1, 1..nobs)
    allo = ceil(allo/nperarm)
    allo = mm_cond(allo:> arms, arms/2+.05, allo)
    allo = colshape(allo,1)   
    allo = sort(allo, 1)
    allo = mm_cond(allo:== arms/2+.05, 0, allo)   
    stopseq = nperm/2
  }
  /* allo' */

  printf("Number of clusters to randomize: %f\n", nobs)
  printf("Number of trial arms: %f\n", arms)
  printf("Number of clusters per arm: %f\n", nperarm)
  printf("Number of permutation sequences : %14.0f\n",  stopseq) 
  stata(`"display `"Start time: $S_DATE $S_TIME"'"') 
 
  aseq = J(1, nobs, .)
  mdiag = J(nobs, nobs, 0)
  count = 1
  nvalid = 0
 
  /* if number of permuations is above 10 mio, assess only 3 mio random allocations */ 
  if(stopseq > 10000000){
    printf("Number of permutation sequences > 1e+07, 3'000'000 random sequences will be assessed instead\n")
    while (count <= 3000000) {
	  p = jumble(allo)
	  count++
      if (mod(count, 50000)==0) {
        printf(". ")
	    displayflush()
	  }
      if (mod(count, 500000)==0){
        adv = strofreal(count/30000, "%12.0f")  
        display(adv + "%; valid seq: " + strofreal(nvalid))
	  }
      mmeans = J(arms, cols(rd),  .)
      for (i=1; i<=cols(rd); i++){
        for (j=1; j<=arms; j++){
          mmeans[j, i] = mean(rd[., i], (p:== j))
        }
      }
      difmean = colmax(mmeans)-colmin(mmeans) 
      valid = rest - difmean 
      /* 
      if (mod(count, 100000)==0){     
	    display("details:")
	    p'
		mmeans
        difmean
        valid
        min(valid)
	   }
      */
      if(min(valid) >= 0){   /* valid combination */
      nvalid++
      ru = runiform(1,1)
	  if(ru[1,1] < 1/nvalid){ /* repace current seq by new sequence */
		aseq = p
	  }
	  for(k=1; k<=nobs; k++){
	    for(m=(k+1); m<=nobs; m++){
	      if(p[k] == p[m]) mdiag[m,k] = mdiag[m,k]+1
	    }
	  }  
    }
   }
   printf("\nNumber of allocation sequences satisfying restrictions: %f\n", nvalid)
  } else
  {
    info = cvpermutesetup(allo)
    while (count <= stopseq) {
	  p = cvpermute(info)
	  count++
	  if (mod(count, 50000)==0) {
		 printf(". ")
		 displayflush()
		 }
	  if (mod(count, 500000)==0){
		 adv = strofreal(count/nperm*100, "%12.0f")  
		 display(adv + "%; valid seq: " + strofreal(nvalid))
		  }
	  mmeans = J(arms, cols(rd),  .)
	  for (i=1; i<=cols(rd); i++){
		 for (j=1; j<=arms; j++){
		   mmeans[j, i] = mean(rd[., i], (p:== j))
		 }
	  }
	  difmean = colmax(mmeans)-colmin(mmeans) 
	  valid = rest - difmean 
	  /*
	  if (mod(count, 100000)==0){     
		 display("details:")
		 mmeans
		 difmean
		 valid
		 min(valid)
	  }
	  */ 
	  if(min(valid) >= 0){
		nvalid++
		ru = runiform(1,1)
		if(ru[1,1] < 1/nvalid){
			aseq = p
		}
		for(k=1; k<=nobs; k++){
		  for(m=(k+1); m<=nobs; m++){
		    if(p[k] == p[m]) mdiag[m,k] = mdiag[m,k]+1
		  }
		}  
	  }
    }
    printf("\nNumber of allocation sequences satisfying restrictions: %f\n", nvalid)
    /* shuffle arms to ensure randomness although only half of all permutations have been invetigated */
	nseq = aseq
	rs = jumble(1::arms)
	for(i = 1; i <= arms; i++){
	  nseq = mm_cond(aseq:== i, rs[i], nseq)
	}
	aseq = nseq
  }
  aseq = mm_cond(aseq:== 0, ., aseq) 
  /* allocation sequence to var _arm */
  st_store(.,"_arm", aseq)
  /* diagnostics */
  printf("Randomly selected sequence:\n")
  aseq = colshape(aseq, nobs)
  aseq
  for(i=1; i<=nobs; i++){
    mdiag[i,i] = .
  }
  smdiag = makesymmetric(mdiag)
  /* mdiag =  mm_cond(mdiag:== 0, ., mdiag) */

  round(smdiag / nvalid * 100)
  res =  round(smdiag / nvalid * 100, .1)
  /* return scalar and diagnostic matrix to stata */
  st_numscalar("validseq", nvalid)
  st_matrix("diagnostic", res)
}
end
