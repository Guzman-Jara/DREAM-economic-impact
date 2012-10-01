capture program drop assert_assigned_lt_actual
program define assert_assigned_lt_actual
  display("Cell assertions")
  assert assigned <= actual_pop + 0.001
  replace assigned = actual_pop if assigned > actual_pop
  assert assigned >= -0.0001
  replace assigned = 0 if assigned < 0
end

capture program drop assert_nation_assigned_eq_target
program define assert_nation_assigned_eq_target
  display("National assertions")
  capture drop nation_assigned
  egen nation_assigned = sum(assigned)
  assert abs(nation_assigned / nation_target - 1) < 0.005 //some wiggle room for floating points
end

capture program drop assert_state_assigned_eq_target
program define assert_state_assigned_eq_target
  display("State assertions")
  capture drop state_assigned
  sort region statefip
  by region statefip: egen state_assigned = sum(assigned)
  assert abs(state_assigned / state_target - 1) < 0.005 //some wiggle room for floating points
end

capture program drop basic_assertions
program define basic_assertions
  assert_assigned_lt_actual
  assert_nation_assigned_eq_target
  assert_state_assigned_eq_target
end

*This allows some room for floating point errors
capture program drop assert_equality
program define assert_equality
  assert abs(`1' - `2') / `2' < 0.0001
end

capture program drop refresh_availability
program define refresh_availability
  replace available = actual_pop - assigned
end

capture program drop redistribute_targets
program define redistribute_targets, byable(recall, noheader)
  local var_to_redistribute `1'
  local amount `2'
  local locked `3'

  tempvar total_non_locked
  tempvar non_locked_pct
  tempvar to_use
  tempvar test_pct
  quietly gen `to_use' = 0

  quietly replace `to_use' = `_byindex' == _byindex()
  quietly egen `total_non_locked' = sum(cond(`locked', 0, `var_to_redistribute')) if `to_use'
  quietly gen `non_locked_pct' = cond(`locked', 0, `var_to_redistribute' / `total_non_locked') if `to_use'
  quietly egen `test_pct' = sum(`non_locked_pct') if `to_use'
  quietly assert missing(`test_pct') | 1 - abs(`test_pct') < 0.001

  quietly replace `var_to_redistribute' = `var_to_redistribute' + (`non_locked_pct' * `amount') if `to_use'
end

capture program drop add_rsog_targets
program define add_rsog_targets
  gen rsog_target = . //Make sure that an error arises if rsog_target already exists
  drop rsog_target

  joinby region sex occ_group using "dta/rsog_targets", unmatched(both)
  assert _merge == 3
  drop _merge

end

capture program drop keep_primary_vars
program define keep_primary_vars
  keep statefip state_target region sex occ_group gender_pct ///
    occ_group_pct educ_r mexican actual_pop actual_state_pop ///
    nation_target region_target prime_region educ_r_target ///
    mexican_target region_sex_target available assigned
end

