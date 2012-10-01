clear

set obs 1000
gen occ00 = _n

recode occ00 ///
  (1/5 7/19 22/29 31/43 50/53 55/69 71 73 80 82/84 86/95 666 = 1) ///
  (6 30 70 74/79 100 102/153 160/186 200/201 204/206 220/243 255 260/286 291/292 303 305 311 313/316 321/324 434 462 752 = 2) ///
  (300/302 304 306 312 325/326 = 3) ///
  (210/211 = 4) ///
  (101 154/156 190/196 214 216 290 296 320 330/351 353/354 365 903/905 = 5) ///
  (81 85 470/471 480/482 484/493 496 = 6) ///
  (472/476 494/495 513 583 = 7) ///
  (54 72 215 244 254 483 500/512 514/582 584/594 = 8) ///
  (370/389 = 9) ///
  (390/395 = 10) ///
  (423 465 = 11) ///
  (400/416 = 12) ///
  (202 360/364 420 422 424 430 432 440 442/461 463/464 = 13) ///
  (20/21 421 425 435 600/613 = 14) ///
  (352 620/625 630/631 633/659 661/665 667/674 676/692 694/725 727/750 753/760 762/763 770/781 784 803 806 812/813 816 821 823 833 835 844/852 855/863 875/876 891/892 941 = 15) ///
  (441 783 785/802 804 810 814/815 820 822 824/832 834 836/843 853/854 864/874 880/890 893/894 896 = 16) ///
  (632 751 900 911/935 950/960 965 973/975 = 17) ///
  (626 660 675 693 726 761 895 936 942 961/964 972 = 18) ///
  (992 = 20) ///
  (980/983 = 21) ///
  (else = -1) ///
  , gen(occ_group)

drop if occ_group == -1
label values occ_group occ_group_lbl

save "dta/occ00_occ_group_xwalk", replace
