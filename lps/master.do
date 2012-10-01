/* The purpose of this folder to is to create a crosswalk of how
likely it is for a person to be an unauthorized immigrant based
solely on their gender and occupation.

It draws its data from:
The Legalized Person Survey (1989) for empirical data on occupations held by unuathorized migrants.
CPS for data on occupations in the population at large in 1989
The ACS, for data on current occuption distributions.
*/

set more off

do "do/labels.do"

******************
* xwalk creation *
******************
*These do files are just a sanity check to ensure a manually created xwalk has no glaring errors.
do "do/make_90_00_occ_xwalk"
do "do/check_occ_groups_00"
do "do/occ_groups_00"

************
* 1989 lps *
************
do "do/lps_clean"
do "do/make_lps_occ_dist"
do "do/make_lps_gender_dist"

************
* 1989 cps *
************
*Create the CPS data file
cd "downloads"
do "cps_00033"
cd ".."
save "dta/cps_89_raw", replace

do "do/make_cps_occ_dist"

************
* 2010 acs *
************

do "do/make_acs_occ_dist"

*******************
* Target Percents *
*******************
do "do/combine_distributions"
