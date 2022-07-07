/*HRS Life Histories*/ 

/**************************************************Dataset Compilation & Sample Construction*************************************************/ 
/*Updated: 4.5.21*/ 


options nofmterr; 


************************************************************************************************************************************************************************
/************************************************************************DATA SOURCES************************************************************************
************************************************************************************************************************************************************************/;


************************************************************************************************************************************************************************************
************************************************************TRACKER FILES************************************************************************************************************************
************************************************************************************************************************************************************************************;

/*2018 Tracker file*/


LIBNAME trk2018 "LOCATION OF DATA" ;
data trk2018; 
set trk2018.trk2018TR_R; 
run; 


proc contents data=trk2018; 
run; 

/*Look at this variable: EFTFASSIGN*/ 
/* 1= receive enhanced face to face in 2006, 2010, 2014
 	2 = receive enhanced face to face in 2008, 2012, 2016 
	9 = removed from sample prior to the 2006 data collection*/ 


proc freq data=trk2018; 
table EFTFASSIGN / missing; 
run; 

data trker (keep = OIWLANG PIWTYPE PIWLANG  EFTFASSIGN vbs16select vbs16elig vbs16consent vbs16complete vbs16valid lhms15 lhms17spr hhid pn hhidpn BIRTHYR PWHY0RWT
OIWTYPE CAMS15 KINSAMP  LINSAMP MINSAMP NINSAMP); 
set trk2018; 
hhidpn= hhid||pn;
hhidpn2= input (hhidpn, 20.);
rename hhidpn2=hhidpn;
run; 

proc contents data=trker; 
run; 

proc freq data=trker; 
table KINSAMP  LINSAMP MINSAMP NINSAMP KINSAMP*MINSAMP LINSAMP*NINSAMP KINSAMP*LINSAMP LINSAMP*MINSAMP/ missing; 
run; 

data tracker; 
set trker; 
if kinsamp = 1 or linsamp = 1 or minsamp = 1 or ninsamp = 1 then cohort = 1; 
else cohort = 0; 
run; 
proc freq data=tracker; 
table cohort; 
run; 



/*Eligible for 2015 LH: those who completed most recent core interview (2014) (OIWTYPE = 1) and were not in CAMS module (CAMS15 =99))
and completed interview in English (OIWLANG  =1 )*/ 

proc freq data=trker; 
table OIWTYPE CAMS15 OIWLANG   / missing; 
run; 

proc freq data=trker; 
table OIWTYPE / missing; 
where CAMS15 = 99 and OIWLANG = 1; 
run; 


/*Among those eligible, how many completed the LH15*/ 
proc freq data=trker; 
table LHMS15 / missing; 
where CAMS15 = 99 and OIWLANG = 1 and OIWTYPE = 1; 
run; 


/*Eligible for 2017 LH: those who completed most recent core interview by March 2017, in CAMS, and excluded HCAP, and interviewed in English*/ 

proc freq data=trker; 
table PIWTYPE  / missing; 
where CAMS15 in(1,2,5,6) and PIWLANG = 1; 
run; 

proc freq data=trker; 
table LHMS17SPR / missing; 
where  CAMS15 in(1,2,5,6) and PIWLANG = 1 and PIWTYPE = 1; 
run; 

/*Indicator variable for total life history variable*/ 

data trker1 ; 
set trker; 
if LHMS15 = 1 and CAMS15 = 99 and OIWLANG = 1 and OIWTYPE = 1 then lh15= 1; 
else lh15 =0; 
if LHMS17SPR = 1 and CAMS15 in(1,2,5,6) and PIWLANG = 1 and PIWTYPE = 1 then lh17 = 1; 
else lh17 = 0 ; 
if lh15 = 1 or  lh17 = 1 then life_history_valid = 1 ; 
else life_history_valid = 0; 
run; 

proc freq data=trker1; 
table lh15 lh17 life_history_valid / missing; 
run; 

/*VBS Variables*/ 

/*Panel participants*/
proc freq data=trker1 ; 
table vbs16select /missing ;
where life_history_valid = 1;  
run; 

