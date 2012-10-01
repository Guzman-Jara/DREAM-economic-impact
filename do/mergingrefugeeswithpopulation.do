use "dta/initial_acs_data.dta", clear
tab yrimmig
label list YRIMMIG
keep if yrimmig>1000
tab yrimmig
tab yrimmig, mi
keep if yrimmig>2000
tab bpld
collapse (sum) perwt, by(bpld yrimmig)

save dta/refugees, replace
import excel using "xl/Refugee Admissions Report as of 30 Apr 2012.xls", sheet("countsbyYear") cellrange(a60:e802) clear

rename A year
rename B bpld
rename C countryname
rename D refugee
rename E asylees

destring asy, force replace

egen TotalRefugees = rowtotal(refugee asylees)

rename year yrimmig
merge m:1 bpld yrimmig using dta/refugees
drop if _m==2

gen ratio = Total/perw

replace bpld = 46542 if bpld==1300
recode bpld (20000/30091 = 5 "Americas") ( 40000/49900= 1 "Europe") (50000/59900 70000/99900=2 "Asia") (60000/699000=3 "Africa") , gen(region)

bysort region yrimmig: egen TotalRegion = total(TotalRef)

****************************
* drop redundant countries *
****************************
drop if yrimmig == 2001 & countryname == "Union of Soviet Socialist Republics" //Redundant with Russia
drop if yrimmig == 2008 & countryname == "China" //Redundant with Tibet

save "dta/refugees", replace
