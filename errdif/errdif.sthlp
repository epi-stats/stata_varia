{smcl}
{* *! version 1.0  09Mar2018}{...}
{vieweralsosee " [R] bootstrap" "help bootstrap"}{...}
{viewerjumpto "Syntax" "errdif##syntax"}{...}
{viewerjumpto "Description" "errdif##description"}{...}
{viewerjumpto "Options" "errdif##options"}{...}
{viewerjumpto "Remarks" "errdif##remarks"}{...}
{viewerjumpto "Examples" "errdif##examples"}{...}

{title:Title}
{phang}
{bf:eggdif} {hline 2}  Calculates difference among 2 egg reduction rates 

{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:eggdif} {varlist}  {ifin} 
[{cmd:,} {it:options}] 

{synoptset 28 tabbed}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt a:rm(varname)}} numeric variable which defines the different treatment groups{p_end}
{synopt:{opt t:reat(#)}} numeric value indicating the new treatment group{p_end}
{synopt:{opt c:omp(#)}} numeric value indicating the comparator group{p_end}
{synoptline}

{p2colreset}{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:eggrr} Calculates egg reduction rates based on geometric anrithmetric means. 
Confidence intervals can be constructed using {cmd:bootstrap}. Can be combined with {cmd:by}

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt arm(varname)} Variable which indicates the different treatment arms. Usually data from a randomized trial.

{phang}
{opt treat(#)} The value of the variable used in option arm which specifies the group receiving the new treatment.

{phang}
{opt treat(#)} The value of the variable used in option arm which specifies the comparator treatment.

{marker remarks}{...}
{title:Remarks}

Calculates differences between 2 egg reduction rates based on geometric or arithmetic means. 
The varlist should contain exactly 2 vaiables. The 1st represents baseline data and the 2nd after treatment data (follow-up).
The geometric mean is calculated as:
exp(sum(log(X + 1))) - 1
Confidence intervals should be constructed with Stata's bootstrap algorithm with option strata (see examples).
Missing values in baseline or follow-up should either be dropped or excluded via if/in before bootstrapping.
{pstd}



{marker examples}{...}
{title:Examples}
{hline}
{pstd}Example with temperature data. For the bootstrap algorithm oiption strata should contain the tretment arm variable and  {p_end}
{phang2}{cmd: sysuse citytemp, replace}{p_end}
{phang2}{cmd: errdif heatdd cooldd, arm(region) treat(1) comp(4)}{p_end}
{phang2}{cmd: bootstrap GM=r(dif_gm) AM=r(dif_am), r(1000) str(region): errdif heatdd cooldd if !mi(heatdd, cooldd), a(region) t(1) c(4)}{p_end}
{phang2}{cmd: estat boot, all}{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:eggrr} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(Nt)}} Number of observations used in the treatment group{p_end}
{synopt:{cmd:r(Nc)}} difference in arithmetic mean ERR{p_end}
{synopt:{cmd:r(dif_gm)}} difference in geometric mean ERR{p_end}
{synopt:{cmd:r(dif_am)}} difference in arithmetic mean ERR{p_end}
{synoptset 20 tabbed}{...}


{p2colreset}{...}


{title:Author}
{phang}
{pstd}Jan Hattendorf, SwissTPH
