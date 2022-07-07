/*************************************LIFE HISTORIES PROJECT: VARAIBLE CODING*************************************/ 
/*DATE OF SET UP: 3.23.21*/ 
/*Date last modified: 4.18.22*/ 


/*Location of data*/ 

libname hrs "LOCATION OF DATA"; 
run; 

options nofmterr; 
data total; 
set hrs.lh_full_2022; 
run; 




/*Formats*/ 

proc format; 
	value parent_edf   
					0 = "8 years or less" 
					1 = "9-11 years" 
					2 = "HS Graduate" 
					3 = "Greater than HS"; 

	value racef 
					0 = "White" 
					1 = "Black" 
					2 = "Hispanic" 
					3 = "Other" ; 
	value eduf 			
					0 = "8 years or less" 
					1 = "9-11 years" 
					2 = "HS Graduate" 
					3 = "Greater than HS"; 
	value smokef 
					0 = "Never Smoker" 
					1 = "Ever Smoker" 
					2 = "Current Smoker" ; 
	value genderf
					1 = "Male" 
					2 = "Female" ; 
run; 






/*******************Life before age 16******************************************/ 

data total1; 
set total; 

if LH2A_15 = . and LH2A_17 = . then orphanage16 = . ; 
else if LH2A_15 = 1 or  LH2A_17 = 1 then orphanage16 = 1; 
else orphanage16 = 0; 

if LH2B_15 = . and LH2B_17 = . then foster16 = . ; 
else if LH2B_15 = 1 or  LH2B_17 = 1 then foster16 = 1; 
else foster16 = 0; 

if LH2C_15 = . and LH2C_17 = . then boardingsch16 = . ; 
else if LH2C_15 = 1 or  LH2C_17 = 1 then boardingsch16 = 1; 
else boardingsch16 = 0; 

if LH2E_15 = . and LH2E_17 = . then parentdeath16 = . ; 
else if LH2E_15 = 1 or  LH2E_17 = 1 then parentdeath16 = 1; 
else parentdeath16 = 0;

if LH2F_15 = . and LH2G_17 = . then mother_sep16 = . ; 
else if LH2F_15 = 1 or  LH2G_17 = 1 then mother_sep16 = 1; 
else mother_sep16 = 0;  

if LH2G_15 = . and LH2H_17 = . then father_sep16 = . ; 
else if LH2G_15 = 1 or  LH2H_17 = 1 then father_sep16 = 1; 
else father_sep16 = 0;  


run; 



/***********************************CODING BINARY INDICATORS OF DEATH AND SEPERATION**********************8*/ 

data total2; 
set total1; 
if orphanage16 = . and foster16 = . and parentdeath16 = . then p_death = . ;
else p_death = sum (orphanage16, foster16, parentdeath16); 

if mother_sep16 = . and father_sep16 = . then p_sep = . ;
else p_sep = sum (mother_sep16, father_sep16); 
run; 

proc freq data=total2; 
table p_death p_sep / missing; 
run; 



data total3; 
set total2; 
if p_death = . then pdeath_bin = . ; 
else if p_death > = 1 then pdeath_bin = 1; 
else pdeath_bin = 0; 

if p_sep = . then psep_bin = . ; 
else if p_sep > = 1 then psep_bin = 1; 
else psep_bin = 0; 

run; 

proc freq data=total3; 
table pdeath_bin psep_bin / missing; 
run; 


/*****************************************************************************************************************
************************************************VBS CODING********************************************************
******************************************************************************************************************/

/*******************CMV CODING**********************/




/*Binary CMV variable*/ 

data total4; 
set total3; 
if PCMVGINT = . then cmv = . ; 
else if PCMVGINT = 1 or PCMVGINT = 3 then cmv = 1; 
else if PCMVGINT = 2 then cmv = 0; 
run; 

data total5; 
set total4; 
if PCMVGINT = . then cmv_cont = .; 
else if PCMVGINT = 2 then cmv_cont = 0; 
else cmv_cont = pcmvge  ; 
run; 


