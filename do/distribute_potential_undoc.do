use "dta/potentially_undocumented_families", clear
*keep everything that is not the pool of undocumented
keep if age < 18 | age > 64
save "dta/other_family_members", replace


use "dta/state_pool_undocumented", clear

joinby statefip sex occ_group mexican educ_r using "dta/undoc_pcts_by_sex_occgroup_state_mexican", unmatched(master)
replace pct_undoc = 0 if _merge == 1
drop _merge

set seed 19943

gen rand = runiform()

gen undocumented = rand <= pct_undoc

append using "dta/other_family_members"
replace undocumented = 0 if missing(undocumented)
replace pct_undoc = 0 if missing(pct_undoc)

mark_children_of_undocumented

save "dta/temporary_with_undocumented", replace

