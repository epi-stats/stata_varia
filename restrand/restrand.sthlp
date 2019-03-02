{smcl}
{* *! 1.0.7 JH 2 March 2019}{...}
{vieweralsosee " [FN] Random-number functions" "help random number functions"}{...}
{viewerjumpto "Syntax" "restrand##syntax"}{...}
{viewerjumpto "Description" "restrand##description"}{...}
{viewerjumpto "Options" "restrand##options"}{...}
{viewerjumpto "Remarks" "restrand##remarks"}{...}
{viewerjumpto "Examples" "restrand##examples"}{...}

{title:Title}
{phang}
{bf:restrand} {hline 2}  Covariate-based constrained randomization

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:restrand} {varlist} 
{cmd:,} {it:constraints(numlist)}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt c:onstrain(numlist)}} co-variate constraints{p_end}
{synopt:{opt a:rms(#)}} number of groups {p_end}
{synopt:{opt se:ed(#)}} set seed for pseudo random number generation{p_end}
{synopt:{opt n(#)}} number of units to randomize to each arm{p_end}
{synopt:{opt sa:mple(#)}} use random allocations instead of permutations{p_end}
{synopt:{opt c:ount}} use counts instead of percentages in the diagnostic matrix{p_end}
{synopt:{opt v:erbose(#)}} show details{p_end}

{synoptline}

{p2colreset}{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:restrand} Performs restricted randomization which is used if the number of units is small (often in cluster randomized trials). 
From all potential allocation sequences only those are selected, which satisfy some pre specified conditions.

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt constrain(numlist)} the constraints used for the randomization, 
i.e. the maximum allowed mean difference between the tretment arms. The number of values must equal the number of variables specified.

{phang}
{opt arms(#)} the number of groups i.e. trial arms or treatment groups (default is 2).

{phang}
{opt seed(#)} the seed to initiate the pseudo random number generator. 
If 0 (the default) the current date  and time will be used to generate a random seed. 
The same seed will generate the same randomisation list.

{phang}
{opt n(#)} the number of units to be randomized to each arm. 
If 0 (the default) all units will be randomized, with number of units per arm is either trunc(_N/arms) or ceil(_N/arms).

{phang}
{opt sample(#)} Use random allocation sequences instead of permutations. 
If 0 (the default) all possible permutations will be used. If the number of observations is high this can be billions and 
it might be better to use only a random selection (the algorithm is fast and requires minimal memory, a million sequences shouldn't be a problem).

{phang}
{opt count} If specified the diagnostic matrix will show counts instead of percentages.

{phang}
{opt verbose(#)} Show details for ech Nth sequence analysed. 0 (the default) means do not show details at all.

{marker remarks}{...}
{title:Remarks}

{pstd}
This procedure performs a pseudo-random selection from a list of acceptable allocations in a way that ensures balance on relevant covariates. 
The current random seed will be modified independent if option {cmd:seed} is specified or not.
A new variable _arm will be generated. If a variable with this name already exists the values will be over-written.
Stratification can be implemented if the restriction for a categorical variable is set to 0 
(note: dummy variables might be required in case of more than 2 categories, see examples for details).
However, this approch might be inefficient because many allocation sequences are per definition invalid.
Usually, it is better to perform the command seperately for each stratum (via in or if). 
The difference between these 2 option is that in the latter case the constraints are fulfilled within each stratum. 
Missing values are not allowed in any of the variables specified in varlist.
The diagnostic matrix indicates how frequently (percent) a pair of units are allocated to the same treatment group.
If a pairs of clusters appears always, often, rarely or never in the same arm,
the procedure should be repeated with more relaxed constraints.  
There is no general rule but rarely is sometimes defined as half as often as one would expect by chance and often as above 75%. 
The command (or more precisely the underlying Mata function) will try to generate a symmetric 
permutation pattern in a way that only half of all combinations needs to be assessed, 
e.g. the allocation sequence (1, 1, 1, 2, 2, 2) is symmetric to (2, 2, 2, 1, 1, 1). 
To ensure randomness the trial arms will be shuffled at the end.
The source code of the underlying Mata function is in the ado file or can be seen at https://github.com/epi-stats/stata_varia/


{marker examples}{...}
{title:Examples}
{hline}
{pstd}Restricted randomisation with 2 variables{p_end}
{phang2}{cmd: sysuse bpwide, replace}{p_end}
{phang2}{cmd: restrand sex bp_before in 50/70, constr(0.05 1) arms(2) seed(1103)}{p_end}
{phang2}{it:({stata "gr_example bpwide: restrand sex bp_before in 50/70, constr(0.05 1) arms(2) seed(1103)": click to run})}
{hline}
{pstd}Show details (note the selected dsequence is actually from loop 43){p_end}
{phang2}{cmd: sysuse bpwide, replace}{p_end}
{phang2}{cmd: restrand bp_before in 1/10, constr(1) arms(2) seed(1103) verb(1)}{p_end}
{phang2}{it:({stata "gr_example bpwide: restrand  bp_before in 1/10, constr(1) arms(2) seed(1103) verb(1)": click to run})}
{hline}
{pstd}Example with random samples instead of permutations{p_end}
{phang2}{cmd: sysuse bpwide, replace}{p_end}
{phang2}{cmd: restrand sex bp_before if agegrp < 3, constr(0.1 5) arms(6) seed(1130) sample(400000)}{p_end}
{phang2}{it:({stata "gr_example bpwide: restrand sex bp_before if agegrp < 3, constr(0.1 5) arms(6) seed(1130) sample(400000)": click to run})}
{hline}
{pstd}Example with to tight constraints. Units are not independent. Some units are always or (almost) never in the same arm{p_end}
{phang2}{cmd: sysuse bpwide, replace}{p_end}
{phang2}{cmd: restrand sex bp_before if  bp_before < 144 | bp_before > 183, constr(0 3) arms(2) seed(1103){p_end} 
{phang2}{it:({stata "gr_example bpwide: restrand sex bp_before if bp_before < 144 | bp_before > 183, constr(0 3) arms(2) seed(1103)": click to run})}
{hline}
{pstd}Example with age-group as strata but the categories are coded 1 to 3 (and 1+3 = 2+2){p_end}
{phang2}{cmd: sysuse bpwide, replace}{p_end} 
{phang2}{cmd: restrand agegrp bp_before if sex==0, constr(0 1) arms(2) sample(10000) seed(1103)}{p_end} 
{phang2}{cmd: tab agegrp _arm, nolab}{p_end}
{hline}
{pstd}Example with age-group as strata with dummy coded categories (constraints atisfied over all strata){p_end}
{phang3}{cmd: sysuse bpwide, replace}{p_end} 
{phang3}{cmd: tabulate agegrp, generate(age)}{p_end}
{phang3}{cmd: restrand age1 age2 age3 bp_before if sex==0, constr(0 0 0 1) arms(2) seed(1103) sample(10000)}{p_end}
{phang3}{cmd: tab agegrp _arm, nolab}{p_end}
{phang3}{cmd: mean bp_before, over(agegrp _arm)}{p_end}
{hline}
{pstd}Example with age-group as strata with in/if (much faster and constraints are satisfied in eacxh stratum){p_end}
{phang3}{cmd: sysuse bpwide, replace}{p_end} 
{phang3}{cmd: forvalues i = 1/3}{c -(}{p_end}
{phang4}{cmd: 	restrand bp_before if agegrp == `i' & sex==0, constr(1) arms(2) seed(1103)
{phang3}{cmd: {c -)}{p_end}
{phang3}{cmd: mean bp_before, over(agegrp _arm){p_end}
{hline}


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
{synopt:{cmd:r(alloc)}} The selected allocation sequence{p_end}
{synopt:{cmd:r(diag)}} Matrix indicating percentages how often pairs were allocated to the same treatment group{p_end}


{p2colreset}{...}

{marker reference}{...}
{title:Reference}
{phang}
Moulton LH. Covariate-based constrained randomization of group-randomized
trials. Clin Trials 2004{p_end}
{phang} 
ccrand (written by Eva Lorenz) is a good alternative 

{title:Author}
{phang}
{pstd}Jan Hattendorf, SwissTPH
