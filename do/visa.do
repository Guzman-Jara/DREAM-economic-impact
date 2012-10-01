
*Counting legal temporary residents

//Account legal temporary visa holders
gen visa:visalbl=0
label def visalbl 0 "N/A" 1 "A" 2 "F-1/M-1" 3 "J-1/Vist Prof" 4 "J-1/Grad Asst" 5 "J-1/Med" 6 "H1/Nurse " 7 "H-2/Agri" ///
8 "H-1B" 9 "L-1" 10 "G-1" 11 "R-1" 12 "O-1/P-1" 13 "J-1/HS" 14 "AuPair" 15 "Spouse-Dep"

* Diplomat (A-visa)

gen occ3= floor(occ/10)
gen ind3= floor(ind/10)

replace visa=1 if legalstatus>=3 & labforce==2 & yrsusa1<=10 & (occ3==2 | occ3==43) & ind3==959 

* Servants of Diplomat (A-visa)
replace visa=1 if legalstatus>=3 & yrsusa1<=10 & relate==12 & (occ3==461 | occ3==465) & ind3==959 & refco !=1 

* Students (F-1/M-1 visa)
replace visa=2 if legalstatus>=3  & (age>=17 & age<= 64) & educ>=7 & (gradeatt==6 | gradeatt==7) 
replace visa=0 if visa==2 & uhrswork >25 &  (ind3==787 | ind3==746) // can't work more than 25 hours on campus
replace visa=0 if visa==2 & uhrswork >20 & !(ind3==787 | ind3==746) // can't work more than 20 hours off campus

* Visiting Prof or Grad Assistants (J-1 / F-1 / M-1 visa)
replace visa=3 if legalstatus>=3 & labforce==2 & yrsusa1<=5 & (ind3==746 | ind3==787)  /// 
					     & ( occ3==220 | (occ3>=130 & occ3<=153) ///
               | occ3==100 | occ3==102 | (occ3>=111 & occ3<=124) | (occ3>=160 & occ3<=176) ///
					     | (occ3>=180 & occ3<=186) | occ3==301 | occ3==303 | occ3==304 | occ3==306 | occ3==312 ///
					     | occ3==314 | occ3==325 ) 
replace visa=4 if visa==3 & yrsusa1<=7 & (age <35 | inctot <17500 | uhrswork < 30)

*Doctor or Med student (J-1 visa)
replace visa=5 if legalstatus>=3 & labforce==2 & yrsusa1<=3 & classwkr !=1 & !(ind3>=797 & ind3<=808) ///
							 & (ind3==819 | ind3==827 | ind3==818 | ind3==809)  ///
					     & ( occ3==301 | occ3==306 | occ3==314 | occ3==165 | occ3==326 | occ3==315 | occ3==316 ///
					     | occ3==320 | occ3==322 | occ3==323  ) 
replace visa=4 if visa==5 & ind3==787 & (inctot <15000 | uhrswork < 30)

*Registered nurse (H-1 visa)
replace visa=6 if legalstatus>=3 & labforce==2 & yrsusa1 <=3 & (occ3==313 | occ3==350) & classwkr !=1 & !(ind3>=797 & ind3<=808) ///
					     & (ind3==819 | ind3==827 | ind3==818 | ind3==809 ) 
replace visa=4 if visa==6 & ind3==787 & (inctot <20000 | uhrswork < 30)

*Agricultural worker (H2 visa)				     
replace visa=7 if legalstatus>=3 & labforce==2 & yrsusa1 <=3 & bpld==26030 & (occ3==20 | occ3==600 | occ3==605)

*Hitech worker (H1B visa)
replace visa=8 if legalstatus>=3 & labforce==2 & yrsusa1<=3 & classwkr==2 & educ>=10 ///
					     & ( (occ3>=130 & occ3<=153) | (occ3>=100 & occ3<=124) | (occ3>=160 & occ3<=186) | occ3==281 | occ3==283 ///
					     | occ3==284 | (occ3>=154 & occ3<=156) | (occ3>=190 & occ3<=196) | occ3==903 | occ3==290 | occ3== 790 | occ3==813 ) ///

