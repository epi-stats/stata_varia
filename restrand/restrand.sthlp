{smcl}
{* *! version 1.02  13Feb2018}{...}
{vieweralsosee " [FN] Random-number functions" "help random number functions"}{...}
{viewerjumpto "Syntax" "randomlist##syntax"}{...}
{viewerjumpto "Description" "randomlist##description"}{...}
{viewerjumpto "Options" "randomlist##options"}{...}
{viewerjumpto "Remarks" "randomlist##remarks"}{...}
{viewerjumpto "Examples" "randomlist##examples"}{...}

{title:Title}
{phang}
{bf:restrand} {hline 2}  Preforms restricted randomization

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:restrand} {varlist} 
{cmd:,} {it:restrictions(numlist)}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt r:estrictions(numlist)}} the restrictions used for the randomization{p_end}
{synopt:{opt a:rms(#)}} number of treatments {p_end}
{synopt:{opt se:ed(#)}} set seed for pseudo random number generation{p_end}
{synopt:{opt n(#)}} number of units to randomize to each arm{p_end}
{synoptline}

{p2colreset}{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:randomlist} generates a dataset with a random allocation list for clinical trials. 
Performs restricted randomization. From all potential allocation sequences only those are selected, whoich satisfy some pre specified conditions.

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt restriction(#)} the restrictions used for the randomization, i.e. the mean difference between the arms of the corresponding variable should be lower than the specified restriction. the number of values must equal the number of variables specified.


{phang}
{opt arms(#)} the number of treatments i.e. trial arms (default is 2).

{phang}
{opt seed(#)} the seed to initiate the pseudo random number generator. 
If 0 (the default) the current date  and time will be used to generate a number randomly. 
The same seed will generate the same randomisation list.

{phang}
{opt n(#)} the number of units to be randomized to each arm. 
If 0 (the default) as many units as possible will be randomized, which is trunc(_N/arms) per treatment group.


{marker remarks}{...}
{title:Remarks}

{pstd}
This procedure performs a pseudo-random selection from a list of acceptable allocations in a way that ensures balance on relevant covariates. 
The current random seed will be modified independent if option {cmd:seed} is specified or not.
A new variable _arm will be generated. The command will stop with an error if a varibale with this name already exists.
Stratification can be implemented if the restriction for a categorical variable is set to 0 and the values of the categories are suitable.
However, because of the high number of invalid sequences this approch might be inefficient (although the function is implemented in the faster Mata language).
It is usually better to generate allocation sequences for each stratum seperately, because also the restrictions have to be fulfilled within each stratum. 
Missing values are not allowed in any of the variables specified in varlist.
The diagnostic matrix indicates how often (percent) a paitr of units are allocated to the same treatment group.
There is no general rule but if units appearing together less than half as often as one would expect by chance or more than 75%, the validity of the randomisation might be compromised. 
In this case the procedure should be repeated with more relaxed constraints. 
The command (or more precisely the underlying Mata function) will try to generate a symmetric 
permutation pattern in a way that only half of all combinations needs to be assessed, 
e.g. the allocation sequence (1, 1, 1, 2, 2, 2) is symmetric to (2, 2, 2, 1, 1, 1) but in this case the 
trial arms will be in a final step randomly shuffled.
If the number of possible permuations exceeds 10 million, only 3 million random allocation seuqnences will be assessed.   


{marker examples}{...}
{title:Examples}
{hline}
{pstd}Restricted randomisation with 3 variables{p_end}
{phang2}{cmd:. sysuse bpwide, replace}{p_end}
{phang2}{cmd:. keep if mod(_n, 6) == 0}{p_end}
{phang2}{cmd:. restrand sex agegrp bp_before, rest(0.1 0.1 5) arms(2) seed(1103)}{p_end}
{phang2}{cmd:. mean restrand sex agegrp bp_before, obver(_arm)}{p_end}
{hline}
{pstd}Example were clusters are not independent from each other{p_end}
{phang2}{cmd:. sysuse bpwide, replace}{p_end}
{phang2}{cmd:. sort bp_before}{p_end}
{phang2}{cmd:. keep if _n < 4 | _n > 112}{p_end}
{phang2}{cmd:. restrand bp_before, rest(2) arms(2) seed(1103)}{p_end}
{hline}
{pstd}Example with agegroup as strata (sizes 2, 10, 2).{p_end}
{phang2}{cmd:. sysuse bpwide, replace}{p_end}
{phang2}{cmd:. keep in 17/44  if mod(_n, 2) == 0}{p_end}
{phang2}{cmd:. replace agegrp = agegr^2}{p_end}
{phang2}{cmd:. restrand agegrp bp_before, rest(0 10) arms(2) seed(1103)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:restrand} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(Nvalidseq)}} The number of allocation sequences which satisfied the constrains{p_end}
{synopt:{cmd:r(seed)}} The seed used to initiate the pseudo-randonm number generator{p_end}
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(diag)}}Matrix indicating percentages how often pairs were allocated to the same treatment group{p_end}

{p2colreset}{...}

{marker reference}{...}
{title:Reference}
{phang}
Moulton LH. Covariate-based constrained randomization of grouprandomized
trials. Clin Trials 2004{p_end}


{title:Author}
{phang}
{pstd}Jan Hattendorf, SwissTPH{p_end}
