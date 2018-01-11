{smcl}
{* *! version 1.01  10Jan2018}{...}
{vieweralsosee " [FN] Random-number functions" "help random number functions"}{...}
{viewerjumpto "Syntax" "randomlist##syntax"}{...}
{viewerjumpto "Description" "randomlist##description"}{...}
{viewerjumpto "Options" "randomlist##options"}{...}
{viewerjumpto "Remarks" "randomlist##remarks"}{...}
{viewerjumpto "Examples" "randomlist##examples"}{...}

{title:Title}
{phang}
{bf:randomlist} {hline 2}  Generates random allocation list for clinical trials
{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:randomlist} #N 
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt se:ed(#)}} set seed for pseudo random number generation{p_end}
{synopt:{opt a:rms(#)}} number of treatments {p_end}
{synopt:{opt b:locksize(#)}} (minimum) blocksize for block randomisation{p_end}
{synopt:{opt m:axblocksize(#)}} maximum blocksize for block randomisation{p_end}
{synopt:{opt st:rata(#)}} number of strata{p_end}
{synopt:{opt c:lear}} replace data in memory if applicable{p_end}
{synoptline}

{p2colreset}{...}
{marker description}{...}
{title:Description}
{pstd}
{cmd:randomlist} generates a dataset with a random allocation list for clinical trials. 
Supports permuted-block randomization with varying block size.
N represents the minimum number of particippants which should be allocated to each arm (and each stratum if strata is specified).

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt seed(#)} the seed to initiate the pseudo random number generator. 
If 0 (the default) the current date  and time will be used to generate a number randomly. 
The same seed will generate the same randomisation list.
{phang}
{opt arms(#)} the number of treatments (i.e. trial arms) (default is 2).
{phang}
{opt blocksize(#)} the size of the blocks used for block randomisation. 
If option {cmd:maxblocksize} is specified this value represents the minimum random block size.
Must be 0 or a multiple of {cmd:arms}.
The default is 0 meaning no block randomisation (usually not recommended).
{phang}
{opt maxblocksize(#)} the maximum block size for block randomisation with varying block sizes. 
Must be 0 or a multiple of {cmd:blocksize}.
The default is 0 meaning fixed block sizes of size {cmd:blocksize}.
{phang}
{opt strata(#)} the number of strata. 
Can be simply interpreted as repeating the process multiple times. 
Default is 1.
{phang}
{opt clear} specifies that it is okay to replace the data in memory.

{marker remarks}{...}
{title:Remarks}
{pstd}
The current random seed will be modified independent if option {cmd:seed} is specified or not.
Usually, it is recommended to use block randomisation to ensure a balanced number of patients in 
each treatment arm. 
In a clinical trial with 2 treatment arms (A and B), a block size of 4 will result in 6 possiblele permutations 
AABB, ABAB, BABA, ABBA, BAAB, BBAA. 
The allcoation ratio is always (1:1:...:1). 
If you require a different allocation ratio increase the number of trial arms followed by {cmd:recode}.
See below for an example. 

{marker examples}{...}
{title:Examples}
{hline}
{pstd}Delete data in memory{p_end}
{phang2}{cmd:. clear}{p_end}
{pstd}Generate allocation list with at least 40 patients in each of the 3 treatments (1:1:1) with varying block dizes of 3, 6 and 9{p_end}
{phang2}{cmd:. randomlist 40, seed(1103) arms(3) blocksize(3) maxblocksize(9)}{p_end}
{hline}
{pstd}Generate allocation sequence with 3 arms with ratio (3:3:1) and block size of 7{p_end}
{phang2}{cmd:. randomlist 40, seed(1103) arms(7) blocksize(7) clear}{p_end}
{phang2}{cmd:. recode arm (1/3 = 1) (4/6 = 2) (7 = 3), generate(finalarm)}{p_end}

{title:Author}
{pstd}Jan Hattendorf, SwissTPH{p_end}
