*this program creates educational transition rates from average changes in synthesize cohorts


capture program drop eductranrate
program define eductranrate

syntax varlist [fweight pweight/] [if], [BY(varlist)] [AGEG(numlist)]

if "`if'"!="" keep `if'

keep `varlist' `exp' `by'
tokenize `varlist'
local multyear `1'  //measure of different years
local degrees `2'   //Education in groups
local age `3'  //Single age
* ageg if you want to specify new agegroup....if so need to modify program

/*capture recode educd (0/61 = 0 "Less than High School") (62/64 = 1 "Completed High School") (65/71=2 "Some College") ///
	(81 = 3 "Associate's Degree") (101 = 4 "Bachelor's Degree" ) (114/116 = 5 "Higher than Bachelor's Degree") ///
	(*=.), gen(degreesCertificates)
*/


if "`ageg'"=="" local ageg 0,5(5)80, 100
else local ageg: subinstr local ageg " " ", ", all
*tempvar agegroup
egen agegroup= cut(`age'),at(`ageg')  // creates age groups

if "`exp'" == "" {
	tempvar exp
	gen `exp'=1
}

collapse  (sum) population=`exp', by(`multyear' agegroup `degrees' `by')
*collapse  (sum) population=pwgtp ,by(multyear AgeGroup degreesCertificates Female Hispanic )

reshape wide population, i(`multyear' agegroup `by') j(`degrees')
rename population0 lessthanhighschool
rename population1 completedhighschool
rename population2 somecollege
rename population3 associatesdegree
rename population4 bachelorsdegree
rename population5 higherthanbachelor
gen na = .
keep if agegroup>5 & agegroup <40
egen total = rowtotal(less com some ass bach high na)
sort `multyear' `by' agegroup
by `multyear' `by': gen normal = cond(_n>1,total[1]/total,1)

gen people1 = less*normal
gen people2 = comp*normal
gen people3 = some*normal
gen people4 = ass*normal
gen people5 = bach*normal
gen people6 = highe*normal

drop less high some ass bach na

keep `by' `multyear' agegroup people?
reshape long people@, i(`multyear' agegroup `by') j(level)

sort `multyear' `by' agegroup level
label define level 1 "LtHS" 2 "HS" 3 "sm" 4 "AA" 5 BA 6 "BB+"
label value level level
by `multyear' `by' agegroup: egen HighSchShare = total(people) if level>=2
replace HighSchS = people / HighS
by `multyear' `by' agegroup: egen PostSecShare = total(people) if level>=3
replace PostSec = people/ PostSec
by `multyear' `by' agegroup: egen PostScShare = total(people) if level>=4
replace PostSc = people/ PostSc
by `multyear' `by' agegroup: egen PostAAShare = total(people) if level>=5
replace PostAA = people/ PostAA


by `multyear' `by': gen lths = people[_n+6] if level==1  //lhs --> lths

by `multyear' `by': gen hs = (people-lths)*HighSch[_n+7] if level == 1  // hs = tot population - lths-1
by `multyear' `by': replace hs = people[_n+6] - hs[_n-1] if level==2

by `multyear' `by': gen sc = (people-lths)*HighSch[_n+8] if level==1
by `multyear' `by': replace sc = (people-hs)*PostSec[_n+7] if level==2
by `multyear' `by': replace sc = people[_n+6] - sc[_n-1]-sc[_n-2] if level==3

by `multyear' `by': gen aa = (people-lths)*HighSch[_n+9] if level==1
by `multyear' `by': replace aa = (people-hs)*PostSec[_n+8] if level==2
by `multyear' `by': replace aa = (people-sc)*PostSc[_n+7] if level==3
by `multyear' `by': replace aa = people[_n+6] - aa[_n-1] -aa[_n-2] - aa[_n-3] if level==4

by `multyear' `by': gen ba = (people-lths)*HighSch[_n+10] if level==1
by `multyear' `by': replace ba = (people-hs)*PostSec[_n+9] if level==2
by `multyear' `by': replace ba = (people-sc)*PostSc[_n+8] if level==3
by `multyear' `by': replace ba = (people-aa)*PostAA[_n+7] if level==4
by `multyear' `by': replace ba = people[_n+6] - ba[_n-1] -ba[_n-2] - ba[_n-3]- ba[_n-4] if level==5

by `multyear' `by': gen bap = (people-lths)*HighSch[_n+11] if level==1
by `multyear' `by': replace bap = (people-hs)*PostSec[_n+10] if level==2
by `multyear' `by': replace bap = (people-sc)*PostSc[_n+9] if level==3
by `multyear' `by': replace bap = (people-aa)*PostAA[_n+8] if level==4
by `multyear' `by': replace bap = (people-ba) if level==5
by `multyear' `by': replace bap = people  if level==6

format people lths hs sc aa ba bap %12.0gc
*drop if age>30

*drop ha total1

by `multyear' `by': gen total1 = people[1]



gen lthsRate = lths/people
gen hsRate = hs/people
gen scRate = sc/people
gen aaRate = aa/people
gen baRate = ba/people
gen bapRate = bap/people
sort `by' agegroup level `multyear'

foreach i of varlist *Rate {
	replace `i' = 1 if `i'>1 & `i'!=.
	replace `i' = 0 if `i' <0
	}


keep `by' agegroup level multyear *Rate
collapse (mean) *Rate, by(agegroup `by' level)
*replace agegroup=agegroup+5
*table agegroup

*reshape wide lths hs sc aa baR bap, i(`by' level) j(agegroup)
reshape long  @Rate, i( `by' agegroup level) j(NextLevel) string  //this line depends on specific age groups; needs modification if changed
gen Nextlevel:level = 1 if NextL == "lths"
replace Nextl = 2 if NextL == "hs"
replace Nextl = 3 if NextL == "sc"
replace Nextl = 4 if NextL == "aa"
replace Nextl = 5 if NextL == "ba"
replace Nextl = 6 if NextL == "bap"
sort `by' level Nextl
drop NextLevel
forvalues i=10(5)35 {
	if `i'<10 | `i'>35 	gen Rate = 0  if agegroup==`i'
	replace Rate = 0 if Rate<1e-6
	mvencode Rate,mv(0) ov
}
order Rate*, alpha
order `by' level Next* , first

end

