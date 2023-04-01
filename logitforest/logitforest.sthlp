{smcl}
{*! version 1.0  1Apr2023}{...}
{vieweralsosee "help meta forestplot"}{...}
{viewerjumpto "Syntax" "errdif##syntax"}{...}
{viewerjumpto "Description" "errdif##description"}{...}
{viewerjumpto "Options" "errdif##options"}{...}
{viewerjumpto "Remarks" "errdif##remarks"}{...}
{viewerjumpto "Examples" "errdif##examples"}{...}

{title:Title}
{phang}
{bf:logitforest} {hline 2}  Generates forest plot after logistic regression 

{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:logitforest} {varlist}   
[{cmd:,} {it:options}] 

{synoptset 28 tabbed}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt stored(str)}} use a stored logistic regression model {p_end}
{synopt:{opt dropr:ef}} omit reference groups{p_end}
{synopt:{opt O:mit(numlist)}} omit estimates at the position provided in numlist {p_end}
{synopt:{opt lab:el(str)}} plovide new category labels {p_end}
{synopt:{opt f:options(str)}} further options passed to meta forestplot {p_end}
{synopt:{opt colv:arti(str)}} title of the variable column {p_end}
{synopt:{opt color:ti(str)}} title of the OR 95% CI column {p_end}
{synopt:{opt head:er(str)}} adding group category names {p_end}
{synopt:{opt own:col(str)}} group category names should be shown in aseparate column {p_end}
{synopt:{opt ref:str(str)}} the text which should be shown for reference groups in column OR 95% CI {p_end}
{synoptline}

{p2colreset}{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:logitforest} Plots a forest plot style graphic showing the estimates from a logistic regression.
You can either run the logistic regression directly via specifying varlist or you can used previously stored 
estimates ond speciy the name of the stored model in option stored.
You have either to specify varlist or stored! 

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt stored(str)} Stored model estimates. Model estimates have to be stored on original log(OR) scale.

{phang}
{opt dropref} Do not show reference categories.

{phang}
{opt omit(numlist)} Omit cetain estimates. The position of the estimates to drop are those in varlist.

{phang}
{opt label(str)}  Change some of the labels e.g. '1 yes 2 no' changes the first category name to yes ... NO SPACES ALLOWED!

{phang}
{opt fopitons(str)}  Any further options passed forward to meta forestplot. Should not contain double quotes.

{phang} 
{opt colvarti(str)} Title of the variable column (default is Category)

{phang} 
{opt colorti(str)} Title of the variable column (default is OR [95%CI])

{phang} 
{opt header(str)} To specify header for categories. Number of words must be equal to the number of estimates! NO SPACES ALLOWED!

{phang} 
{opt owncol} Should the header be shown in a seperate columnopts


{marker remarks}{...}
{title:Remarks}

{cmd:logitforest} calls internally the command meta forestplot. 
Almost all options available  for meta forestplot can be specified in the option foptions.
{pstd}




{marker examples}{...}
{title:Examples}
{hline}
{pstd}logistic regression with 'married' as outcome{p_end}
{phang2}{cmd: sysuse nlsw88, replace}{p_end}
{phang2}{cmd: logitforest married age i.race i.collgrad i.south c_city}{p_end}
{phang2}{it:({stata "gr_example nlsw88: logitforest married age i.race i.collgrad i.south c_city": click to run})}{p_end}
{hline}
{pstd}Some options passed to meta forestplot{p_end}
{phang2}{cmd: sysuse nlsw88, replace}{p_end}
{phang2}{cmd: logitforest married age i.race i.collgrad i.south c_city, foption(xlabel(0.2 0.5 1 2 5, format(%9.2g)))}{p_end}
{phang2}{it:({stata "gr_example nlsw88: logitforest married age i.race i.collgrad i.south c_city, foption(xlabel(0.2 0.5 1 2 5, format(%9.2g)))": click to run})}{p_end}
{hline}
{pstd}Using own category labels{p_end}
{phang2}{cmd: sysuse nlsw88, replace}{p_end}
{phang2}{cmd: logitforest married age i.race i.south c_city, label(2 white 3 black 4 other 5 north 6 south 7 city) }{p_end}
{phang2}{it:({stata "gr_example nlsw88: logitforest married age i.race i.south c_city, label(2 white 3 black 4 other 5 north 6 south 7 city)": click to run})}{p_end}
{hline}
{pstd} using stored estimates {p_end}
{phang2}{cmd: sysuse nlsw88, replace}{p_end}
{phang2}{cmd: logit married age i.race i.collgrad i.south c_city}{p_end}
{phang2}{cmd: estimates store mymodel}{p_end}
{phang2}{cmd: logitforest, stored(mymodel)}{p_end}
{hline}
{pstd} foptions can be stored in a local macro {p_end}
{phang2}{cmd: sysuse nlsw88, replace}{p_end}
{phang2}{cmd: local opts "nullrefline(favorsleft('tx better') favorsright('placebo better')) markeropts(msymbol(o) mcol(red) mlcolor(blue) msize(medsmall)) crop(0.25, 4) ciopts(lpat(dash) lwi(thin) lcol(orange)) xlabel(0.25 0.5 1 2 4, format(%9.2g)) itemopt(size(small)) caption(nice plot) b1title(odds ratio)"}{p_end}
{phang2}{cmd: logitforest, stored(mymodel) f(`opts') }{p_end}
{hline}

{marker results}{...}



{p2colreset}{...}


{title:Author}
{phang}
{pstd}Jan Hattendorf, SwissTPH
