/**Table 1 Coding: Life Histories Manuscript****/


libname HRS "LOCATION OF DATA" ; run; 


data lh; 
set hrs.lh_full_2022; 
run; 

proc contents data=lh; 
run; 


/*Formats*/ 


proc format; value maritalf 
0 = "Married/Partnerned"
1 = "Separated/Divorced" 
2 = "Widow" 
3 = "Never Married"; 
run; 

proc format; 
value mlrf 0 = "Low" 
1 = "Medium" 
2 = "High" ; 
run; 

proc format; value smokef
0 = "Never Smoker"
1 = "Former Smoker"
2 = "Current Smoker"; 
run; 


proc format; 
value genderf 
1 = "Male" 
2= "Female" ; 
run; 

proc format; value chld_healthf 
1 = "Excellent" 
2 = "V Good" 
3 = "Good" 
4 = "Fair" 
5 = "Poor" 
; 
run; 



proc format; 

value educf 0 = 'Less than HS' 
			1 = 'HS grad' 
			2 = 'Some college' 
			3 = 'College grad and above' ; 
value genderf 
1 = "Male" 
2= "Female" ; 

value racef 
0 = "Non-Hispanic White" 
1 = "Non-Hispanic Black" 
2 = "Hispanic" 
3 = "Other Race" ; 

value parentedf  0 = '8 Years or Less'
				1= '9-11 Years' 
				2 = 'HS Graduate' 
				3 = 'Greater than HS\' ; 
run; 


/*Continuous varibles*/ 



ods graphics on; 
proc surveymeans data=lh mean  nobs nmiss ;
weight PVBSWGTR; 
var  ln_cmv ln_crp ln_tnf ln_il6 R13AGEY_B  R13SHLTC R13HLTC R13CONDE  R13ADLC ; 
where eligiblev2=1;
run; 

/*stratified by Parental Death*/ 

proc sort data=lh; 
by eligiblev2 pdeath_bin; 
run; 

ods graphics on; 
proc surveymeans data=lh mean  nobs nmiss ;
weight PVBSWGTR; 
domain pdeath_bin; 
var  ln_cmv ln_crp ln_tnf ln_il6 R13AGEY_B  R13SHLTC R13HLTC R13CONDE  R13ADLC R13BMI ; 
where eligiblev2=1;
run; 

/*Stratified by Parental Separation*/ 

proc sort data=lh; 
by eligiblev2 psep_bin; 
run; 

ods graphics on; 
proc surveymeans data=lh mean  nobs nmiss ;
weight PVBSWGTR; 
domain psep_bin; 
var  ln_cmv ln_crp ln_tnf ln_il6 R13AGEY_B  R13SHLTC R13HLTC R13CONDE  R13ADLC R13BMI ; 
where eligiblev2=1;
run; 


/*Categorical Variables*/

proc surveyfreq data=lh; 
weight pvbswgtr; 
format RAgender genderf. race_eth racef. edu educf. smoke smokef. parent_ed parentedf. ; 
table  pdeath_bin psep_bin RAgender race_eth parent_ed edu smoke / col row  ;  
where eligiblev2 = 1; 
run;

/*By parental death*/ 

proc surveyfreq data=lh; 
weight pvbswgtr; 
format RAgender genderf. race_eth racef. edu educf. smoke smokef. parent_ed parentedf. ; 
table  pdeath_bin*( psep_bin RAgender race_eth parent_ed edu smoke) / col row ;  
where eligiblev2 = 1; 
run;

proc freq data=lh; 
format RAgender genderf. race_eth racef. edu educf. smoke smokef. parent_ed parentedf. ; 
table  pdeath_bin*( psep_bin RAgender race_eth parent_ed edu smoke)/ missing; 
where eligiblev2 = 1; 
run;



/*By parental Sep*/ 

proc surveyfreq data=lh; 
weight pvbswgtr; 
format RAgender genderf. race_eth racef. edu educf. smoke smokef. parent_ed parentedf. ; 
table  psep_bin*( pdeath_bin RAgender race_eth parent_ed edu smoke) / col row ;  
where eligiblev2 = 1; 
run;

proc freq data=lh; 
format RAgender genderf. race_eth racef. edu educf. smoke smokef. parent_ed parentedf. ; 
table  psep_bin*( pdeath_bin RAgender race_eth parent_ed edu smoke)/ missing; 
where eligiblev2 = 1; 
run;



/*Race-Stratified Table*/ 
ods graphics on; 
proc surveymeans data=lh mean  nobs nmiss ;
format race_eth racef.; 
weight PVBSWGTR; 
var  ln_cmv ln_crp ln_tnf ln_il6  ; 
where race_eth = 3 and eligibleV2= 1; 
run; 


proc surveyfreq data=lh; 
weight pvbswgtr; 
format RAgender genderf. race_eth racef. edu educf. smoke smokef. parent_ed parentedf. ; 
table  race_eth*(pdeath_bin psep_bin) / col row  ;  
where  eligibleV2= 1; 
run;



proc freq data=lh; 
format  race_eth racef. edu educf. smoke smokef. parent_ed parentedf. ; 
table  race_eth*(pdeath_bin psep_bin) / missing  ; 
where eligibleV2 = 1;  
run;