*Dropping the one person with the outlying value*; 

data total6; 
set total5; 
if cmv_cont > 1830 then delete ; 
else cmv_contv2 = cmv_cont + 1; 
run; 

data total6; 
set total6; 
ln_cmv = log(cmv_contv2); 
run; 

proc univariate data=total6; 
var pcmvge; 
histogram; 
run; 
proc means data=total6 mean median mode q1 q3 min max; 
var pcmvge; 
run; 



/*Log Transforming IL-6 and CRP and TNF*/ 

data total7; 
set total6; 
ln_il6 = log(PIL6);
ln_crp = log(pcrp); 
ln_tnf = log(PTNFR1);
run; 

proc surveymeans data=total7 mean q1 median q3 ; 
weight  PVBSWGTR;
var ln_il6 ln_crp ln_tnf; 
run; 




/*****************smoking status*****************/ 

data total8; 
set total7; 
if R13SMOKEN = 1 and R13SMOKEV = 1 then smoke = 2; /*current smoker*/
else if R13SMOKEN = 0 and R13SMOKEV = 1 then smoke = 1; /*ever smoker*/ 
else if R13SMOKEN = 0 and R13SMOKEV = 0 then smoke = 0; /*never smoker*/ 
else if R13SMOKEN in (.M, .D, .R) and R13SMOKEV in (.M, .D, .R) then smoke = . ; 
run; 


/*Parent Edu
0: 8 years or less 
1: 9-11 years 
2: 12 years (HS Grad) 
3: Great than HS > 12 years*/ 

/*Respondent Education
0: 8 years or less 
1: 9-11 years 
2: 12 years (HS Grad) 
3: Great than HS > 12 years*/ 

proc freq data=total8; 
table RAMEDUC RAFEDUC; 
run;  


data total9; 
set total8; 
 	if RAMEDUC = .  and RAFEDUC = .  then parent_ed = . ;

else if (0 < = RAMEDUC < = 7  ) and  ( 0 < = RAFEDUC < = 8 ) then parent_ed = 0; /*Highest Ed of either parent is Less/equal than 8 Years*/ 
else if (0 < = RAMEDUC < = 8  ) and  RAFEDUC = .  then parent_ed = 0; 
else if (0 < =  RAFEDUC < = 8 )  and  RAMEDUC = .  then parent_ed = 0; 

else if (9 < = RAMEDUC < = 11 ) and  ( 9 < = RAFEDUC < = 11  ) then parent_ed = 1; /*Highest Ed of either parent is 9-11 years*/ 
else if (9 < = RAMEDUC < = 11  ) and  RAFEDUC = .  then parent_ed = 1; 
else if (9 < =  RAFEDUC < = 11 ) and  RAMEDUC = .  then parent_ed = 1; 
else if (9 < = RAMEDUC < = 11 ) and ( 0 < = RAFEDUC < = 8) then parent_ed = 1; 
else if (9 < =  RAFEDUC < = 11  ) and ( 0 < = RAMEDUC < = 8) then parent_ed = 1; 

else if  RAMEDUC = 12 and  RAFEDUC = 12 then parent_ed = 2; /*Highest Ed of either parent is HS Grad*/ 
else if RAMEDUC = 12  and  RAFEDUC = .  then parent_ed = 2; 
else if RAFEDUC = 12 and  RAMEDUC = .  then parent_ed = 2; 
else if RAMEDUC = 12 and RAFEDUC <  12 then parent_ed = 2; 
else if RAFEDUC = 12 and RAMEDUC <  12 then parent_ed = 2; 

else if  RAMEDUC > 12 and  RAFEDUC > 12 then parent_ed = 3; /*Highest Ed of either parent is > HS */ 
else if RAMEDUC > 12  and  RAFEDUC = .  then parent_ed = 3; 
else if RAFEDUC > 12 and  RAMEDUC = .  then parent_ed = 3; 
else if (RAMEDUC > 12 )  and RAFEDUC < = 12 then parent_ed = 3; 
else if (RAFEDUC > 12 ) and RAMEDUC < = 12 then parent_ed = 3; 


