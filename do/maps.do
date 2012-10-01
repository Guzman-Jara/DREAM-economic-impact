*Creation of maps. Results from DREAM Act impact.

cd z:\public\CAP
clear

set more off

import excel using xl\SUMMARYIMPACTSbyState.xlsx, firstrow

merge 1:1 fip using z:\private\maps\usa\state\USstate, keep(match)


egen TI=rowtotal(TI2010 TI2020 TI2030) 
gen TI_billions = TI/1e9
format TI_billions %10.0fc
spmap Freq using Z:\private\maps\usa\state\USstate_coord if _ID!=31 & _ID!=39, id(_ID) fcolor(Rainbow) ///
      clmethod(custom) clbreaks(0,10000,50000,100000,1.2e6) ///
      legenda(on)
spmap TI_b using Z:\private\maps\usa\state\USstate_coord if _ID!=31 & _ID!=39, id(_ID) fcolor(Greens) ///
      clmethod(custom) clbreaks(0,1,10,150) ///
      legenda(on) legtitle("2012 Billions $" ) legstyle(2)