/*Non-Zero Weights = 0 (not zero) */ 
proc freq data=trker1; 
table PWHY0RWT /missing; 
where life_history_valid = 1 and vbs16select = 1; run; 

/*eligible*/ 
proc freq data=trker1; 
table vbs16elig / missing; 
where life_history_valid = 1 and vbs16select = 1 and PWHY0RWT = 0; 
run; 

/*VBS consented*/ 
proc freq data=trker1; 
table vbs16consent / missing; 
where vbs16elig = 1 and life_history_valid = 1 and vbs16select = 1 and PWHY0RWT = 0; 
run; 

/*VBS Valid Test Result*/ 

proc freq data=trker1; 
table vbs16valid / missing; 
where vbs16consent=1 and vbs16elig = 1 and life_history_valid = 1 and vbs16select = 1 and PWHY0RWT = 0; 
run; 


data subset_trker (drop=hhidpn); 
set trker1; 
if vbs16consent=1 and vbs16elig = 1 and life_history_valid = 1 and vbs16select = 1 and PWHY0RWT = 0; 
hhidpn2= input (hhidpn, 20.);
rename hhidpn2=hhidpn;
a = 1; 
run; 




******************************************************************************************************************************************************
************************************************************LEAVE BEHIND QUESTIONNAIRES************************************************************
******************************************************************************************************************************************************

/*2006 Leave Behind*/ ;

LIBNAME H2006 "LOCATION OF DATA" ;
data lb2006; 
set H2006.H06LB_R;
hhidpn= hhid||pn;
hhidpn2= input (hhidpn, 20.);
run; 
data lb2006 (drop=hhidpn); 
set lb2006; 
rename hhidpn2=hhidpn;
run; 

proc contents data=lb2006; 
run; 

/*2008 Leave Behind*/ 

LIBNAME H2008 "LOCATION OF DATA" ;

data lb2008; 
set H2008.H08LB_R;;
hhidpn= hhid||pn;
hhidpn2= input (hhidpn, 20.);
run; 
data lb2008 (drop=hhidpn); 
set lb2008; 
rename hhidpn2=hhidpn;
run; 

proc contents data=lb2008; 
run; 


/*2010 Leave Behind*/ 

LIBNAME H2010 "LOCATION OF DATA" ;

DATA lb2010; 
set H2010.H10LB_R;
hhidpn= hhid||pn;
hhidpn2= input (hhidpn, 20.);
run; 

data lb2010 (drop=hhidpn); 
set lb2010; 
rename hhidpn2=hhidpn;
run; 


proc contents data=lb2010; 
run; 

/*2012 Leave Behind*/ 

LIBNAME H2012 "LOCATION OF DATA" ;
DATA lb2012; 
 SET H2012.H12LB_R;
 hhidpn= hhid||pn;
hhidpn2= input (hhidpn, 20.);

run; 

data lb2012 (drop=hhidpn); 
set lb2012; 
rename hhidpn2=hhidpn;
run; 

proc contents data=lb2012; 
run; 

************************************************************************************************************************************************************************************
************************************************************LIFE HISTORY QUESTIONNAIRES******************************************************************************************
************************************************************************************************************************************************************************************; 


/*Life Histories Questionnaires: 2015, 2017*/


libname lh "LOCATION OF DATA" ; 
run; 

data lh15; 
set lh.lhms15_R; 
run; 

data lh17; 
set lh.lhms17spr_R; 
run; 

data lh15 (drop= hhidpn hhidpn2); 
set lh15 ; 
run; 

data lh15;
set lh15 ; 
hhidpn= hhid||pn;
hhidpn2= input (hhidpn, 20.);
run; 

data lh15 (drop= hhidpn);
set lh15 ; 
rename hhidpn2=hhidpn;
run; 
proc contents data=lh15; 
run; 

data lh17 (drop= hhidpn hhidpn2); 
set lh17 ; 
run; 

data lh17;
set lh17 ; 
hhidpn= hhid||pn;
hhidpn2= input (hhidpn, 20.);
run; 

data lh17 (drop= hhidpn);
set lh17 ; 
rename hhidpn2=hhidpn;
run; 

proc contents data=lh17; 
run; 

