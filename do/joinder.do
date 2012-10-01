
*combines naturalization changes, refugee and visa status with other characteristics

gen newcitizencat: newcitizencatlbl=999
label def newcitizencatlbl 0 "US-Born Citizen" 1 "Born overseas US parents" 2 "Naturalized Citizen" ///
  3 "Refugee" 4 "Temp/Under visa" 5 "Ok-welfarercpt" ///
  6 "Ok status-vet" 7 "Ok status-job" 8 "Ok status-before 1980" ///
  9 "Children ok when parents ok" 10 "Ok in legal occ group" 999 "Pot undoc"
replace newcitizencat=0 if legalstatus==0 // US Born Citizen
replace newcitizencat=1 if legalstatus==1 // US Citizen born overseas
replace newcitizencat=2 if legalstatus==2 // Naturalized US citizen
replace newcitizencat=3 if legalstatus>1 & refco==1
replace newcitizencat=4 if legalstatus>2 & (visa >0 & visa<=15)
//replace newcitizencat=5 if legalstatus>2 & ((incss>0 & incss<99999) | ( incwelfr>0 & incwelfr<99999) | foodstmp==2) //no foodstmp in census

replace newcitizencat=5 if (newcitizencat==999 | legalstatus==5) & ((incss>0 & incss<99999) | ( incwelfr>0 & incwelfr<99999))
replace newcitizencat=6 if (newcitizencat==999 | legalstatus==5) & vetstat>1
replace newcitizencat=7 if (newcitizencat==999 | legalstatus==5) & ( occ==210 | occ==211 | occ==301 | occ==306 | (occ>=370 & occ<=382) | occ==385 ///
						                             | occ==386 | occ==394 | (occ>=980 & occ<=992) )
replace newcitizencat=7 if (newcitizencat==999 | legalstatus==5) & (classwkr>=24 & classwkr<=28)
replace newcitizencat=8 if (newcitizencat==999 | legalstatus==5) & (yrimmig>=1910 & yrimmig<=1980)
* Correction for the children - if their parents are okay in status then they are okay too
sort serial pernum
by serial: replace newcitizencat=9 if (newcitizencat==999 | legalstatus==5) & (newcitizencat[poploc]<=8 | newcitizen[momloc]<=8)
replace newcitizencat=10 if (newcitizencat==999 | legalstatus==5) & occ_group_has_no_undocs

