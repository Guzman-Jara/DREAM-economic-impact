************
* cleaning *
************
insheet using "csv/occ_90-00_xwalk.csv", names clear

gen group = !missing(occ90)
replace group = sum(group)

sort group
by group: replace occ90 = occ90[1]
by group: replace occ90_desc = occ90_desc[1]

drop if missing(occ00)

replace conversion_factor = conversion_factor / 100
drop group

save "dta/occ_90_00_xwalk_with_desc", replace

*************************
* create occ desc files *
*************************
use "dta/occ_90_00_xwalk_with_desc", clear

bysort occ90: keep if _n == 1
keep occ90 occ90_desc
save "dta/occ90_desc", replace

use "dta/occ_90_00_xwalk_with_desc", clear

bysort occ00: keep if _n == 1
keep occ00 occ00_desc
save "dta/occ00_desc", replace

*************************
* make the xwalk itself *
*************************
use "dta/occ_90_00_xwalk_with_desc", clear

keep occ90 occ00 conversion_factor
sort occ90 conversion_factor

by occ90: replace conversion_factor = sum(conversion_factor)
gsort occ90 -conversion_factor
by occ90: replace conversion_factor = 1 if _n == 1 //ensure that there is always a 100% prob for the first choice

by occ90: gen num = _n
egen max_occs = max(num)
local max_occs = max_occs[1]

rename conversion_factor pct_
rename occ00 occ00_
reshape wide pct_ occ00_, i(occ90) j(num)

forvalues i = 1/`max_occs' {
  replace pct_`i' = -1 if missing(pct_`i')
}

save "dta/occ_90_00_xwalk_final", replace

