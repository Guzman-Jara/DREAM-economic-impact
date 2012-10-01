do do/initial_dist_pcts_do/distribution_pct_fns
*
do do/initial_dist_pcts_do/setup

preserve
do do/initial_dist_pcts_do/region_level_target_adjustments
restore

do do/initial_dist_pcts_do/assign_by_occ_group
save "dta/pre_mexican_adjust", replace

use "dta/pre_mexican_adjust", clear
do do/initial_dist_pcts_do/adjust_by_mexican
do do/initial_dist_pcts_do/adjust_by_educ

keep sex mexican educ_r statefip occ_group assigned actual_pop

gen pct_undoc = assigned / actual_pop
drop assigned actual_pop
save "dta/undoc_pcts_by_sex_occgroup_state_mexican", replace
