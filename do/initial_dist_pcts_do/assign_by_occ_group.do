********************************
* occupation group assignments *
********************************
local missed_targets = 1
local super_loop = 0

local transfer_threshold = 1000

while(`missed_targets' > 0 & `super_loop' < 10) {
  local super_loop = `super_loop' + 1

  add_rsog_targets

  sort region sex occ_group statefip
  by region sex occ_group: egen rsog_assigned = sum(assigned)
  gen rsog_to_trnsfr_in  = cond(rsog_target > rsog_assigned + `transfer_threshold', rsog_target - rsog_assigned, 0)
  gen rsog_to_trnsfr_out = cond(rsog_assigned > rsog_target + `transfer_threshold', rsog_assigned - rsog_target, 0)

  egen total_missed = sum((rsog_to_trnsfr_in > 0) + (rsog_to_trnsfr_out > 0))
  local missed_targets = total_missed[1]
  drop total_missed
  display("********************")
  display("Super Loop: `super_loop'")
  display("Missed targets: `missed_targets'")
  display("********************")

  *calculating where the transfering will occur by state
  *like this is how they are assigned by ROWS, but not really
  gen will_trsfr_in  = rsog_to_trnsfr_in  > `transfer_threshold' & available > 0
  gen will_trsfr_out = rsog_to_trnsfr_out > `transfer_threshold' & assigned > 0

  sort region sex occ_group statefip
  by region sex occ_group: egen rsog_can_trsfr_in = sum(will_trsfr_in * available)
  by region sex occ_group: egen rsog_can_trsfr_out = sum(will_trsfr_out * assigned)

  gen to_trsfr_in_pct = cond(will_trsfr_in, ((will_trsfr_in * available) / rsog_can_trsfr_in), 0)
  gen to_trsfr_out_pct = cond(will_trsfr_out, ((will_trsfr_out * assigned) / rsog_can_trsfr_out), 0)

  gen to_trsfr_in =  to_trsfr_in_pct * rsog_to_trnsfr_in
  gen to_trsfr_out = to_trsfr_out_pct * rsog_to_trnsfr_out

  *adjust necessary due to floating point errors
  replace to_trsfr_out = assigned if abs(to_trsfr_out - assigned) < 0.01

  *assertions
  assert to_trsfr_in <= available
  assert to_trsfr_out <= assigned

  *Now balance the state totals, so that to_trsfr in == to_trsfr out
  local num_under = 1
  local iter = 1
  while(`num_under' > 0) {
    display("Calculating excess iteration: `iter'")
    capture drop sts_to_trsfr_in sts_to_trsfr_out sts_excess_in sts_excess_out ///
                 spare_available spare_assigned sts_spare_available sts_spare_assigned ///
                 sts_excess_in_over sts_excess_out_over
    sort statefip sex occ_group
    by statefip sex: egen sts_to_trsfr_in = sum(to_trsfr_in)
    by statefip sex: egen sts_to_trsfr_out = sum(to_trsfr_out)

    *sts_excess_in means too many available are becoming assigned; need to take some assigned make unassigned
    *sts_excess_out means too many assigned are becoming unassigned; need to take some available and assign them
    gen sts_excess_in = cond(sts_to_trsfr_in > sts_to_trsfr_out, sts_to_trsfr_in - sts_to_trsfr_out, 0)
    gen sts_excess_out = cond(sts_to_trsfr_out > sts_to_trsfr_in, sts_to_trsfr_out - sts_to_trsfr_in, 0)

    assert abs(sts_to_trsfr_in - sts_excess_in - sts_to_trsfr_out + sts_excess_out) < 0.01

    gen spare_available = cond(will_trsfr_out, 0, available - to_trsfr_in)
    gen spare_assigned = cond(will_trsfr_in, 0, assigned - to_trsfr_out)

    by statefip sex: egen sts_spare_available = sum(spare_available)
    by statefip sex: egen sts_spare_assigned = sum(spare_assigned)

    gen sts_excess_in_over  = sts_excess_in > sts_spare_assigned
    gen sts_excess_out_over = sts_excess_out > sts_spare_available
    egen num_under = sum(sts_excess_in_over + sts_excess_out_over)
    local num_under = num_under[1]

    *adjust
    if(`num_under' > 0) {
      display("Num under: `num_under'")
      assert (sts_spare_available / sts_excess_out) < 1 if sts_excess_out_over
      replace to_trsfr_out = to_trsfr_out * (sts_spare_available / sts_excess_out) if sts_excess_out_over
      assert (sts_spare_assigned / sts_excess_in) < 1 if sts_excess_in_over
      replace to_trsfr_in = to_trsfr_in * (sts_spare_assigned / sts_excess_in) if sts_excess_in_over
    }
    drop num_under

    local iter = `iter' + 1
  }

  assert sts_excess_in <= sts_spare_assigned
  assert sts_excess_out <= sts_spare_available

  gen spare_available_pct = cond(sts_excess_out == 0, 0, spare_available / sts_spare_available)
  gen spare_assigned_pct = cond(sts_excess_in == 0, 0, spare_assigned / sts_spare_assigned)

  local avail_ass available assigned
  foreach var of local avail_ass {
    by statefip sex: egen test_pct = sum(spare_`var'_pct)
    assert test_pct == 0 | abs(1 - test_pct) < 0.005
    drop test_pct
  }

  replace to_trsfr_in = to_trsfr_in + spare_available_pct * sts_excess_out
  replace to_trsfr_out = to_trsfr_out + spare_assigned_pct * sts_excess_in

  by statefip sex: egen sts_overall_trsfrs = sum(to_trsfr_in - to_trsfr_out)
  assert abs(sts_overall_trsfrs) < 1

  replace assigned = assigned + to_trsfr_in
  replace assigned = assigned - to_trsfr_out

  basic_assertions
  refresh_availability
  keep_primary_vars
}

