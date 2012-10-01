sort region sex occ_group
collapse (rawsum) actual_pop (mean) occ_group_pct (mean) nation_target (mean) region_sex_target, by(region sex occ_group)

sort region sex

*make sure the target percents all add to 1
by region sex: egen ttl_pct = sum(occ_group_pct)
replace occ_group_pct = occ_group_pct / ttl_pct
drop ttl_pct
by region sex: egen ttl_pct = sum(occ_group_pct)
assert abs(1 - ttl_pct) < 0.0001 //some wiggle room for floats
drop ttl_pct

*create rsog_target and make sure its total adds up to the national target
gen rsog_target = occ_group_pct * region_sex_target
egen ttl_rsog_target = sum(rsog_target)
assert_equality ttl_rsog_target nation_target
drop ttl_rsog_target

local max_proportion = 0.95
gen actual_rsog_under = actual_pop * $max_proportion < rsog_target
gen rsog_actual_pop_under_by = cond(actual_rsog_under, rsog_target - ($max_proportion * actual_pop), 0)

by region sex: egen total_rsog_under_by = sum(rsog_actual_pop_under_by)
egen num_under = sum(actual_rsog_under)

sort region sex occ_group
by region sex occ_group: gen prime_rsog = _n == 1

local iter = 1
local under_by = 20

while(num_under[1] > 0 & `under_by' > 2) {
  display("Adjusting RSOG targets, iteration: `iter' under_by: `under_by'")
  local iter = `iter' + 1

  by region sex: redistribute_targets rsog_target total_rsog_under_by actual_rsog_under
  replace rsog_target = actual_pop * $max_proportion if actual_rsog_under

  egen test_target = sum(rsog_target)
  assert_equality test_target nation_target
  drop test_target total_rsog_under_by

  replace actual_rsog_under = actual_pop * $max_proportion < rsog_target
  replace rsog_actual_pop_under_by = cond(actual_rsog_under, rsog_target - ($max_proportion * actual_pop), 0)

  by region sex: egen total_rsog_under_by = sum(rsog_actual_pop_under_by)
  egen total_under = sum(total_rsog_under_by * prime_rsog)
  local under_by = total_under[1]

  drop num_under total_under
  egen num_under = sum(actual_rsog_under)
}

keep region sex occ_group rsog_target
save "dta/rsog_targets", replace


