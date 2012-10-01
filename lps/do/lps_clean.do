/*
This do file cleans and collapse occupational data from the Legalized Population Survery
*/

use "dta/lps", clear

rename _all, lower

***********************
* BASIC DATA CLEANING *
***********************

*************
* technical *
*************
destring basewtx, gen(wgt)

****************
* demographics *
****************
destring a1yearx, gen(year_of_birth)
gen age = 1989 - year_of_birth

destring a1agex, replace
replace age = a1agex if !missing(a1agex)


destring a3x, gen(sex)
capture label drop sex_lbl
label define sex_lbl 1 "Male" 2 "Female"
label values sex sex_lbl

**********
* region *
**********

*NOTE: The lps doesn't use standard fips codes, they have their own
*close to this fips, but some states are out of order

destring d9x, gen(state_first_job)
destring state89, gen(state_residence)
label var state_first_job "In what state was your first job located"

drop if state_first_job == 40 //drop out those who listed Puerto Rico.
replace state_first_job = state_residence if state_first_job == 999 //Assume the first job state is where they live if it is missing

*there are fewer than 50 codes here because not every state is represented in the lps.
recode state_first_job  ///
  (7 20 32 35 39 41 48 = 1) ///
  (2 3 8 9 10 11 18 19 21 26 28 37 44 45 47 51 = 2) ///
  (13 15/17 23/25 30 36 50 = 3) ///
  (1 4/6 12 14 33 34 38 46 49 52 = 4) ///
  , gen(region)

label val region region_lbl
***************
* occupations *
***************
destring d12x, gen(first_occ) //first occupation you had in u.s.
destring d20x, gen(occ) //occupation where you worked most hours

*Official Missing Values
mvdecode occ first_occ, mv(997 = .\998 = .\999 = .)
*Values labeled as "Coding error"
mvdecode occ first_occ, mv(181 = .\574 = .\772 = .)

replace occ = first_occ if d18x != "2" //If the job you worked most hours was not the same as first job

rename occ occ80 //make clear that these are occ80 codes

do "do/occ_groups_80"
replace occ_group = 20 if d6x == "2" // if never worked in us, characterize as unemployed

keep wgt age sex occ80 region occ_group

save "dta/lps_occ_info_only", replace

