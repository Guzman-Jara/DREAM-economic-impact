capture drop region

recode statefip ///
  (09 23 25 33 44 50 34 36 42 = 1) ///
  (17 18 26 39 55 19 20 27 29 31 38 46 = 2) ///
  (10 11 12 13 24 37 45 51 54 01 21 28 47 05 22 40 48 = 3) ///
  (04 08 16 30 32 35 49 56 02 06 15 41 53 = 4) ///
  , gen(region)
