*1990 census occ codes are virtually identical to 1980 codes with minor differences.
gen occ90 = occ80

*Replace occ codes which don't show up in 90 codes with miscellanious equivalents
replace occ90 = 353 if occ80 == 349 // Telgraphers -> Communications equipment operators, n.e.c.
replace occ90 = 374 if occ80 == 369 // Samplers -> Material recording, scheduling, and distributing clerks, n.e.c.
replace occ90 = 444 if occ80 == 437 // Short order cooks -> Miscellaneous food preparation occupations
replace occ90 = 674 if occ80 == 673 // Apparel and fabric patternmakers -> Miscellaneous precision apparel and fabric workers
replace occ90 = 795 if occ80 == 794 // Hand grinding and polishing occupation -> Miscellaneous hand working occupations
replace occ90 = 804 if occ80 == 805 // Truck drivers, light -> Truck drives | (the 1990 cps makes no distinction between light and heavy truck drivers)


*There are 90minor code ch80anges for the same occupation description
replace occ90 = 628 if occ80 == 633 // Supervisors, production occupations
replace occ90 = 864 if occ80 == 863 // Supervisors, handlers, equipment cleaners, and laborers, n.e.c.
replace occ90 = 865 if occ80 == 864 // Helpers, mechanics and repairers
replace occ90 = 866 if occ80 == 865 // Helpers, construction trades
replace occ90 = 867 if occ80 == 866 // Helpers, surveyor
replace occ90 = 868 if occ80 == 867 // Helpers, extractive occupations
replace occ90 = 874 if occ80 == 873 // Production helpers

