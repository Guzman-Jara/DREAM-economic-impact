use "/../dta/initial_acs_data" if multyear == 2010, clear
keep if age >= 18 & age <= 65 //working age population only
drop empstat

gen occ00 = floor(occ / 10)

*replace some ipums labels with our own
do "do/labels"
replace region = floor(region / 10)
label val region region_lbl

joinby occ00 using "dta/occ00_occ_group_xwalk", unmatched(master)

replace occ_group = 20 if empstatd >= 20 & empstat <= 22 //unemployed
replace occ_group = 19 if empstatd >= 30 //not in labor force
replace occ_group = 21 if empstatd == 13 // military
replace occ_group = 22 if empstatd == 0 // not reported

rename perwt pop

save "dta/acs_2010_with_occ_groups", replace
use "dta/acs_2010_with_occ_groups", clear

collapse (rawsum) pop, by(region sex occ_group)

sort region sex occ_group
by region sex: egen reg_sex_ttl = sum(pop)
gen reg_sex_pct = pop / reg_sex_ttl

rename reg_sex_pct main_pct_10
keep region sex occ_group main_pct_10

save "dta/acs_2010_occ_dist", replace
