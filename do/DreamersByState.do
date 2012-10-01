*PROGRAM to estimate the direct effect of the DREAM Act by state
*Juan Carlos Guzman
*8/21/2012

set more off
pause on
use "dta/2006-2010_full_plus_undocumented" if undocumented, clear

/* conditions for being a DREAMER
	A. Present in the USE 5 years before bill...so present entered before 2008
	B 15 years or younger when he enter the US.
	E. has been admitted ot a institution of higher education in the US; or
		has earn a high school or GED in us
	F.  age 35 year of age or younger

 REMOVAL OF CONDITIONAL STATUS TO PERMANENT
   D. i. Obtaines a degree of higher education or has completed 2 years of BA or higher; or
	  ii. has served in the militariy for 2 years */

* age at arrival
gen agearrival = age - yrsusa1

*Education
egen level = cut(educd), at(0,62,65 81,101,114,117) icodes
replace level = level+1
label define cert 1 "No High School" 2 "High School or Equivalent" 3 "Some College" ///
		4 "Asscoiate's degree" 5 "Bachelor's degree" 6 "Graduated degree"
label value level cert

recode level (2=1 "HS") (4/max= 2 "At least AA") (*=0 "Not Ready"), gen(eligready)
*keep everyone who might have be eligible to be a conditional dreamer

keep if (age<=35 & agearrival<15 & yrsusa1>=5) & fborn

*COMPARISON WITH MPI DATA

egen ageMPI = cut(age),at(0,18,30, 99)
tab level
egen eduEligible = cut(level), at(1,2,4,7)
tab ageMPI eduEligible [fw=perwt]
 * results are quite close:)


egen agegroup = cut(age), at(0,5(5)80, 100)
recode race 4/6 =4 3 7/9=5, gen(raceeth2)
replace raceeth2 = 3 if latino


label define raceeth 1 White 2 Black 3 Hispanic 4 Asian 5 Other 6 Unauthorized
label value raceeth2 raceeth
collapse (sum) pop=perwt, by(agegroup level racee sex state)
save dta/dreamersByState, replace



*PROJECTIONS
* EDUCATION PROJECTION

use dta/dreamersByState, clear
	gen army = 0
forvalues i=1/4 {
	joinby sex agegroup raceet army level using dta/eductransitionNatives, unmatch(master)
	replace Rate=1 if Rate==.
	replace Nextlevel=level if Next==.
	gen pop1 = pop*Rate
	replace agegroup = agegroup+5
	if `i'==1 {
		gen failures=0
		gen military=0
	}

	if `i'>=2 {
		replace failures = pop1*.95 if (raceet!=7 & !army) & ///
				((level==Nextlevel & level==2 ) | (agegroup>35 & level==Nextlevel & level==1))
		replace military = pop1*.05 if (raceet!=7 & !army) & ///
			( (level==Nextlevel & level==2) | (agegroup>35 & level==Nextlevel & level==1))

		replace pop1 = 0 if failures>0 & failures<.
		expand 2 if failure>0, gen(failed)
		expand 2 if failed, gen(army1)

		replace army = 1 if army1
		replace failed=0 if army1
		replace raceeth=7 if failed

		replace failure = 0 if !failed
		replace military = 0 if !army1
		replace pop1 = military if army1
		replace pop1 = failures if failed
		}
	drop if agegroup>=65

	collapse (sum) pop=pop1 failures military, by(state sex agegroup raceeth Nextlevel army)
	replace failures = 0
	rename Next level


	save dta/dreamNativeRateByState`i', replace
}
use dta/dreamersByState, clear
gen year = 2010
forvalues i=1/4 {
	append using dta/dreamNativeRateByState`i'
	replace year = 2010+`i'*5 if mi(year)
}
sort year raceeth sex agegroup
*drop military failure
gen failed = raceeth==7
replace raceeth=6 if raceeth==7
save dta/dreamNativeEducByState, replace



use dta/dreamersByState, clear
forvalues i=1/4 {

	joinby sex agegroup raceet level using dta\eductransitionForeigners, unmatched(master)
	gen pop`i' = pop*Rate  //RJ told me NOT to round till the end. And he was RIGHT

	replace agegroup = agegroup+5
	drop if agegroup>=65

	collapse (sum) pop=pop`i', by(state sex agegroup raceeth Nextlevel)
	rename Next level

	save dta/dreamForeignRateByState`i', replace
}
use dta/dreamersByState, clear
gen year = 2010
forvalues i=1/4 {
	append using dta/dreamForeignRateByState`i'
	replace year = 2010+`i'*5 if mi(year)
}
sort year raceeth sex agegroup
save dta/dreamForeignEducByState, replace


