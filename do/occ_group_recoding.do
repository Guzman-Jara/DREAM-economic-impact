capture drop _merge

rename occ3 occ00
joinby occ00 using "lps/dta/occ00_occ_group_xwalk", unmatched(master)
*
replace occ_group = 19 if empstatd >= 30 //not in labor force
replace occ_group = 20 if (empstatd >= 20 & empstat <= 22) //unemployed
replace occ_group = 21 if empstatd == 13 // military
replace occ_group = 22 if empstatd == 0 // not reported

assert _merge == 3 | occ_group >= 19
drop _merge

