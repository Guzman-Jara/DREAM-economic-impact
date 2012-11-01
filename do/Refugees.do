//Counting refugees
display("begginning of file")
gen refco: refcolbl = .
display("After refco")
replace refco=1 if bpld==43000  & ((yrimmig>=1982 & yrimmig<=1984) | (yrimmig >=1990 & yrimmig<=1992))  									//Albania
replace refco=1 if bpld==45100  & ((yrimmig==1983 | (yrimmig>=1985 & yrimmig<=1988)))                                                   		//Bulgaria
replace refco=1 if bpld==45400  & ((yrimmig>=1982 & yrimmig<=1988))                                                                                          //Hungary
replace refco=1 if bpld==45500  & ((yrimmig>=1982 & yrimmig<=1983))                                                                                          //Poland
replace refco=1 if bpld==45600  & ((yrimmig>=1981 & yrimmig<=1989))                                                                                          //Romania
replace refco=1 if bpld==45200  & ((yrimmig>=1981 & yrimmig<=1986))                                                                                          //Czechoslovakia
replace refco=1 if bpld==45700  & (((yrimmig>=1993 & yrimmig<=1999) | yrimmig==2000)) //check year immg used to be 1 for this old value, repl as 2000        //Yugoslavia
replace refco=1 if (bpld>=46500 & bpld<=46999)   & ((yrimmig>=1980 & yrimmig<=1982)|(yrimmig>=1995 & yrimmig<=1997) ///                                       //Other USSR/Russia
                                | (yrimmig>=1987 & yrimmig<=1994 & runiform()<.80))
display("after other ussr")
replace refco=1 if bpld==52000  & ((yrimmig>=1980 & yrimmig<=1993) | yrimmig==2000)                                                                          //Afghanistan
replace refco=1 if bpld==52200  & ((yrimmig>=1984 & yrimmig<=1989) | yrimmig==2000)                                                                          //Iran
replace refco=1 if bpld==53200  & ((yrimmig==1981 | yrimmig==1983  | (yrimmig>=1991 & yrimmig<=1999) | yrimmig==2000))                                       //Iraq
replace refco=1 if bpld==54100  & (yrimmig>=1993 & yrimmig<=1994)                                                                                            //Syria
replace refco=1 if bpld==52130  & (yrimmig==1999 | yrimmig==2000  )                                                                                          //Burma (Myanmar)
replace refco=1 if bpld==51100  & (yrimmig>=1980 & yrimmig<=1990)                                                                                            //Cambodia (Kampuchea)
replace refco=1 if bpld==51300  & (yrimmig>=1980 & yrimmig<=1996)                                                                                            //Laos
replace refco=1 if bpld==51800  & ((yrimmig>=1980 & yrimmig<=1984 & runiform()<.65) |(yrimmig>=1985 & yrimmig<=1989)  ///                                                     //Vietnam
                                | (yrimmig>=1990 & yrimmig<=1994 & runiform()<.75)  |(yrimmig>=1995 & yrimmig<=1996))
