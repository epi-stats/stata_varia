*! version 1.01 SRH 10 Jan 2018

program define randomlist
  version 14
  gettoken N 0 : 0, parse(" ,") 
  confirm integer number `N'
  if `N' <=0 error 411 
  syntax [, SEed(int 0) Arms(int 2) Blocksize(int 0) Maxblocksize(int 0) STrata(int 1) Clear]
  if ("`clear'" == ""){
     if (_N > 0) error 4     
  } 
  if ("`clear'" == "clear"){
     clear     
  }   
  if `strata' <=0 | `seed' < 0 error 411 
  if (`blocksize' > 0 & mod(`blocksize',`arms') != 0){
     display as error "Blocksize must be a multiple of arms"
	 exit
  }	
  if (`maxblocksize' > 0 &  mod(`maxblocksize',`blocksize') != 0){
     display as error "Maxblocksize must be a multiple of blocksize"
	 exit
  }	 
  if (`seed' == 0){
     local timeseed = mod(Clock("$S_DATE $S_TIME" , "DMYhms")/1000, 10000000)
	 set seed `timeseed'
	 local timeseed = round(runiform() * 10000000)
	 di "Seed set to: `timeseed'"
	 local seed = `timeseed'
  }	 
  if (`blocksize' == 0){
	    local setobs = `N' * `strata' * `arms' 
	    qui: set obs `setobs'
		gen id = _n
		if (`strata' > 1){
		   gen stratum = ceil(_n / (`arms' * `N')) 
		}
		gen arm = ceil(`arms' * uniform()) 
  }  
  if (`blocksize' > 0){
    if (`maxblocksize' == 0) local maxblocksize = `blocksize'
	local setobs = `N' * `strata' * `arms' +  `maxblocksize' * `strata'  
	qui: set obs `setobs'
    gen id = _n
	qui: gen block = .
    qui: gen stratum = . 
	local countN = 1
	local countB = 1
	/* local countS = 1 */
	forvalues i = 1/`strata' {
	local cont = 1
	  while (`cont' == 1){
       local bs = ceil(`maxblocksize'/`blocksize' * uniform()) * `blocksize' 
	   local toN = `bs' + `countN' - 1
	   qui: replace block = `countB' in `countN'/`toN'
	   qui: replace stratum = `i' in `countN'/`toN'  
	   qui: tab stratum if stratum == `i'
	   if (r(N) >= `N' * `arms'){
	     * local countS = `++countS'
		 local cont = 0
	   }	 
       local countB = `++countB'
	   local countN = `bs'+`countN'
	  }
	}  
    qui: drop if block == .
	gen rnd = runiform()
	bysort block: egen arm = rank(rnd) 
	lab var arm 
	qui: replace arm = mod(arm, `arms') + 1 
	drop rnd
	if (`strata' == 1) drop stratum
	}  
  qui: gen detail = "seed" in 1
  qui: gen value = `seed' in 1
  qui: replace detail = "N arms" in 2
  qui: replace value = `arms' in 2
  qui: replace detail = "code vers" in 3
  qui: replace value = 1.01 in 3
  if(`blocksize' > 0){
	  qui: replace detail = "blk size" in 4
	  qui: replace value = `blocksize' in 4
  }  
  if(`maxblocksize' > `blocksize'){
	qui: replace detail = "max blk" in 5
	qui: replace value = `maxblocksize' in 5
  }
end



