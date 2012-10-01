do do/region_recoding
do do/occ_group_recoding

*make sure there will be no conflicting merge variables
capture drop _merge
gen target_pct = .
drop target_pct
gen gender_pct = .
drop gender_pct

joinby region sex occ_group using "lps/dta/target_occ_group_pcts", unmatched(master)
assert _merge != 2
drop _merge

gen occ_group_has_no_undocs = target_pct == 0
drop target_pct gender_pct
