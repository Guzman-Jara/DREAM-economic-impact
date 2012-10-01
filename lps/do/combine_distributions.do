use "dta/lps_occ_dist", clear

drop if missing(region)

joinby region sex occ_group using "dta/cps89_occ_dist", unmatched(both) _merge(_cps_merge)
joinby region sex occ_group using "dta/acs_2010_occ_dist", unmatched(both) _merge(_acs_merge)
joinby region sex using "dta/lps_region_gender_dist", unmatched(both) _merge(_sex_merge)

*make sure the merges  went well
assert _cps_merge != 1 //there are some missing categories in lps_occ_dist, so using only is acceptable
assert _acs_merge == 3 //there shouldn't be any missing categories any more
assert _sex_merge == 3 //sex should all be found
drop _cps_merge _acs_merge _sex_merge

*adjust original percents by change in occupations
replace immigrant_pct_89 = 0 if missing(immigrant_pct_89)
gen target_pct = immigrant_pct_89 * main_pct_10 / main_pct_89


*************************************************************
* adjust laborforce and unemployed to match Passels numbers *
*************************************************************
* Men
* 94% laborforce participation = 0.06 nilf
local male_nilf = 0.06
* 6.5% unumployment = (0.94 * 0.065) = 0.0611
local male_unemploy = 0.0611
* .8789 share of the remaining pop
local male_share_working = 0.8789
* Women
* 0.58 laborforce particpation = 0.42 nilf
local female_nilf = 0.42
*6.5% unemployment = (0.58 * 0.065) = 0.0377
local female_unemploy = 0.0377
* 0.5423 share of the working pop
local female_share_working = 0.5423

*zero out these values so we can adjust the others and then add them back in
replace target_pct = 0 if sex == 1 & occ_group == 19
replace target_pct = 0 if sex == 1 & occ_group == 20
replace target_pct = 0 if sex == 2 & occ_group == 19
replace target_pct = 0 if sex == 2 & occ_group == 20
*
*force the remaing target percents to add to one
sort region sex occ_group target_pct
by region sex: egen ttl_pct = sum(target_pct)

replace target_pct = (`male_share_working' / ttl_pct) * target_pct if sex == 1
replace target_pct = (`female_share_working' / ttl_pct) * target_pct if sex == 2

replace target_pct = `male_nilf' if sex == 1 & occ_group == 19
replace target_pct = `male_unemploy' if sex == 1 & occ_group == 20
replace target_pct = `female_nilf' if sex == 2 & occ_group == 19
replace target_pct = `female_unemploy' if sex == 2 & occ_group == 20
*
by region sex: egen test = sum(target_pct)
assert abs(test - 1) < 0.00001 //add some tolerance for floating point errors

keep region sex gender_pct occ_group target_pct
save "dta/target_occ_group_pcts", replace


