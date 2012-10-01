/* This file provides a check to make sure that the "occ_groups_00", which was manually coded
does not disagree with the 1980 occ groups */

*start with 1980 codes
insheet using "csv/occ_80_codes.csv", names clear
do "do/occ_groups_80"

drop if occ80 == 905 | occ80 == 909 //drop unemployed for now

*bring 1980 to 1990
do "do/occ80_90_xwalk"

*1990 does not map to 2000 directly, so create a lot of cases
*so that all the variations are caught
expand 1000
sort occ90
by occ90: gen rand = _n / _N
do "do/run_90_00_occ_xwalk"

*figure out how often a 2000 occ maps onto an occ group
sort occ00 occ_group
by occ00 occ_group: gen occ_group_wgt = _N
by occ00 occ_group: keep if _n == 1

*calculate a percent that a 2000 occ will map to an occ group
sort occ00 occ_group
by occ00: egen occ_wgt = sum(occ_group_wgt)
gen occ_group_pct = occ_group_wgt / occ_wgt


*add in descriptions for ease
joinby occ00 using "dta/occ00_desc", unmatched(master)

*now perform the manual coding
rename occ_group xwalk_occ_group
do "do/occ_groups_00"

*observe any anomolies
gen observe = occ_group != xwalk_occ_group & occ_group_pct > 0.4

*observe occupations by anomoly
sort occ00
by occ00: egen max_pct = max(occ_group_pct)
gen observe2 = max_pct < 0.6



