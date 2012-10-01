# Economic Impact of the DREAM Act Report Code

## Introduction

This repository contains the Stata code used to conduct the analysis published in the paper ["The Economic Benefits of the DREAM Act"](http://www.americanprogress.org/issues/immigration/report/2012/10/01/39567/the-economic-benefits-of-passing-the-dream-act/) (Guzman and Jara, 2012).  That report, in turn, replicates the methodology found in the paper, ["Narrative Profile with Adjoining Tables of Unauthorized Migrants and Other Immigrants, Based on Census 2000: Characteristics and Methods"](http://sabresystems.com/whitepapers/EMS_Deliverable_2-3_022706.pdf) (Passel, Van Hook, and Bean, 2000) with necessary updates do to the passage of time, as well as updating the methodology to make use of the American Community Survey (ACS) instead of the Current Population Survey (CPS).  It is highly recommended that you read the main body of "The Economic Benefits fo the DREAM Act" for background.  We also recommend reading the methodology sections of both papers to help interpret this code.  Either paper alone does not quite give a full methodology.

We, the authors of the report, are releasing this code in the spirit of openness.  The code is released under the Educational Community Licence version 1.0.  Please read the license before making use of the code.

## What is included in this repository?

The [Stata](http://www.stata.com) code (we used version 12.1) necessary to create a dataset of undocumented immigrants.
The Stata code that uses that data set to create an estimate of the direct economic impact of the DREAM Act.
Some excel and csv files necessary for the code to run.
A copy of the [Legalized Person Survey]("http://mmp.opr.princeton.edu/LPS/LPSpage.htm") dataset, for convenience.
Some CPS data relating to the economic conditions
Some select stata dta files, for convenience.

## What is not included in this repository?

1) Any of code relating to our estimate of the induced impact of the DREAM Act, which was conducted using the [IMPLAN](http://en.wikipedia.org/wiki/MIG,_Inc.) system.  Most of the analysis was conducted using IMPLAN's graphical user interface, which does not lend itself to code sharing.
2) Any of the American Community Survey data necessary for the code to run.  These files can be huge, and if you wished to run the code for a different set of years, you would need to download a different dataset anyway.  See instructions for downloading this data below.


## Some cautions

The code is not as well commented as it could be.  It is also messy in some places.  We released the code as is under the philosophy that somewhat messy code released today is more useful to community than code whose release is continually delayed because its authors never get around to cleaning it sufficiently.  Feel free to leave an issue to draw our attention to places you feel the code could be better commented or existing comments written more clearly.

The methodology makes use of some broad occupational categories to classify potentially undocumented workers.  These categories are based on census occupation codes, which do change over time.  Our analysis was of the period between 2006 and 2010.  If you apply this code to a different time period, please check that the occupation codes have not changed.  Differences in the occupation codes can cause odd results and frustrating errors.


## Requirements

We ran the code using [Stata](http://www.stata.com) version 12.1.  We have not tested the code on any other version of Stata.

The total disk space for the entire project is close to 10GB.  This amount can be reduced by using a smaller sample, e.g. a 3-year ACS sample instead of the 5-year sample we use.  See instructions on downloading necessary data below.

We recommend having at least 8gb of ram on your machine in order to execute the code in a timely manner.  It is possible to run the code with only 4gb, but there are certain join commands that can take over an hour to execute with that way.

## Instructions on downloading necessary data

We use [IPUMS USA](http://usa.ipums.org/usa) to download our ACS data.  In order to ensure that your data has the same variable names and coding, you should download your data from [IPUMS USA](http://usa.ipums.org/usa) as well, though you will need a free user account to access the data.  The [user's guide](http://usa.ipums.org/usa/doc.shtml) contains useful information on how to use IPUMs.

Once you have an account, you can select any sample you want, but for the report we used the 2010 ACS 5-year sample.  Whatever sample you select, it will need to contain the following variables:

adjust statefip gq pernum perwt momloc poploc sploc nchild relate related age sex marst race raced bpl bpld citizen yrimmig yrsusa1 hispan hispand school educ educd gradeatt gradeattd empstat empstatd labforce occ ind classwkr classwkrd wkswork2 uhrswork inctot incwage incss incwelfr incearn poverty vetstat vetstatd

Once your extract is ready, download both the Data and STATA files to this project's downloads directory.  Extract the data file.  Near the beginning of the master.do file is an obvious place to enter the precise name of your extract's do file.  Enter it before running the code.

## Running the code

First, follow the instructions on downloading necessary data above.  To run the code, simply open the master.do file at the root of the directory and click run.

The code may take a long time to execute.  You may find it helpful to comment out sections of code so as to only run some steps at a time.  The most convenient place to do this is in the master.do file.