*/
*  INCOME JOIN WITH EDUCATION PROJECTIONS
use dta/dreamNativeEducByState, clear
label value raceeth2 raceeth
*replace pop = pop+ military
table year, c(sum pop) col format(%15.0fc) row
table year if failed, c(sum pop) col format(%15.0fc) row

append using dta/dreamForeignEducByState, gen(type)
label define type 0 "NativeRates" 1 "ForeignRates"
label value type type
rename raceeth2 race
gen raceeth2:raceeth2 = cond(!type,race,6)
rename level certificate

capture drop region
recode statefip ///
  (09 23 25 33 44 50 34  42 = 1 "Northeast" ) ///
  ( 18 26 39 55 19 20 27 29 31 38 46 = 2 "Midwest") ///
  (10 11  13 24 37 45 51 54 01 21 28 47 05 22 40 = 3 "South") ///
  ( 08 16 30 32 35 49 56 02 15 41 53 = 4 "West") ///
  (4= 5 "Arizona"), gen(region)
  label define region 6 California 12 Florida 36 "New York" 17 Illinois 48 Texas, add
 egen agegroup2 = cut(age), at(0,15(10)65,100)
merge m:1 region sex certi raceeth agegroup2 using dta/incomeByState, keep(match master)

egen EarnGroup = cut(incearn), at(0,10000,15000,25000,35000,50000,75000,100000,150000) icodes
egen IncoGroup = cut(inctot), at(0,10000,15000,25000,35000,50000,75000,100000,150000) icodes

gen TotInc	= inctot*pop
gen TotEarn = incearn*pop
format Tot* %15.0fc
replace TotEarn = -TotEarn if type
replace TotInc = - TotInc if type
egen newyear =cut(year), at(0,2020,2025,2030,2031 ) icodes

*Calculating number of DREAMers by state
preserve
table state if newyear==0 & type [pw=pop], replace
gen str8 dreamers= cond(table1<1000,"<1000", string(round(table1/1000)*1000))
export excel using xl\numberDREAMERS.xls, firstrow(varlabels) replace
restore

* calculating increase in the percentage of DREAMERes with college
gen CollegeDegree = certificate>3 if certificate!=.
label define newyear 0 "2010-2020" 1 "2020-2025" 2 "2025-2030"
preserve
table state year type [pw=pop] if year<2030, c(mean College )  replace
reshape wide table1, i(state year) j(type)
label var table10 "With DREAM Act"
label var table11 "Without Dream Act"
export excel using xl/CollegeAttainmentByState.xlsx, firstrow(varlabels) replace
restore
preserve
gen college = cond(type, -College, College)
table state newyear [pw=pop] if year<2030, c(sum college ) col replace
mvencode newyear, mv(5)
reshape wide table1, i(state ) j(newyear)
label var table10 "college2015"
label var table11 "college2020"
label var table12 "college2025"
label var table15 "collegetotal"
export excel using xl/CollegeAttainmentByState.xlsx, firstrow(varlabels) sheet(increase) sheetreplace
restore

* Calculating cumulative earnings of DREAMers by the Passage of ACT

preserve
table state year [pw=5*1.041053] if newyear<3,  c(sum TotEarn) format(%15.0fc) replace
bysort state: gen cumulativeSum= sum(table1)
format cumulative %15.0f
replace year =year +5
expand 2 if year==2015, gen(temp)
replace year = 2010 if temp
replace cumulative =0 if temp
sort state year

export excel statefip year cumu using xl/CummEarningByState.xlsx, firstrow(varlabels) replace
restore

* creating files for IMPLAN

table year type [pw=5*1.041053] if newyear<3,  c(sum TotEarn) format(%15.0fc) row col
table EarnGroup newyear [fw=5], c(sum TotEa) format(%15.0fc) row
table EarnGroup state newyear [fw=5],  c(sum TotEarn) format(%15.0fc) row col replace

drop if EarnGroup==.
sort state EarnGroup
gen Sector = 10001+EarnGroup
label var table1 "Household Expenditures"
gen year=2010
label var year "Event Year"
gen local = 1
label var local "Local Direct Purchase"
capture rm xl/valuesforIMPLANByState.xls
*gen year1 = cond(year<=2030, year,2030)



	foreach i in 1	2	4	5	6	8	9	10	11	12	13	15	16	17	18	19	20	///
		21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	///
		39	40	41	42	44	45	46	47	48	49	50	51	53	54	55	56 {

		local state: label STATEFIP `i'
		forvalues j=0/2 {
		export excel Sector table1 year  local if state==`i' & newyear==`j' using xl/valuesforIMPLANByStateV.xls, firstrow(varlabels) sheet("`state'_`j'") cell(A4)
	}
}


