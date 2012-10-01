* Create a percent distribution of occ_groups by region and sex.
use "dta/lps_occ_info_only", clear

collapse (rawsum) wgt, by(region sex occ_group)

rename wgt pop
sort region sex occ_group
by region sex: egen reg_sex_ttl = sum(pop)
gen reg_sex_pct = pop / reg_sex_ttl

rename reg_sex_pct immigrant_pct_89
keep region sex occ_group immigrant_pct_89

save "dta/lps_occ_dist", replace
