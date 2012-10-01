sort mexican
by mexican: egen m_assigned = sum(assigned)
gen m_target_diff = m_assigned - mexican_target

sort statefip mexican
egen alt_available = rowmin(available assigned) //Make sure that no group can more than double in size


*assert that there is enough available population for mexican adjustment
sort mexican
by mexican: egen m_capacity = sum( cond(m_target_diff > 0, assigned, alt_available) )
assert m_capacity > abs(m_target_diff)
drop m_capacity

sort statefip mexican
by statefip mexican: egen stm_capacity = sum( cond(m_target_diff > 0, assigned, alt_available) )
by statefip: egen s_capacity = min(stm_capacity)
by statefip: gen prime_state = _n == 1

*distribute the amount to trasfer based on the state_capacity
egen m_capacity = sum(prime_state * s_capacity)
assert m_capacity > abs(m_target_diff)
gen stm_to_distribute = -m_target_diff * (s_capacity / m_capacity)
gen cell_pct_dist = cond(m_target_diff > 0, assigned, alt_available) / stm_capacity

*test that the distribution will go well
by statefip mexican: egen test_pct_dist = sum(cell_pct_dist)
assert abs(1 - test_pct_dist) < 0.0001
drop test_pct_dist

replace assigned = assigned + cell_pct_dist * stm_to_distribute

drop m_assigned m_target_diff
sort mexican
by mexican: egen m_assigned = sum(assigned)
gen m_target_diff = m_assigned - mexican_target
assert abs(m_target_diff) < 1

basic_assertions
refresh_availability
keep_primary_vars