run; 


proc freq data=total9; 
table parent_ed / missing; 
run; 




data total10; 
set total9; 
if raedyrs  = .  then edu = .; 
else if  (0 < = raedyrs < = 8 ) then edu = 0; 
else if (9 < = raedyrs < = 11 ) then edu = 1; 
else if  raedyrs = 12 then edu = 2; 
else if  raedyrs > 12 then edu = 3;
run;  



proc freq data=total10; 
table raedyrs edu; 
run; 

/*Race/Ethnicity*/ 

proc freq data=total11; 
table RARACEM RAHISPAN race_eth /missing; 
run; 

data total11; 
set total10; 
if RARACEM in (., .M) and RAHISPAN in (., .M) then race_eth =. ; 
else if raracem = 1 and rahispan in (0, .M, .) then race_eth = 0 ; /*White*/ 
else if raracem = 2 and rahispan in (0, .M, .) then race_eth = 1 ; /*Black*/ 
else if  rahispan = 1 then race_eth = 2 ; /*Hispanic*/ 
else if raracem = 3 and rahispan in (0, .M, .) then race_eth = 3 ; /*Other*/ 
run; 


/*Marital Status*/ 

proc freq data=total11; 
table R13MSTAT /missing; 
run; 
/*Shortening to 2-level*/ 

data total12; 
set total11;
if R13MSTAT in (. , .M) then marital_stat =  . ; 
else if R13MSTAT in (1,2) then marital_stat = 1; 
else marital_stat = 0; 
run; 


/*Recoding BMI missingness */ 

data total13; 
set total12; 
if R13BMI = .M then R13BMI = . ; 
run; 




************************************************************************************************************************************************************************************
************************************************************ELIGIBILITY CRITERIA************************************************************************************************************************
************************************************************************************************************************************************************************************;



/*Eligibility Criteria: Complete outcome data, Non-zero survey weights*/ 

data total14;
set total13;
if vbs16valid = 1 and vbs16consent=1 and vbs16elig = 1 and life_history_valid = 1 and vbs16select = 1 and PWHY0RWT = 0 then eligible = 1; 
else eligible = 0; 
run; 

proc freq data=total14; 
table eligible /missing; 
run; 


data total15; 
set total14; 
if PIL6 = . or cmv = . or pcrp = . or PTNFR1 = .  then outcome_M = 1; 
else outcome_M = 0; 
run; 

data total16; 
set total15; 
if eligible = 1 and outcome_M = 0  and PVBSWGTR > 0 then eligiblev2 = 1; 
else eligiblev2 = 0; 
run; 

proc freq data=total16; 
table eligiblev2; 
run; 


/*Saving dataset*/ 

libname hrs "LOCATION OF DATA" ; 
run; 


data hrs.lh_full_2022; 
set total16; 
run; 



/*Subsetting to variables needed and only eligible observations*/ 

data subset (keep = hhidpn

/*BMI at 2016*/ 
r13BMI

/*chronic condtions*/
r13conde

/*marital status*/
r13conde

/*BMI*/
r13conde

/*Age*/
r13agey_b

ragender /*gender*/
raracem  /*race/ethnicity*/
raeduc /*education*/
rahispan /*hispanic*/
birthyr /*birth yr*/


R13ADLC
R13HLTC
R13SHLTC

eligiblev2
edu

race_eth

smoke 
parent_ed
edu 
race_eth
marital_stat
ragender  PCMVGINT 
 pcmvge cmv_cont cmv_contv2  ln_tnf ln_crp ln_il6 ln_cmv) ; 
; 
set total16; 
where eligiblev2 =1; 

run;



/*Saving Subsetted Dataset*/ 



data hrs.lh_subset ;
set subset; 
run; 
