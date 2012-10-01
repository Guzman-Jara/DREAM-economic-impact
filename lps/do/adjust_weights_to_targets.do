use "dta/lps_occ_info_only", clear
drop if missing(region) //nothing we can do with this data

joinby region sex occ_group using "dta/occ_group_adjustments", unmatched(master)

assert _merge == 3
drop _merge

joinby region using "dta/region_targets", unmatched(both)

assert _merge == 3
drop _merge

replace wgt = wgt * occ_grp_adj

sort region sex occ_group
by region: egen sum_lps_wgts = sum(wgt)

gen final_wgt_adj = target_ttl_undocumented / sum_lps_wgts
gen perwt = wgt * final_wgt_adj

keep region sex occ_group perwt

save "dta/lps_log_reg_ready", replace

