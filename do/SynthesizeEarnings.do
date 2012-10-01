* Program to calculate the Synthesized Earnings for different groups
* Assupmtions: in the labor Market from 40 years 25 to 65 by education
*level.

capture program drop synthetic
program define synthetic
pause on
syntax varlist [fweight pweight], [BY(varlist)] [AGEG(numlist)] [FULL(varlist)]
tokenize `varlist'
local income `1'  //measure of income
local educ `2'   //Education in groups
local age `3'  //Single age

preserve
if "`ageg'"=="" {
	local ageg 25(10)65
	local group= 10
}
else {
	local ageg: subinstr local ageg " " ", ", all
	tokenize "`ageg'", parse(" ,")
	capture confirm number `3'
	if !_rc local group= `3'-`1'
	else local group= `2'- `1'
}


tempvar agegroup
quietly egen `agegroup'= cut(`age'),at(`ageg')  // creates age groups
quietly drop if `agegroup'==.
if "`full'"!="" {
	tokenize `full'
	local wkhp `1'  //hours of work per week
	local wkw `2'  //weeks worked in a year
	collapse (mean) `income' [`weight' `exp'] if `wkhp'>=35 & `wkw'>=4 , by(`agegroup' `educ' `by')  //fulltime almost all year
}
else {
	collapse (mean) `income' [`weight' `exp'], by(`agegroup' `educ' `by')
}


gen inc5yr = `income'*`group'
sort `educ' `by' `agegroup'

by `educ' `by': egen ltear= total(inc5yr)
egen tag = tag(`educ' `by')
quietly keep if tag
tabdisp `educ' `by', cell(ltear) format(%11.0fc)
restore
end




