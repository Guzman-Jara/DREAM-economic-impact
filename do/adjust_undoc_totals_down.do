local over = 1

while(`over' > 0) {
  use "dta/temporary_with_undocumented" if undocumented, clear

  collapse (rawsum) perwt, by(statefip)
  rename perwt ttl_marked_as_undoc
  joinby statefip using "dta/state_target_totals", unmatched(master)
  assert _merge == 3
  drop _merge

  gen adjustment = 1
  gen over = ttl_marked_as_undoc > target_ttl_undocumented
  egen ttl_over = sum(over)
  local over = ttl_over[1]

  replace adjustment = target_ttl_undocumented / ttl_marked_as_undoc if over
  keep statefip adjustment

  save "dta/state_adjustments", replace

  use "dta/temporary_with_undocumented", clear

  replace undocumented = 0 if child_of_undoc

  joinby statefip using "dta/state_adjustments", unmatched(master)
  assert _merge == 3
  drop _merge

  replace pct_undoc = pct_undoc * adjustment

  replace undocumented = rand <= pct_undoc

  mark_children_of_undocumented

  drop adjustment

  save "dta/temporary_with_undocumented", replace
}

save "dta/undocumented_distributed", replace
