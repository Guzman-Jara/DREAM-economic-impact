/* This program creates measures the income and college potential of
DREAMers.  looking at college transition rates, and income with life-time earnings

*/


use "dta/2006-2010_full_plus_undocumented", clear
run do/synthesizeEarnings.do
* life-time earnings tables creation.

* certificate levels of education: LTHS, HS, SC,AA, BA, GR

egen certificate = cut(educd), at(0,62,65 81,101,114,117) icodes
label define cert 0 "No High School" 1 "High School or Equivalent" 2 "Some College" ///
		3 "Asscoiate's degree" 4 "Bachelor's degree" 5 "Graduated degree"
label value certificate cert

recode race 4/6 =4 3 7/9=5, gen(race4)
gen raceeth2:raceeth = cond(undoc, 6, cond(latino,3,race4))
label define raceeth 1 White 2 Black 3 Hispanic 4 Asian 5 Other 6 Unauthorized
tab raceeth, mi
mvdecode incearn inctot, mv(-9999 9999999)

* LIFE TIME EARNINGS
synthetic incearn certificate age [fw=perwt], by(raceeth2) ageg(25(5)65)
synthetic incearn certificate age [fw=perwt], by(raceeth2) ageg(25(5)65) full(uhrswork WKS)
synthetic incearn certificate age [fw=perwt], by(raceeth2 sex) ageg(25(5)65)
synthetic incearn certificate age [fw=perwt], by(raceeth2 sex) ageg(25(5)65) full(uhrswork WKS)

*  ADDING REPLICATE WEIGHTS FOR STANDARD ERRORS

*merge 1:1 serial pernum using dta/weights, keep(master matched)
*svyset [pw=perwt], jkr(repwtp1-repwtp80)
*save dta/2006-2010_full_plus_undocumented_weights, replace


*CREATION OF INCOME PROFILE FILE
*egen agegroup = cut(age), at(0(5)100)
egen agegroup2 = cut(age), at(0,15(10)65,100)
preserve
collapse (mean) incearn inctot [fw=perwt], by(raceeth2 agegroup sex cert)
save dta/income, replace
restore
*tab region
capture drop region
recode statefip ///
  (09 23 25 33 44 50 34  42 = 1 "Northeast" ) ///
  ( 18 26 39 55 19 20 27 29 31 38 46 = 2 "Midwest") ///
  (10 11  13 24 37 45 51 54 01 21 28 47 05 22 40 = 3 "South") ///
  ( 08 16 30 32 35 49 56 02 15 41 53 = 4 "West") ///
  (4= 5 "Arizona"), gen(region)
  label define region 6 California 12 Florida 36 "New York" 17 Illinois 48 Texas, add

preserve

collapse (mean) incearn inctot (semean) se=incearn [fw=perwt], by(region sex cert raceeth2 agegroup2  )
tab region
save dta/incomeByState, replace

* CREATION OF TRANSITION RATES


restore
run do/educationTransitionRates.do
preserve
eductranrate multyear certific age [pw=perwt] if !fborn, by(raceeth2 sex)
save dta/eductransitionNatives, replace
restore

preserve
replace raceeth2 = cond(latino,3,race4)
eductranrate multyear certific age [pw=perwt] if undocu & fborn, by(raceeth2 sex)
save dta/eductransitionForeigners, replace
restore

