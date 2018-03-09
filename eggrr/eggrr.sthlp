{smcl}
{* *! version 1.01  09Mar2018}{...}
{vieweralsosee " [FN] Random-number functions" "help random number functions"}{...}
{viewerjumpto "Syntax" "restrand##syntax"}{...}
{viewerjumpto "Description" "restrand##description"}{...}
{viewerjumpto "Options" "restrand##options"}{...}
{viewerjumpto "Remarks" "restrand##remarks"}{...}
{viewerjumpto "Examples" "restrand##examples"}{...}

{title:Title}
{phang}
{bf:restrand} {hline 2}  Calculates egg reduction rates 

{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:logistic} {varlist}  {ifin} 
[{cmd:,} {it:options}] 

{synoptset 28 tabbed}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt r:eplicates(#)}} number of bootstrap replicates{p_end}
{synopt:{opt nob:oot}} don't construct bootstrap confidence intervals {p_end}
{synoptline}

{p2colreset}{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:eggrr} Calculates egg reduction rates based on geometric anrithmetric means. 
Confidence intervals are constructed via bootstrapping. Can be combined with {cmd:by}

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt replicates(#)} Number of bootstrap resamplings. Default is set to 5000.

{phang}
{opt noboot} Supress the bootstrap resampling. This option does only make sense if the command should be combined with number of treatments i.e. trial arms (default is 2).

{phang}
{opt seed(#)} the seed to initiate the pseudo random number generator. 
If 0 (the default) the current date  and time will be used to generate a number randomly. 
The same seed will generate the same randomisation list. Can be combined with {cmd:bootstrap}. 
The command's own bootstrap algorithm is much faster because it is implemented in MATA but Stata's native bootstrap offers more options.
See examples for details.

{phang}
{opt n(#)} the number of units to be randomized to each arm. 
If 0 (the default) as many units as possible will be randomized, which is trunc(_N/arms) per treatment group.


{marker remarks}{...}
{title:Remarks}

Calculates egg reduction rates based on geometric anrithmetric means. Often used in helminth research. The varlist should contain exactly 2 vaiables. 
The 1st represents baseline data and the 2nd after treatment data (follow-up).
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
{phang2}{cmd: keep if !missing(heatdd, cooldd)}{p_end}
{phang2}{cmd: bootstrap Gerr=r(err_gm), rep(1000): eggrr heatdd cooldd, noboot}{p_end}
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
