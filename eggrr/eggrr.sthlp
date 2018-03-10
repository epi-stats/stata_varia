{smcl}
{* *! version 1.02  09Mar2018}{...}
{vieweralsosee " [R] bootstrap" "help bootstrap"}{...}
{viewerjumpto "Syntax" "eggrr##syntax"}{...}
{viewerjumpto "Description" "eggrr##description"}{...}
{viewerjumpto "Options" "eggrr##options"}{...}
{viewerjumpto "Remarks" "eggrr##remarks"}{...}
{viewerjumpto "Examples" "eggrr##examples"}{...}

{title:Title}
{phang}
{bf:eggrr} {hline 2}  Calculates egg reduction rates 

{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:eggrr} {varlist}  {ifin} 
[{cmd:,} {it:options}] 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt r:eplicates(#)}} number of bootstrap replicates{p_end}
{synopt:{opt nob:oot}} omit bootstrap confidence intervals {p_end}
{synoptline}

{p2colreset}{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:eggrr} Calculates egg reduction rates based on geometric or arithmetic means. 
Confidence intervals are constructed via bootstrapping. Can be combined with {cmd:by}

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt replicates(#)} Number of bootstrap resamplings. Default is set to 5000.

{phang}
{opt noboot} Omit the bootstrap resampling. 
This option is usually used if Stata's native bootstrap algorithm should be used which is much slower but offers different types bootstrap CIs.
See examples for details.


{marker remarks}{...}
{title:Remarks}

Calculates egg reduction rates based on geometric anrithmetric means.
The varlist should contain exactly 2 vaiables. 
The 1st represents baseline measurements and the 2nd after treatment data (follow-up).
The geometric mean is calculated as:
exp(sum(log(X + 1))) - 1

{pstd}



{marker examples}{...}
{title:Examples}
{hline}
{pstd}Example with temperature data{p_end}
{phang2}{cmd: sysuse citytemp, replace}{p_end}
{phang2}{cmd: eggrr heatdd cooldd}{p_end}
{phang2}{cmd:  bysort region: eggrr heatdd cooldd}{p_end}
{hline}
{pstd}Example using Stata's bootstrap algorithm{p_end}
{phang2}{cmd: sysuse citytemp, replace}{p_end}
{phang2}{cmd: bootstrap GM=r(err_gm), rep(1000): eggrr heatdd cooldd if !mi(heatdd, cooldd), noboot}{p_end}
{phang2}{cmd: estat boot, all}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:eggrr} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}} Number of observation used{p_end}
{synopt:{cmd:r(err_gm)}} geometric mean ERR{p_end}
{synopt:{cmd:r(err_am)}} arithmetric mean ERR{p_end}
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(quant)}} 2.5, 50, and 97.5% quantiles (only if noboot is not specified){p_end}


{p2colreset}{...}


{title:Author}
{phang}
{pstd}Jan Hattendorf, SwissTPH
