preserve

************************************
* CREATE EDUC_R TARGETS BY MEXICAN *
************************************
collapse (sum) assigned (mean) educ_r_target (mean) mexican_target (mean) nation_target, by(mexican educ_r)

gen cur_assigned = assigned

*create a combined pct for a broad idea of how much to transfer
gen educ_r_target_pct = educ_r_target / nation_target
gen educ_r_pct = cur_assigned / educ_r_target
gen mex_pct = cur_assigned / mexican_target
gen combined_pct = educ_r_pct * mex_pct

*create a trsfr_pct (what proportion of mex/non-mex to tranfer out by ed elevel
sort educ_r mexican
by educ_r: egen ttl_combined_pct = sum(combined_pct)
gen trsfr_pct = combined_pct / ttl_combined_pct

local missing_by = 1000
local iter = 0
while(`missing_by' > 0.5) {
  sort educ_r mexican
  by educ_r: egen ed_cur_assigned = sum(cur_assigned)

  *initial tranfer totals
  gen target_dif = educ_r_target - ed_cur_assigned
  egen ttl_target_dif = sum( target_dif^2 )
  gen to_trsfr = target_dif * trsfr_pct

  *the mexican totals won't naturally line (we lined up based on education total)
  *so now we need to reduce them back down to where they should be
  sort mexican educ_r
  by mexican: egen m_excess_activity = sum(to_trsfr)
  gen to_adjust = -m_excess_activity * mex_pct
  replace to_trsfr = to_trsfr + to_adjust
  replace cur_assigned = cur_assigned + to_trsfr


  sort educ_r mexican
  by educ_r: egen new_ed_cur_assigned = sum( cur_assigned )
  gen new_target_dif = educ_r_target - new_ed_cur_assigned
  egen new_ttl_target_dif = sum( new_target_dif^2 )
  gen missing_by = sqrt(new_ttl_target_dif)

  local iter = `iter' + 1
  local missing_by = missing_by[1]
  display("Iteration `iter'- Missing by: `missing_by'")

  drop ed_cur_assigned target_dif ttl_target_dif to_trsfr to_adjust new_ed_cur_assigned new_ttl_target_dif m_excess_activity new_target_dif missing_by
}

*
egen ttl = sum(cur_assigned)
assert_equality ttl nation_target

sort mexican
by mexican: egen test_m = sum(cur_assigned)
assert_equality test_m mexican_target
*
sort educ_r
by educ_r: egen test_e = sum(cur_assigned)
assert_equality test_e educ_r_target

keep educ_r mexican cur_assigned
rename cur_assigned educ_r_target
save "dta/educ_r_targets", replace

restore
************************************
* ASSIGN EDUC_R TARGETS BY MEXICAN *
************************************
drop educ_r_target
joinby mexican educ_r using "dta/educ_r_targets", unmatched(both)
assert _merge == 3
drop _merge

local missing_by = 10000
local iter = 0

while(`missing_by' > 0.25) {
  sort mexican educ_r
  by mexican educ_r: egen educ_r_assigned = sum(assigned)

  gen target_diff = educ_r_assigned - educ_r_target
  egen alt_available = rowmin(available assigned)

  *assert that there is enough available population for the education adjustment
  sort mexican educ_r
  by mexican educ_r: egen capacity = sum( cond(target_diff > 0, assigned, alt_available) )
  assert capacity > abs(target_diff)
  drop capacity

  sort mexican statefip educ_r
  by mexican statefip educ_r: egen ste_capacity = sum( cond(target_diff > 0, assigned, alt_available) )
  by mexican statefip: egen s_capacity = min(ste_capacity)
  by mexican statefip: gen prime_state = _n == 1

  *distribute the amount to trasfer based on the state_capacity
  egen educ_r_capacity = sum(prime_state * s_capacity)
  assert educ_r_capacity > abs(target_diff)
  gen ste_to_distribute = -target_diff * (s_capacity / educ_r_capacity)
  gen cell_pct_dist = cond(ste_capacity == 0, 0, cond(target_diff > 0, assigned, alt_available) / ste_capacity)

  *test that the distribution will go well
  by mexican statefip educ_r: egen test_pct_dist = sum(cell_pct_dist)
  assert ste_capacity == 0 | abs(1 - test_pct_dist) < 0.0001
  drop test_pct_dist

  replace assigned = assigned + cell_pct_dist * ste_to_distribute

  drop educ_r_assigned target_diff
  sort mexican educ_r
  by mexican educ_r: egen educ_r_assigned = sum(assigned)
  by mexican educ_r: gen prime = _n == 1
  gen target_diff = educ_r_assigned - educ_r_target
  egen total_diff_sq = sum(prime * target_diff^2)
  gen missing_by = sqrt(total_diff_sq)

  local missing_by = missing_by[1]
  local iter = `iter' + 1

  display("Iteration `iter': `missing_by'")

  drop educ_r_assigned target_diff alt_available ste_capacity s_capacity prime_state educ_r_capacity ste_to_distribute cell_pct_dist prime total_diff_sq missing_by
}

*assert_nation_assigned_eq_target
*assert_assigned_lt_actual

*don't assert by the state totals, because a few states are off by 0.5% (New Hampshire and Rhode Island), one by 1.5% (Montana) and one by 3% (South Dakota) off.
*These are all states with pretty low undocumented counts, so whatever.

keep_primary_vars
