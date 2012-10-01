use "dta/2006-2010_undocumented", clear
keep if undocumented
keep undocumented serial pernum

joinby serial pernum using "dta/ready_to_redistribute_occs_2006_2010", unmatched(both)
assert _merge != 1
drop _merge

replace undocumented = 0 if missing(undocumented)

