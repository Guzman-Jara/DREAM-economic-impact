use "dta/lps_occ_info_only", clear

drop if missing(region)

collapse (rawsum) wgt, by(region sex)

rename wgt pop

*****************************
* Adjust overal sex weights *
*****************************

local male_ratio = 0.535962877 //taken from Passel 2006 for the overall ratio of women to men

sort sex
egen total_pop = sum(pop)
by sex: egen total_by_sex = sum(pop)
gen target_sex_total = cond(sex == 1, `male_ratio' * total_pop, (1 - `male_ratio') * total_pop)
replace pop = pop * (target_sex_total / total_by_sex)


sort region sex
by region: egen region_ttl = sum(pop)

gen gender_pct = pop / region_ttl

keep region sex gender_pct

save "dta/lps_region_gender_dist", replace

