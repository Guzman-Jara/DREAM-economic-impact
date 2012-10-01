************************************************
* Keep only families of potential undocumented *
************************************************
*mark families that contain potentially undocumented
sort serial
gen temp_potential_undoc = newcitizencat == 999
by serial: egen potential_undoc = max(temp_potential_undoc)
drop temp_potential_undoc

keep if potential_undoc

recode educd (0/26=1)(30/61=2)(62/64=3)(65/100=4)(101/116=5), gen(educ_r)
recode educd (0/61 = 1)(62/64=3)(65/116=4), gen(educ_r2)
replace educ_r2 = 2 if educ_r2 == 1 & school == 2
replace educ_r2 = 4 if educ_r2 == 3 & school == 2

gen mexican = bpl == 200
save "dta/potentially_undocumented_families", replace

use "dta/potentially_undocumented_families", clear

egen total_potential_undoc_pop = sum(perwt)
drop if age > 64

gen working_age = age >= 18 & age <= 64
gen part_undoc_pop = (yrimmig & age < 18) | (age >= 18 & age <= 64)

egen ttl_working_age = sum(perwt * working_age)
egen ttl_undoc_pop = sum(perwt * part_undoc_pop)

keep if age >= 18 & age <= 64 //keep only working age
keep if newcitizencat == 999


gen children_adjustment = ttl_working_age / ttl_undoc_pop
*replace children_adjustment = (1 + children_adjustment) / 2

save "dta/state_pool_undocumented", replace


collapse (rawsum) perwt (mean) children_adjustment (mean) total_potential_undoc_pop, by(region state sex mexican educ_r occ_group)
rename perwt actual_pop
save "dta/state_pool_undocumented_by_occ_group", replace
