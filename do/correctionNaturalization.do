
*correction for naturalization 

*capture rename _all, lower

gen legalstatus:legalstatuslbl = citizen
label def legalstatuslbl 0 "US Born" 1 "Born Overseas US parents" 2 "Naturalized Citizen" ///
3 "Non Citizen" 4 "Non Citizen paperwork" 5 "Pool of Potential Undoc"


* Put all people from Mexico and Central America who report as naturalized arrivg after 1980 into pool of potential undoc
replace legalstatus=5 if legalstatus==2 & yrimmig>=1980 & yrimmig<. & (bpl==200 | bpl==210) // placing Mexico and Central America in undoc pool

* Change to "Non Citizen" for "Naturalized" citizen who live in US less than 5 years, except from Mexico and Central America
replace legalstatus = 3 if (bpl !=200 & bpl !=210) & citizen==2 & yrsusa1 <=5   

* Except for those married to citizen or child of any US citizen parent, replace back to "Naturalized"

sort serial pernum
by serial: replace legalstatus = 2 if citizen==2 & yrsusa1 >=3 & sploc !=0 & legalstatus[sploc]<2
by serial: replace legalstatus = 2 if citizen==2 & ((poploc>0 & legalstatus[poploc]<=2) | (momloc>0 & legalstatu[momloc]<=2))

* For children born overseas of US parents, change to "Non Citizen" if they have their parents are no US Citizen
by serial: replace legalstatus = 3 if citizen==1 & (poploc+momloc>0) & !((poploc>0 & legalstatus[poploc]<=2) | (momloc>0 & legalstatus[momloc]<=2)) 

tab legal [fw=perwt*5]
