cd ".."
use dta/initial_acs_data, clear

gen hhead:head= relate == 1
label def head 0 "Other" 1 "Head"

collapse (rawsum) perwt, by(yrimmig bpld citizen hhead)

save "dta/immigrants_by_year", replace
