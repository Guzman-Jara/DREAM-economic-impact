***********************
* SET OVERALL TARGETS *
***********************
insheet using "csv/target_ttl_undocument_by_state.csv", names clear

************************************
* REMOVE WHEN RUNNING FULL DATASET *
************************************
keep state t2008
************************************

egen target_ttl_undocumented = rowmean(t2*)
drop t2*

rename target_ttl_undocumented state_target
replace state_target = state_target * 1000



rename state statefip

recode statefip ///
  (09 23 25 33 44 50 34 36 42 = 1) ///
  (17 18 26 39 55 19 20 27 29 31 38 46 = 2) ///
  (10 11 12 13 24 37 45 51 54 01 21 28 47 05 22 40 48 = 3) ///
  (04 08 16 30 32 35 49 56 02 06 15 41 53 = 4) ///
  , gen(region)

joinby region using "lps/dta/target_occ_group_pcts", unmatched(master)
assert _merge == 3
drop _merge

rename target_pct occ_group_pct

*************************************************
* adjust states whose estimates are below 10000 *
*************************************************
*they are presently marked as 10000.  They need to be some actual number.
gen low_state_target = state_target <= 10000
joinby statefip sex occ_group using  "dta/state_pool_undocumented_by_occ_group", unmatched(using)
assert _merge == 3
drop _merge

sort region statefip
by region statefip: egen actual_state_pop = sum(actual_pop)
by region statefip: gen prime_state = _n == 1

egen nation_target = sum(state_target * prime_state)

forvalues i = 1/5 { //run a few times to account for totals changing and all
  display("Adjusting down low state estimates: `i'")
  replace state_target = actual_state_pop * nation_target / total_potential_undoc_pop if low_state_target
  drop nation_target
  egen nation_target = sum(state_target * prime_state)
}

*******************************************************
* adjust states with too few people for their targets *
*******************************************************
*this pop does not contain children, so modify it accordingly
replace state_target = state_target * children_adjustment

gen low_state = state_target > $max_proportion * actual_state_pop
egen num_under = sum(prime_state * low_state)
local num_under = num_under[1]
local under_by = 10
while(`num_under' > 0 & `under_by' > 1) { //see next lines VVV
  *under by is there because it is possible for the program to get caught
  *in an infinite loop because of a very low under by total where some
  *states are still technically under
  egen under_by = sum(prime_state * low_state * (state_target - $max_proportion * actual_state_pop))
  egen ttl_not_under = sum(prime_state * !low_state * state_target)
  replace state_target = state_target + under_by * (state_target / ttl_not_under)
  replace state_target = $max_proportion * actual_state_pop if low_state

  local under_by = under_by[1]
  drop under_by ttl_not_under num_under low_state

  gen low_state = state_target > $max_proportion * actual_state_pop
  egen num_under = sum(prime_state * low_state)
  local num_under = num_under[1]
}

*undo the children adjustment for the later steps
replace state_target = state_target / children_adjustment

preserve

keep if prime_state
keep statefip state_target
rename state_target target_ttl_undocumented
save "dta/state_target_totals", replace

restore

*confirm the nation targets still add up
drop low_state num_under
egen test_nation_target = sum(state_target * prime_state)
assert abs(test_nation_target - nation_target) < 2
drop test_nation_target


*create the region targets from the children targets
sort region statefip
by region: egen region_target = sum(state_target) if prime_state
by region: gen prime_region = _n == 1
by region: replace region_target = region_target[1]
assert !missing(region_target)

*test that the region targets add to the nation target
egen test_ttl = sum(region_target) if prime_region
replace test_ttl = test_ttl[1]
assert abs(test_ttl - nation_target) < 2
drop test_ttl

*****************************************
* adjust targets down based on children *
*****************************************
*adjust all targets down assuming that children will be added in later.
local targets state_target region_target nation_target
foreach var of local targets {
  replace `var' = `var' * children_adjustment
}

drop children_adjustment

************************
* nation level targets *
************************
* education targets taken from Passel 2009 *
gen     educ_r_target = 0.293 * nation_target if educ_r == 1
replace educ_r_target = 0.184 * nation_target if educ_r == 2
replace educ_r_target = 0.274 * nation_target if educ_r == 3
replace educ_r_target = 0.104 * nation_target if educ_r == 4
replace educ_r_target = 0.145 * nation_target if educ_r == 5
assert !missing(educ_r_target)

* Mexican targets taken from Passel 2009 *
gen mexican_target = cond(mexican, 0.58 * nation_target, 0.42 * nation_target)

******************
* region targets *
******************
gen region_sex_target = gender_pct * region_target
sort region sex
by region sex: gen prime_region_sex = _n == 1
egen ttl_region_sex = sum(region_sex_target) if prime_region_sex
by region sex: replace ttl_region_sex = ttl_region_sex[1]
assert abs(nation_target - ttl_region_sex) <= 2
drop ttl_region_sex
*Abbrev. rsog = region_sex_occ_group


gen available = actual_pop

*******************
* ASSIGN BY STATE *
*******************
display("Assigning by state")
gen transfer_ratio = actual_pop / actual_state_pop
gen assigned = state_target * transfer_ratio

basic_assertions
refresh_availability
keep_primary_vars


