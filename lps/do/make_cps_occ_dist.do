use  "dta/cps_89_raw", clear

keep if age >= 18 & age <= 65 //working age population only
rename occ occ80


*replace some ipums labels with our own
do "do/labels"
replace region = floor(region / 10)
label val region region_lbl

do "do/occ_groups_80"

replace occ_group = 20 if empstat >= 20 & empstat <= 22 //unemployed
replace occ_group = 19 if empstat >= 30 //not in labor force
replace occ_group = 21 if empstat == 13 // military
replace occ_group = 22 if empstat == 0 // not reported

rename wtsupp pop

collapse (rawsum) pop, by(region sex occ_group)

sort region sex occ_group
by region sex: egen reg_sex_ttl = sum(pop)
gen reg_sex_pct = pop / reg_sex_ttl

rename reg_sex_pct main_pct_89
keep region sex occ_group main_pct_89

save "dta/cps89_occ_dist", replace
