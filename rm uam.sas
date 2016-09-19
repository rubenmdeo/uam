/*Program uam.sas    					*/
/*Analisis de IMC datos de Manuel-UAM*/

libname uam "/folders/myfolders/rubensas/uam/data/";

%let program_name=rmuam;

title "Analisis de IMC UAM";
filename reffile "/folders/myfolders/rubensas/uam/data/encuestas calidad de vida.xlsx";
/*
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

proc contents data=import; run;

proc contents data=uam.uam1; run;

proc print label data=uam.uam1;
title2 "2113076334	julionava@gmail.com	M	29	SI	4	SI	6	7	2	4	1	5	";
title3 "1	1	3	3	3	2	2	5	1	2	1	4	4	4	6	3	4	SI	SI	NO	10	";
title4 "NO	162	61.4	16	4	49		NO";
;
where matricula in ('2113076334','2102038075');
run;

*/

proc format;

value autopeso_num
.N="Autoweight is 'No'";

*label autopeso='Knows own weight (y/n):;
value autopeso_yes
0="No"
1='Yes';

value imc_class
1='Low weight'
2='Normal weight'
3='Overweight'
4='Obese';

value yesno
1='Yes'
2='No'
0='No';

value genero
1='Male';

run;

data work.uam1;
set uam.uam1;

**BMI:;
if peso_n ne . then do;
imc=peso_n/((estatura/100)**2);
end;

if 0<imc<=18.5 then imc_class=1;
	else if 18.5<=imc<25 then imc_class=2;
	else if 25<imc<30 then imc_class=3;
	else if imc>=30 then imc_class=4;

format 
autopeso_num autopeso_num.
autopeso_yes autopeso_yes.
imc_class imc_class.
trabajas2 yesno.
OBESFAM2 YESNO.
;
run;
/*
proc means n nmiss min max data=work.uam1;
title2 "Checking definitions";
*class imc_class;
var estatura peso_n autopeso_num imc;
run;
proc print n noobs data=work.uam1;
where estatura=. or autopeso_num=. or peso_n=.;
var estatura autopeso: peso_n;
run;

proc freq data=uam.uam1(drop=matricula email );
tables _char_;
run;

proc means n nmiss min median max data=uam.uam1;
run;

*/


ods listing close;
ods rtf file="/folders/myfolders/rubensas/uam/lst/&PROGRAM_NAME &SYSDATE9..rtf";

proc tabulate data=work.uam1 format=comma15.0;
title2 "A. Statistics known or not own weight";
where imc ne .;
class autopeso_yes imc_class;
var peso_n autopeso_num imc;

tables (autopeso_yes='Knows own weight (y/n)'* 
			(peso_n='Measured weight' autopeso_num='Known weight' )),
		(n='N' (min='Min' q1='25th percentile' median='Median' 
			mean='Mean' q3='75th percentile' max='Max' std='Std (sqrt(Var))' 
			cv='CV=100* (Std/Mean)')*f=10.1);
run;
/*
proc freq; tables OBES:; run;
*/
proc tabulate data=work.uam1 format=comma15.0;
title2 "A (cont'd). Statistics known or not own weight";
where imc ne .;
class autopeso_yes imc_class trabajas2 OBESFAM2;
var peso_n autopeso_num imc;
	
tables (imc_class="BMI" trabajas2='I HAVE A JOB (Y/N)' 
		OBESFAM2='FAMILY HISTORY OF OBESITY (Y/N)'
all='Column Totals'), 
			(autopeso_yes='Knows own weight (y/n)' all='Column Totals')*
		(n='N' colpctn='Col %' );
		
run;

ods graphics on;
   
proc reg data=work.uam1;
where autopeso_yes=1;

model peso_n=autopeso_num imc_class;
title2 "B. Modelo measured weight= known weight BMI";
run;
 
ods graphics off;				
ods rtf close;
ods listing;




