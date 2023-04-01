*! version 1.0 - 01Apr2023
program define logitforest
   syntax [varlist(default=none ts fv)] [, stored(str) DROPRef Omit(numlist) LABel(str) Foptions(str) COLVarti(str) COLORti(str) HEADer(str) OWNcol REFStr(str)]
   version 15
   if "`stored'" == "" & "`varlist'" == "" {
     di as error "either varlist or option stored has to be defined"
	         exit 100
   }
   if "`stored'" != "" & "`varlist'" != "" {
     di as error "varlist and option stored may not be combined"
	         exit 184
   }	
   
   /* check if a stored model should be used */
   if "`stored'" != "" {
   	  di "Using model estimates stored in `stored'"
   	  estimates replay `stored'
   }
   else {
   /* else run logistic regression */
   * NOTE: run on original scale not on OR scale
      logit `varlist'
   }
   
   * store regression table in matrix
   matrix res = r(table)'
   * matrix list res
   local catnames : colnames r(table)
   
   * replace data with regression table 
   preserve
   qui: clear
   qui: svmat res, names(col)
   qui: generate __label = ""
   tokenize "`catnames'"
   forvalues i = 1/`=_N' {
     qui: replace __label = "``i''" in `i'
   }	
   * drop the constant 	
   qui: drop if __label == "_cons"

   * change labels
   if "`label'" != "" {
   	  local nlab = wordcount("`label'")
	  local nlab2 = `nlab' / 2
	  tokenize "`label'"
      forvalues i = 1/`nlab2' {
	  	 local ilab = `i' * 2
	  	 local ipos = `i' * 2 -1		 
         qui: replace __label = "``ilab''" in ``ipos''
	  }	 
   }   
    
   * insert fake CI to include reference groups in the figure
   if "`dropref'" != "dropref" {
     qui: replace ll = -0.00001 if missing(ll)
     qui: replace ul =  0.00001 if missing(ul)
   }
   
   /* Convince Stata that the data are the result of a meta analysis */
   qui: meta set b ll ul, studylabel(__label)
   
   * make a text variable to set or-ci of reference groups to emty
   gen _orci = strofreal(exp(_meta_es), "%9.2f") + " [" + strofreal(exp(_meta_cil), "%9.2f") + "," + strofreal(exp(_meta_ciu), "%9.2f") + "]"
   qui: replace _orci = "`refstr'" if b == 0

   * omit referecne specified in options (set estimate to missing)
   if "`omit'" != "" {
      foreach i of local omit {
         qui: replace _meta_es = . if _meta_id == `i'
	  }	 
   }
   
   if "`colvarti'" == "" {
   	 local colvarti "Category"
   }
   if "`colorti'" == "" {
   	 local colorti "OR [95%CI]"
   }   
   
   /* check if some options are specified if not change the meta forest defaults */
   /* add a space in the beginning 
   (important if e.g. note or mark are specified in the beginning) */
   local foptions " `foptions'"
   
   /* check if markeropts are specified */
   local mopts = strpos("`foptions'", " mark")
   if `mopts' == 0 {
   	    local foptions "`foptions' mark(ms(D) msize(medium))"
   }
   /* check if refline is specified */
   local refline = strpos("`foptions'", " nullref")
   if `refline' == 0 {
   	    local foptions "`foptions' nullref"
   } 
   /* check if b1title("Odds Ratio") is specified */
   local b1 = strpos("`foptions'", " b1")
   if `b1' == 0 {
   	    local foptions "`foptions' b1title(odds ratio)"
   }   
   local note = strpos("`foptions'", " note")
   if `note' == 0 {
   	    local foptions `foptions' note(" ")
   }  
   
   di "`foptions'"
   if "`header'" == "" {
      qui: meta forestplot _id _plot _orci, eform ///
                 nooverall noohetstats noohomtest noosigtest nowmarkers /// 
				 columnopts(_id, title(`colvarti')) ///
				 columnopts(_orci, title(`colorti')) ///
                 `foptions'
   }
   
   if "`header'" != "" {

      qui: gen _groups = ""
	  tokenize "`header'"
      forvalues i = 1/`=_N' {
        qui: replace _groups = "``i''" in `i'
      }	
      
	  if "`owncol'" == "owncol" {

        forvalues i = `=_N'(-1)2 {
          qui: replace _groups = "" in `i' if _groups[`i'] == _groups[`i'-1] 
        }	
		
        replace _groups = `"{bf:"' + _groups + `"}"'		
		qui: meta forestplot _groups _id _plot _orci, eform ///
	             nogmarkers noghetstats nogwhomtests nogsigtests nogbhomtests ///
                 nooverall noohetstats noohomtest noosigtest nowmarkers /// 
				 columnopts(_id, title(`colvarti')) ///
				 columnopts(_orci, title(`colorti')) ///
				 columnopts(_groups, title(Variable) size(small)) ///
                 `foptions'	  
	  }
	  
	  if "`owncol'" != "owncol" {	  
      qui: meta forestplot _id _plot _orci, subgroup(_groups) eform ///
	             nogmarkers noghetstats nogwhomtests nogsigtests nogbhomtests ///
                 nooverall noohetstats noohomtest noosigtest nowmarkers /// 
				 columnopts(_id, title(`colvarti')) ///
				 columnopts(_orci, title(`colorti')) ///
                 `foptions'
				 
	  }
   }
   
   restore
end

