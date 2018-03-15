*! version 1.04 - 15Mar2018
program define errdif, rclass 
   version 13
   syntax varlist(min=2 max=2 numeric) [if] [in], Arm(varname) Treat(int) Comp(int) 
   confirm numeric var `arm' 
   marksample touse
   local bl:  word 1 of `varlist'
   local fu:  word 2 of `varlist'
   qui: count if `bl' == 0 & `touse'
   if r(N) > 0 display "Warning: zero-egg-counts at baseline detected"
   cap assert `bl' >= 0 & `fu' >= 0 if `touse' & (`arm' == `treat' | `arm' == `comp')
   if _rc {
     display as error "negative values in `bl' and/or `fu' encountered"
     exit 411
   }   
   qui ameans `bl' if `arm' == `treat' & `touse', add(1) 
   local gmtbl = r(mean_g) - 1 
   local amtbl = r(mean) - 1 
   qui ameans `fu' if `arm' == `treat' & `touse', add(1)     
   local gmtfu = r(mean_g) - 1 
   local amtfu = r(mean) - 1 
   local errgmt = 1 - `gmtfu'/`gmtbl' 
   local erramt = 1 - `amtfu'/`amtbl'    
   qui ameans `bl' if `arm' == `comp' & `touse', add(1) 
   local gmcbl = r(mean_g) - 1 
   local amcbl = r(mean) - 1 
   qui ameans `fu' if `arm' == `comp' & `touse', add(1)     
   local gmcfu = r(mean_g) - 1 
   local amcfu = r(mean) - 1 
   local errgmc = 1 - `gmcfu'/`gmcbl' 
   local erramc = 1 - `amcfu'/`amcbl'
   local difgm = `errgmt' - `errgmc'
   local difam = `erramt' - `erramc'
   display as result "geometric mean `arm': `treat' - BL:" round(`gmtbl', .1) ", FU:" round(`gmtfu', .1) ", ERR:" round(100 * `errgmt', .01) "%"
   display as result "geometric mean `arm': `comp' - BL:" round(`gmcbl', .1) ", FU:" round(`gmcfu', .1) ", ERR:" round(100 * `errgmc', .01) "%"
   display as result "Abs. diff ERRs (geometric mean): " round(100 * `difgm', .01) "%"
   display as result "arithmetic mean `arm': `treat' - BL:" round(`amtbl', .1) ", FU:" round(`amtfu', .1) ", ERR:" round(100 * `erramt', .01) "%"
   display as result "arithmetic mean `arm': `comp' - BL:" round(`amcbl', .1) ", FU:" round(`amcfu', .1) ", ERR:" round(100 * `erramc', .01) "%"
   display as result "Abs. diff ERRs (arithmeticmean): " round(100 * `difam', .01) "%" 
   return scalar dif_gm = `difgm' * 100
   return scalar dif_am = `difam' * 100
end  