replace refco=1 if bpld==60011  & (yrimmig==1996 | yrimmig ==2000)                                                                                           //Algeria
replace refco=1 if bpld==60071  & yrimmig==1990                                                                                                              //Angola
display("after Angola")
replace refco=1 if bpld==60041  & (yrimmig>=1998 | yrimmig<=1999)                                                                                            //Burundi
replace refco=1 if bpld==60072  & yrimmig==2000                                                                                                              //Cameroon
replace refco=1 if bpld==60075  & ((yrimmig>=1991 & yrimmig<=1999) | yrimmig==2000)                                                                          //Congo
replace refco=1 if bpld==60022  & (yrimmig==1996 | yrimmig==1998)                                                                                            //Gambia
replace refco=1 if bpld==60027  & ((yrimmig>= 1992 & yrimmig<=1999) | yrimmig==2000)                                                                         //Liberia
replace refco=1 if bpld==60013  & yrimmig==1990                                                                                                              //Libya
replace refco=1 if bpld==60029  & ((yrimmig>=1995 & yrimmig<=1996) | (yrimmig>=1998 & yrimmig<=1999))                                                        //Mauritania
replace refco=1 if bpld==60030  & (yrimmig==1996 | yrimmig==1998   | yrimmig==1999)                                                                          //Niger
replace refco=1 if bpld==60051  & ((yrimmig>=1994 & yrimmig<=1997)| yrimmig==1999 | yrimmig==2000)                                                           //Rwanda
replace refco=1 if bpld==60033  & ((yrimmig>=1998  & yrimmig<=1999)| yrimmig==2000)                                                                          //Sierra Leone
replace refco=1 if bpld==60053  & ((yrimmig>=1988 & yrimmig<=1999) | yrimmig==2000)                                                                          //Somalia
replace refco=1 if bpld==60015  & ((yrimmig>=1991 & yrimmig<=1999) | yrimmig==2000)                                                                          //Sudan
replace refco=1 if bpld==60034  & (yrimmig==1994 | yrimmig ==1999  | yrimmig==2000)                                                                          //Togo
replace refco=1 if bpld==60055  & yrimmig==1991                                                                                                              //Uganda
display("after cuba")
replace refco=1 if bpld==60044  & ((yrimmig>=1980 & yrimmig<=1994) | yrimmig==1999 | yrimmig==2000)                                                          //Ethiopia
replace refco=1 if bpld==60065  & ((yrimmig>=1980 & yrimmig<=1994) | yrimmig==1999 | yrimmig==2000)                                                          //Eritrea
replace refco=1 if bpld==25000  & ((yrimmig>=1980 & yrimmig<=1981) | (yrimmig>=1988 & yrimmig<=1989) ///                                                     //Cuba
                                & (yrimmig>=1991 & yrimmig<=1999)  | yrimmig==2000)
replace refco=1 if bpld==26020  & ((yrimmig>=1987 & yrimmig<=1988) | (yrimmig>=1992 & yrimmig<=1993))                                                        //Haiti

replace refco=1 if bpld==21060  & (yrimmig>=1987 & yrimmig<=1988)                                                                                            //Nicaragua
replace refco=1 if bpld==95000  & yrimmig==1995                                                                                                              //Other, nec
label def refcolbl 0 "non-refugee country" 1 "refugee country"                                                                                              //
do do/extra_refugees.do

save "dta/temp", replace
use "dta/temp", clear

merge m:1 yrimmig bpld using dta/refugees, keepusing(TotalRefugees ratio TotalRegion region) keep(master matched)

display "After the merge"
replace refco =1 if region==1 & ratio>.3722 & ratio <. & yrimmig>2000 & yrimmig<.
replace refco =1 if region==2 & ratio>.2545 & ratio <. & yrimmig>2000 & yrimmig<.
replace refco =1 if region==3 & ratio>.3073 & ratio <. & yrimmig>2000 & yrimmig<.
replace refco =1 if region==5 & ratio>.2632 & ratio <. & yrimmig>2000 & yrimmig<.

capture program drop ratiothreshold
program define ratiothreshold
preserve

	tempfile original small
	tempvar refugee2001 diff
	gen `refugee2001' = .
	sort serial pernum
	qui save `original', replace
foreach i in 1 2 3 5 {
	use `original', clear
/*	keep if region==`i'
	save `small', replace*/
	local ratio = .5
	local lratio=0
	local uratio=1
	while abs(`uratio'-`lratio')>.0001 {
		* di "Ratio = " `ratio' _n " Sum = " `sum' _n "uratio = " `uratio'  " lratio = " `lratio'
		qui replace `refugee2001' = ratio>`ratio' if region==`i'
		qui by serial: replace `refugee2001' = 1 if (`refugee2001'[momloc]==1 | `refugee2001'[poploc]==1) & region== `i'
		collapse (sum) `refugee2001' (mean) ratio TotalRegion [fw=perwt] if region==`i' & yrimmig>2000 & yrimmig<., by(yrimmig)
		gen `diff' = `refugee2001'-TotalRegion
		qui summ `diff'
		local sum = r(sum)
		if `sum'<0 {
			local uratio = `ratio'
			local ratio = (`lratio'+`ratio')/2
		}
		else {
			local lratio = `ratio'
			local ratio = (`ratio'+`uratio')/2
		}
		use `original', clear

	}
di in smcl "{hline} {center:Region =  `i'}" _n  "{center:Ratio =  `ratio'} " _n "{hline}"
}

end
*ratiothreshold


//Correction for Refugee Children
sort serial pernum
by serial: gen refchild: refchildlbl = (refco[poploc]==1 | refco[momloc]==1)
replace refco=1 if citizen>=2 & refchild==1
