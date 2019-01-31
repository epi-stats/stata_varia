*! version 1.05 - 31Jan2019
program define eggrr, rclass sortpreserve byable(recall)
  version 13
  syntax varlist(min=2 max=2 numeric) [if] [in] [, Replicates(int 5000) NOBoot]
  marksample touse
  local bl:  word 1 of `varlist'
  local fu:  word 2 of `varlist'
  di "Baseline var: `bl', Follow-up var: `fu'"
  qui: count if `bl' == 0 & `touse'
  if r(N) > 0 display "Warning: zero-egg-counts at baseline detected"
  cap assert `bl' >= 0 & `fu' >= 0 if `touse' 
  if _rc {
     display as error "negative values in `bl' and/or `fu' encountered"
     exit 411
  }   
  qui: ameans `bl' if `touse' , add(1) 
  local g1 = r(mean_g) - 1 
  local a1 = r(mean) - 1 
  qui: ameans `fu' if `touse' , add(1) 
  local g2 = r(mean_g) - 1 
  local a2 = r(mean) - 1 
  local errgm = (1 - `g2'/`g1') * 100 
  local erram = (1 - `a2'/`a1') * 100 
  if("`noboot'" == "") mata: bootegg("`varlist'", "`touse'", `replicates')  
  di as result "Geometric mean ERR: " round(`errgm', .01) " (BL:" round(`g1',.1) ", FU: " round(`g2',.1) ")"
  di as result "Arithmetic mean ERR: " round(`erram', .01) " (BL:" round(`a1',.1) ", FU: " round(`a2',.1) ")"
  quietly count if `touse'
  return scalar N = r(N)
  return scalar err_gm = `errgm'
  return scalar err_am = `erram'
  if("`noboot'" == ""){
    matrix colnames quantiles = gm_err am_err
    matrix rownames quantiles = q025 q50 q975
    matrix list quantiles
    return matrix quant quantiles 
  }
end

version 13
mata:
void function bootegg(string scalar varlist, string scalar touse, real scalar loops)
{
  real matrix egg, bootmat
  st_view(egg=., ., tokens(varlist), touse)
  N = rows(egg)
  bootmat = J(loops,2,.) 
  for (i=1 ; i <= loops; i++){
	  draw = ceil(runiform(N,1):*N)	
	  begg = egg[draw,.]
	  amerr = 1-mean(begg[,2])/mean(begg[,1])
	  bootmat[i,2] = amerr
	  begg = begg:+1
	  gmerr = 1-(exp(sum(log(begg[,2]))/N)-1)/(exp(sum(log(begg[,1]))/N)-1)
	  bootmat[i,1] = gmerr

  }
  // Code below to remove dependency on moremata (mm_quantile) can't find the source code  
  q = J(3,2,.)
  _sort(bootmat, 1)
  if (loops * 0.025 == trunc(loops * 0.025)) {
      q[1,1] = bootmat[loops * 0.025, 1]
      q[3,1] = bootmat[loops * 0.975, 1]
  } 
  else {
      q[1,1] = (bootmat[trunc(loops * 0.025), 1] + bootmat[trunc(loops * 0.025)+1, 1])/2
      q[3,1] = (bootmat[trunc(loops * 0.975), 1] + bootmat[trunc(loops * 0.975)+1, 1])/2	 
  }
  if (loops * 0.5 == trunc(loops * 0.5)) {
      q[2,1] = bootmat[loops * 0.5,1]
  } 
  else {
      q[2,1] = (bootmat[trunc(loops * 0.5), 1] + bootmat[trunc(loops * 0.5)+1, 1])/2
  }  
    _sort(bootmat, 2)
  if (loops * 0.025 == trunc(loops * 0.025)) {
      q[1,2] = bootmat[loops * 0.025, 2]
      q[3,2] = bootmat[loops * 0.975, 2]
  } 
  else {
      q[1,2] = (bootmat[trunc(loops * 0.025), 2] + bootmat[trunc(loops * 0.025)+1, 2])/2
      q[3,2] = (bootmat[trunc(loops * 0.975), 2] + bootmat[trunc(loops * 0.975)+1, 2])/2	 
  }
  if (loops * 0.5 == trunc(loops * 0.5)) {
     q[2,2] = bootmat[loops * 0.5, 2]
  } 
  else {
     q[2,2] = (bootmat[trunc(loops * 0.5), 2] + bootmat[trunc(loops * 0.5)+1, 2])/2
  }  
  // mm_quantile(bootmat, 1, (0.025 \ 0.5 \ 0.975))
  st_matrix("quantiles", q)
}
end 