*Intra Company transfer (L-1 visa)
replace visa=9 if legalstatus>=3 & labforce==2 & yrsusa1<=3 & classwkr==2  ///
		   				 & ( (occ3>=1 & occ3<=20) | occ3==22 | occ3==30 | occ3==31 | (occ3>=33 & occ3<=43) ///
               | (occ3>=51 & occ3<=53) | occ3==60 | occ3==62 | occ3==70 | occ3==71 | occ3==73 | occ3==80 ///
               | (occ3>=82 & occ3<=84) | occ3==86 | occ3==95 | occ3==480 | occ3==484 | occ3==485 | occ3==493 ///
               | occ3==430 | occ3==432 | occ3==470 | occ3==471 | occ3==500 | occ3==600| occ3==620 | occ3==700 | occ3==770 ///
               | occ3==282 ) 

*International Org (G-1 visa)
replace visa=10 if legalstatus>=3 & labforce==2 & yrsusa1<=3 & classwkr==2 & ind3==959 ///
               & ( (occ3>=130 & occ3<=153) | (occ3>=100 & occ3<=124) | (occ3>=160 & occ3<=186) | occ3==281 | occ3==283 ///
					     | occ3==284 | (occ3>=154 & occ3<=156) | (occ3>=190 & occ3<=196) | occ3==903 | occ3==290 | occ3== 790 | occ3==813  ///
 							 | (occ3>=1 & occ3<=20) | occ3==22 | occ3==30 | occ3==31 | (occ3>=33 & occ3<=43) ///
               | (occ3>=51 & occ3<=53) | occ3==60 | occ3==62 | occ3==70 | occ3==71 | occ3==73 | occ3==80 ///
               | (occ3>=82 & occ3<=84) | occ3==86 | occ3==95 | occ3==480 | occ3==484 | occ3==485 | occ3==493 ///
               | occ3==430 | occ3==432 | occ3==470 | occ3==471 | occ3==500 | occ3==600| occ3==620 | occ3==700 | occ3==770 ///
               | occ3==282 )
               
*Religious worker (R-1 visa)
replace visa=11 if legalstatus>=3 & labforce==2 & yrsusa1<=6 & (occ3>=204 & occ3<=206)  

*Athlete & Entertainer (O-1/P-1 visa)
sort serial pernum
by serial: replace visa=12 if poploc !=0 & momloc !=0 & legalstatus>=3 & labforce==2 & (classwkrd>=13 & classwkrd<=23) ///
		& yrsusa1<=3 & (inctot>=30000 & inctot<=999999) ///
		    & ( ind3==647 | ind3==648 | ind3==199 | ind3==657 | ind3==659 | ind3==859 | ind3==857   | ind3==856 ) ///
		    & ( occ3==260 | occ3==263 | occ3==270 | occ3==271 | occ3==272 | (occ3>=274 & occ3<=276) | occ3==285 | occ3==291 )

*High School exchange student (J-1 visa)
sort serial pernum
by serial: replace visa=13 if legalstatus>=3 & yrsusa1<=3 & marst==6 & relate==12 & momloc==0 & poploc==0 & (age>=14 & age<=16) & (gradeatt==4 | gradeatt==5) ///
		    & bpl != bpl[1]

*Au Pair (J-1 visa)
sort serial pernum
by serial: replace visa=14 if legalstatus>=3 & yrsusa1<=4 & sploc==0 & poploc==0 & momloc==0 & relate==12 & nchild[1] !=0 & (occ3==460 | occ3==461) 

*spouse and dependent
sort serial pernum
by serial: replace visa=15 if legalstatus>=3 & sploc!=0 & classwkr==0 & (visa[sploc]==2 | (visa[sploc]>=6 & visa[sploc]<=8) | visa[sploc]==11 )
by serial: replace visa=15 if legalstatus>=3 & sploc!=0 & classwkr>=0 & (visa[sploc]==1 | (visa[sploc]>=3 & visa[sploc]<=5) | visa[sploc]==9 | visa[sploc]==10 | visa[sploc]==12 )
by serial: replace visa=15 if legalstatus>=3 & ( (visa[poploc]>0 & visa[poploc]<=15) | (visa[momloc]>0 & visa[momloc]<=15) )
 
