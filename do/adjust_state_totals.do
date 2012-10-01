**********************************
* get the original state targets *
**********************************
insheet using "csv/target_ttl_undocument_by_state.csv", clear
egen target_ttl_undocumented = rowmean(t2010 t2009 t2008 t2005)
rename state statefip
keep statefip target_ttl_undocumented
gen state_target = target_ttl_undocumented * 1000

*************************************************
* adjust states whose estimates are below 10000 *
*************************************************
*they are presently marked as 10000.  They need to be some actual number.
joinby statefip using "dta/state_pool_undocumented_by_occ_group", unmatched(both)
assert _merge == 3
drop _merge

gen low_state_target = state_target <= 10000

collapse (rawsum) actual_pop (mean) state_target (mean) low_state_target (mean) children_adjustment, by(statefip)
egen nation_undoc_pop = sum(actual_pop)


sort statefip
by statefip: egen actual_state_pop = sum(actual_pop)
drop actual_pop

forvalues i = 1/5 { //run a few times to account for totals changing and all
  display("Adjusting down low state estimates: `i'")
  egen nation_target = sum(state_target)
  di nation_target[1]
  replace state_target = actual_state_pop * nation_target / nation_undoc_pop if low_state_target
  drop nation_target
}

********************************************************************************
* adjust states whose pool of undocumented is not big enough for their targets *
********************************************************************************
replace state_target = state_target * children_adjustment

gen low_state = state_target > $max_proportion * actual_state_pop
egen num_under = sum(low_state)
local num_under = num_under[1]
local under_by = 10000

while(`num_under' > 0 & `under_by' > 1) {
  egen under_by = sum(low_state * (state_target - $max_proportion * actual_state_pop))
  local under_by = under_by[1]

  egen ttl_not_under = sum(!low_state * state_target)
  replace state_target = state_target + under_by * (state_target / ttl_not_under)
  replace state_target = $max_proportion * actual_state_pop if low_state

  drop under_by ttl_not_under num_under low_state

  gen low_state = state_target > $max_proportion * actual_state_pop
  egen num_under = sum(low_state)
  local num_under = num_under[1]

}

replace state_target = state_target / children_adjustment

keep statefip state_target
rename state_target target_ttl_undocumented


save "dta/state_target_totals", replace