************************************************************************************************************************************************************************************
************************************************************VBS SAMPLE AND SUPPLEMENT************************************************************************************************************************
************************************************************************************************************************************************************************************


/*VBS Full*/ 

options nofmterr; 
libname vbs "LOCATION OF DATA" ; run; 

DATA vbs; 
set vbs.HRS2016VBS;
run; 

proc contents data=vbs; 
run; 


data vbs1; 
set vbs; 
hhidpn= hhid||pn;
hhidpn2= input (hhidpn, 20.);
run; 
data vbs2 (drop = hhidpn); 
set vbs1; 
rename hhidpn2=hhidpn;
run; 
proc contents data=vbs2; 
run; 

proc print data=vbs2 (obs=100); 
var hhidpn; 
run; 


/*VBS Supplement*/ 


/*Add Il-6*/ 

libname vbs "LOCATION OF DATA" ; 
run; 

data vbssupp; 
set vbs.vbs16aa; 
run; 

data vbssupp1; 
set vbssupp; 
hhidpn= hhid||pn;
hhidpn2= input (hhidpn, 20.);

run; 

data vbssupp1 (drop= hhidpn); 
set vbssupp1; 
rename hhidpn2=hhidpn;
run; 

proc sort data=vbssupp1; 
by hhidpn; 
proc sort data=vbs2; 
by hhidpn; 
run; 

data vbs3; 
merge vbs2 (in=a) vbssupp1; 
by hhidpn; 
if a; 
run; 


/********** Tracker variables related to the VBS*/ 
/*2016 VBS SAMPLE SELECTION
VBS16SELECT            

/*2016 VBS ELIGIBLE
VBS16ELIG 
 
/*2016 VBS CONSENT
VBS16CONSENT 

/*2016 VBS COMPLETION 
VBS16COMPLETE            

/*2016 VBS VALID RESULT
VBS16VALID */ 



************************************************************************************************************************************************************************************
************************************************************COVARIATES************************************************************************************************************************
************************************************************************************************************************************************************************************



/*Covariates*/ 

;


libname rand "LOCATION OF DATA" ; 
libname library "LOCATION OF DATA" ; 

proc format LIBRARY=library cntlin= library.sasfmts; 


data hrs_long; 
set rand.randhrs1992_2016v2; 
run; 

data hrs_longV1 (keep =  hhid pn RAhhidpn S13IWSTAT
R13AGEY_B RAGENDER
RARACEM
RAHISPAN
RAEDYRS RAEDEGRM RAEDUC RAMEDUC RAFEDUC R13MSTAT R13SMOKEV R13SMOKEN R13BMI
R13SHLTC  R13HLTC R13ADLC R13conde  );  
set hrs_long; 
run; 

data hrs_longV2; 
set  hrs_longV1; 
rename RAhhidpn = hhidpn; 
run; 


data hrs_longV3; 
set hrs_longV2; 
hhidpn2= input (hhidpn, 20.);
run; 
data hrs_longV3 (drop = hhidpn); 
set hrs_longV3; 
rename hhidpn2=hhidpn;
run; 

proc contents data=hrs_longV3; 
run; 




/*Compiling Datsets*/ 

proc sort data=subset_trker; 
by hhidpn; 
proc sort data=lb2006; 
by hhidpn; 
proc sort data=lb2008; 
by hhidpn; 
proc sort data=lb2010; 
by hhidpn; 
proc sort data=lb2012; 
by hhidpn; 
proc sort data=lh15;
by hhidpn; 
proc sort data=lh17; 
by hhidpn; 
proc sort data=vbs2; 
by hhidpn;
proc sort data=vbssupp1; 
by hhidpn;
proc sort data=hrs_longV3; 
by hhidpn;
run; 

data full; 
merge subset_trker lb2006 lb2008 lb2010 lb2012 lh15 lh17 vbs2 vbssupp1 hrs_longV3 ; 
by hhidpn; 
run; 



/*Saving Dataset*/ 


libname hrs "LOCATION OF DATA" ; 
run; 

options nofmterr; 
data hrs.lh_full_2022; 
set full; 
run; 


