* This do file is to read 2006 IPUMS USA data
* for Latino in Indiana to count the undocumented
* using Passel method in "Adjoining Tables of Unauthorized Migrants..."
* follow closely to their method, no modification
* Modified by Maria Awal, May 21, 2008

cd z:\public\CAP
use serial age bpld yrimmig perwt using dta\usa_00022 if bpld>=10000 & yrimmig>2000, clear 

collapse (sum) perwt, by(bpld yrimmig)

list


