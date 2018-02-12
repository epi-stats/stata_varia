

*! version 1.01 SRH 10 Jan 2018
program define restrand, rclass
  version 14
  syntax varlist(num) , Restriction(numlist) [Arms(int 2) SEed(int 0)]
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
	 di "Seed set to: `timeseed'"
	 local seed = `timeseed'
  }
  qui: gen _arm = .
  mata: checkpermute("`varlist'", "`restriction'", `arms')
  return matrix diag diagnostic 
end

 
version 14
mata:
void function checkpermute(string scalar varlist, 
                           string matrix restrict,
						   real scalar arms)
{
 real matrix rd
 real rowvector rest
 real rowvector difmean
 real scalar count
 rest = strtoreal(tokens(restrict))
 rd = st_data(., varlist)
 nobs = rows(rd)
 narm = floor(nobs/arms)
 remain = mod(nobs, arms)

 nperm = exp(lnfactorial(nobs))
 for (i=1; i<=arms; i++){
   nperm = nperm/exp(lnfactorial(narm))
 }
 nperm = nperm/exp(lnfactorial(remain))

 display("Number of clusters to randomize: " + strofreal(nobs))
 display("Number of trial arms: " + strofreal(arms))
 display("Number of clusters per arm: " + strofreal(narm))
 display("Number of permutation sequences (incl duplicates): " + strofreal(nperm))
  
 allo = J(1,1,1..nobs)
 allo = ceil(allo/narm)
 allo = mm_cond(allo:> arms, 0, allo)
 allo = colshape(allo,1)
 /* allo */

 aseq = J(1, nobs, .)
 mdiag = J(nobs, nobs, 0)
 count = 0
 nvalid = 0
 info = cvpermutesetup(allo)
 while ((p = cvpermute(info)) != J(0,1,.)) {
   count++
   if (mod(count, 50000)==0) stata(`"display ".", _cont"')   
   if (mod(count, 500000)==0){
      adv = strofreal(count/nperm*100, "%9.2g")  
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
   if (mod(count, 10000000)==0){     
     display("details:")
	 mmeans
     difmean
     valid
     min(valid)
	 }
   */	 
   if(min(valid) >= 0){
     /* display("valid combination") */
     nvalid++
     ru = runiform(1,1)
	 if(ru[1,1] < 1/nvalid){
        /* display("new combination") */
		aseq = p
		/* aseq */
	 }
	 for(k=1; k<=nobs; k++){
	   for(m=k; m<=nobs; m++){
	      if(p[k] == p[m]) mdiag[m,k] = mdiag[m,k]+1
	   }
	 }  
  }
 }
 
 /* st_addvar("int","_arm") */
 st_store(.,"_arm", aseq)
 display("")
 display("Number of allocation sequences satisfying restrictions: " + strofreal(nvalid))
 display("Randomly selected sequence:")
 aseq = colshape(aseq, nobs)
 aseq
 display("Diagnostics:")
 round(mdiag / nvalid * 100)
 res =  round(mdiag / nvalid * 100, 2)
 st_matrix("diagnostic", res)
}
end
 



