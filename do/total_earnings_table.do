cd ..

use dta/forIMPLAN, clear

local inflation_adj = 226.665 / 218.056 // adj = cpi-u 2012january / 2010yearlyavg
local inflation_adj = 1
local period = 5 // number of years represented by each row

gen combined_earnings = incearn * pop * `inflation_adj' * `period'

collapse (rawsum)combined_earnings, by(type year)
by type: replace combined_earnings = sum(combined_earnings)

rename combined_earnings _

reshape wide _, i(year) j(type)

gen _dif = _0 - _1

format _* %15.0f

rename _0 with_dream_act
rename _1 without_dream_act


label var year "year"
label var with_dream_act "With DREAM Act"
label var without_dream_act "Without DREAM Act"

drop _dif
export excel using "xl/combined_earnings", firstrow(varlabels) replace


