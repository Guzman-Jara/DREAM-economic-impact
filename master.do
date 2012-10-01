set more off

****************************
* Create initial data file *
****************************
cd downloads
do "Insert the name of the do file associated with your IPUMS data extract here."
save "dta/inital_acs_data", replace

********************************************
* Legalize Population Survey Sub-directory *
********************************************
*If you are running this data using 2006-2010 ACS 5 year sample, this section can safely remain
*commented out, as the dta file this subproject creates is included with the repository

**first run the Legalized Person Survey master do file
*cd lps
*do master
*cd ..


*********************************************
* CREATE DATASET OF UNDOCUMENTED IMMIGRANTS *
*********************************************
do do/fns
do do/globals

do do/mergingrefugeeswithpopulation

************************
* Create Distributions *
************************
*Go through once with just 2008 to confirm if our probabilities are correct
use dta/initial_acs_data if multyear == 2008, clear

replace perwt = perwt * 5

gen fborn:fb=(bpl>120 & bpl<=950) //anybody born ouside of US territories
label def fb 0 "US Born"  1 "Foreign Born"

gen latino:latinolbl= hispan>0 & hispan<.
label def latinolbl 0 "Non Hispanic" 1 "Hispanic"

gen hhead:head= relate==101
label def head 0 "Other" 1 "Head"
rename Y, lower

do "do/correctionNaturalization"

do "do/Refugees"

do "do/visa"
do "do/drop_out_bad_occ_groups"

do "do/joinder"

save "dta/ready_to_redistribute_occs_2008", replace

use "dta/ready_to_redistribute_occs_2008", clear
do "do/tabulate_undoc_pool"

do "do/calculate_inital_dist_percents"
do "do/distribute_potential_undoc"
do "do/adjust_undoc_totals_down"
do "do/confirmation_tables"
save "dta/2008_undocumented", replace

********************
* Run full dataset *
********************
*Now go through the whole dataset using percents based on 2008
use "dta/initial_acs_data", clear

gen fborn:fb=(bpl>120 & bpl<=950) //anybody born ouside of US territories
label def fb 0 "US Born"  1 "Foreign Born"

gen latino:latinolbl= hispan>0 & hispan<.
label def latinolbl 0 "Non Hispanic" 1 "Hispanic"

gen hhead:head= relate==101
label def head 0 "Other" 1 "Head"
rename Y, lower

do "do/correctionNaturalization"

do "do/Refugees"

do "do/visa"
do "do/drop_out_bad_occ_groups"

do "do/joinder"

save "dta/ready_to_redistribute_occs_2006_2010", replace

use "dta/ready_to_redistribute_occs_2006_2010", clear
do "do/tabulate_undoc_pool"
do "do/distribute_potential_undoc"
do "do/adjust_state_totals"
do "do/adjust_undoc_totals_down"
do "do/confirmation_tables"

save "dta/2006-2010_undocumented", replace
*
do "do/combine_undocumented_with_full_dataset"
*
save "dta/2006-2010_full_plus_undocumented", replace

*****************************
* DIRECT IMPACT ON DREAMERS *
*****************************
do "do/Earnings and College changes"
do "do/DreamersByState"
