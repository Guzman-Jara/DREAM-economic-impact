/*program to calculate the economic impact of the executive order
by Juan Carlos Guzman
Sep 17, 2012*/

/* Are You Eligible to Apply?
Basically, the government will be using its discretion not to pursue those:
* who arrived in this country before turning 16;
* have no felony record;
* have resided here continuously for at least five years;
* are currently in school;
* have graduated from high school or obtained an equivalency diploma;
* or are honorably discharged veterans.
But they cannot have turned 30 at the time of their application.
*/
cd "z:\public\CAP"
set more off
pause on

/*
use "dta\2006-2010_full_plus_undocumented" if undocumented, clear

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

keep if (age<=30 & agearrival<15 & yrsusa1>=5) & fborn

* to deal with this we basically are going to assume that there is only a change in income but no education profile
* in other words we will making go through the foreign born transition rates but make them
* earn what a us born will get as opose of as a undocumented?



egen agegroup = cut(age), at(0,5(5)80, 100)
recode race 4/6 =4 3 7/9=5, gen(raceeth2)
replace raceeth2 = 3 if latino


label define raceeth 1 White 2 Black 3 Hispanic 4 Asian 5 Other 6 Unauthorized
label value raceeth2 raceeth
collapse (sum) pop=perwt, by(agegroup level racee sex state)
save dta\executiveorderByState, replace

use dta/executiveorderByState, clear
quietly {
forvalues i=1/4 {

	joinby sex agegroup raceet level using dta\eductransitionForeigners, unmatched(master)
	gen pop`i' = pop*Rate  //RJ told me NOT to round till the end. And he was RIGHT
	
	replace agegroup = agegroup+5
	drop if agegroup>=65
	
	collapse (sum) pop=pop`i', by(state sex agegroup raceeth Nextlevel)
	rename Next level

	save dta/EO_ForeignRateByState`i', replace
}
use dta/executiveorderByState, clear
gen year = 2010
forvalues i=1/4 {
	append using dta/EO_ForeignRateByState`i'
	replace year = 2010+`i'*5 if mi(year)
}
sort year raceeth sex agegroup
save dta/EO_ForeignEducByState, replace
}
*/
*  INCOME JOIN WITH EDUCATION PROJECTIONS
use dta/EO_ForeignEducByState, clear
label value raceeth2 raceeth
*replace pop = pop+ military
table year, c(sum pop) col format(%15.0fc) row
expand 2, gen(type)
replace race=6 if type
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

* creating files for IMPLAN

table year type [pw=5*1.041053] if newyear<3,  c(sum TotEarn) format(%15.0fc) row col 
table EarnGroup newyear [fw=5], c(sum TotEa) format(%15.0fc) row  
table EarnGroup state year [fw=5],  c(sum TotEarn) format(%15.0fc) row col replace 

drop if EarnGroup==.
sort state EarnGroup
gen Sector = 10001+EarnGroup
label var table1 "Household Expenditures" 
capture gen year=2010
if _rc {
	rename year newyear
	gen year=2010
}
	
label var year "Event Year"
gen local = 1
label var local "Local Direct Purchase"


	foreach i in 1	2	4	5	6	8	9	10	11	12	13	15	16	17	18	19	20	///
		21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	///
		39	40	41	42	44	45	46	47	48	49	50	51	53	54	55	56 {

		local state: label STATEFIP `i'
		forvalues j=2010(5)2025 {
		qui export excel Sector table1 year  local if state==`i' & newyear==`j' ///
			using xl\valuesIMPLAN_EOStateI.xls, firstrow(varlabels) ///
			sheet("`state'_`j'") cell(A4) sheetreplace
	}
}
