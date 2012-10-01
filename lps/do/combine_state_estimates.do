* Combines Passel's 2010 state estimates of undocumented workers by region.

insheet using "csv/target_ttl_undocument_by_state.csv", names clear

do "do/labels"

recode state ///
  (09 23 25 33 44 50 34 36 42 = 1) ///
  (17 18 26 39 55 19 20 27 29 31 38 46 = 2) ///
  (10 11 12 13 24 37 45 51 54 01 21 28 47 05 22 40 48 = 3) ///
  (04 08 16 30 32 35 49 56 02 06 15 41 53 = 4) ///
  , gen(region)
label val region region_lbl

replace target_ttl_undocumented = target_ttl_undocumented * 1000
collapse (sum) target_ttl_undocumented, by(region)
keep region target_ttl_undocumented

save "dta/region_targets", replace

