joinby occ90 using "dta/occ_90_00_xwalk_final", unmatched(master)

//Make sure that all variables in the initial dataset were matched
assert _merge != 1 if !missing(occ90)
drop _merge

local max_occs = max_occs[1]
drop max_occs

*gen rand = runiform()
gen occ00 = .

forvalues i = 1/`max_occs' {
  replace occ00 = occ00_`i' if rand <= pct_`i'
  drop occ00_`i' pct_`i'
}

drop rand
