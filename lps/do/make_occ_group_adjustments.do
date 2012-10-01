use "dta/cps89_occ_dist", clear
joinby region sex occ_group using "dta/acs_2010_occ_dist", unmatched(both)

assert _merge == 3
drop _merge

gen occ_grp_adj = main_pct_10 / main_pct_89
keep region sex occ_group occ_grp_adj

save "dta/occ_group_adjustments", replace

