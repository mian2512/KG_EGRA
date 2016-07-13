
clear all
set more off

global data "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Original_data"
global wdata "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Working_data"
global outreg "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Outreg"
global do "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\do"


/*
This is the master do file for 2016 USDA-EGRA 
This do files does the following: 
	1) Calls individual section's do file
	2) Executes the code in each individual do file in #1
	3) Write the final data into the working directory 

*Created by Paul Sirma on 04.13.2016
*************************************
*/


* 1. Russian Grade 4
*********************

do "${do}\RG4_2016"
	
	
*Change two variable to strings before appending 
foreach var of varlist previ1 consent  {

di "****`var'*****"
tab `var' 
tab `var' , nola

cap drop _`var'
decode `var' , gen(_`var')
order _`var' , after(`var')
tab `var' _`var' 
cap drop `var' 
rename _`var' `var' 
}
*

cou //287 observations for Russian Grade 4	
save "${wdata}\KG_2016_allgrades_appended.dta" , replace 
saveold "${wdata}\KG_2016_allgrades_appended.dta" , replace   //saving to stata 13 


* 2. Kyrgz Grade 4
*********************

do "${do}\KG4_2016"

cou  //1,081 observations for Kyrgzy Grade 4 

*Appenind Kyrgz and Russian Grade 4 together 

append using "${wdata}\KG_2016_allgrades_appended.dta"  
save "${wdata}\KG_2016_allgrades_appended.dta" , replace 
saveold "${wdata}\KG_2016_allgrades_appended.dta" , replace   //saving to stata 13 

cou //1368 observations for Grade 4
tab language , m

/*

   language |      Freq.     Percent        Cum.
------------+-----------------------------------
          K |      1,081       79.02       79.02
          R |        287       20.98      100.00
------------+-----------------------------------
      Total |      1,368      100.00


*/



* 3. Russian Grade 2
********************

do "${do}\RG2_2016"
cou  //286 observations 

*Change two variable to strings before appending 
foreach var of varlist consent  {

di "****`var'*****"
tab `var' 
tab `var' , nola

cap drop _`var'
decode `var' , gen(_`var')
order _`var' , after(`var')
tab `var' _`var' 
cap drop `var' 
rename _`var' `var' 
}
*

*Appenind Kyrgz and Russian Grade 4 together 

append using "${wdata}\KG_2016_allgrades_appended.dta"  
save "${wdata}\KG_2016_allgrades_appended.dta" , replace 
saveold "${wdata}\KG_2016_allgrades_appended.dta" , replace   //saving to stata 13 

cou  //1654 observations 
tab language grade , m 
/*

           |         grade
  language |         2          4 |     Total
-----------+----------------------+----------
         K |         0      1,081 |     1,081 
         R |       286        287 |       573 
-----------+----------------------+----------
     Total |       286      1,368 |     1,654 


*/



* 3. Kyrgzy Grade 2
********************

do "${do}\KG2_2016"
cou  //1071 observations 

*Change two variable to strings before appending 
destring ufwst1 , replace
foreach var of varlist  consent {

di "****`var'*****"
tab `var' 
tab `var' , nola

cap drop _`var'
decode `var' , gen(_`var')
order _`var' , after(`var')
tab `var' _`var' 
cap drop `var' 
rename _`var' `var' 
}
*
*Appenind Kyrgz and Russian Grade 4 together 

append using "${wdata}\KG_2016_allgrades_appended.dta"  


cou //2725 observations 
tab language grade , m 
/*


           |         grade
  language |         2          4 |     Total
-----------+----------------------+----------
         K |     1,071      1,081 |     2,152 
         R |       286        287 |       573 
-----------+----------------------+----------
     Total |     1,357      1,368 |     2,725 

	 
*/



*Labelling all the variables 
****************************

lab define ln_ 1 "Incorrect" 0 "Correct" , replace 
forval i=1/69 {

lab var ln`i' "Letter Name"
lab var tln`i' "Time at minute 1 and minute 2 for Letter Name"
lab val ln`i' ln_
}
*
 forval i=1/10 {
 lab var ils`i' "Inital Letter Sound"
 lab var ov`i' "Oral vocab"
}
*
lab def fw_ 1 "Incorrect" 0 "Correct" 	, replace
lab def ufw_ 1 "Incorrect" 0 "Correct" 	, replace
forval i=1/40 {
lab var fw`i' "Familiar words"
lab val fw`i' fw_ 
lab var tfw`i' "Time at minute 1 and minute 2 for Familiar Words"

lab var ufw`i' "Nonesense words" 
lab val ufw`i' ufw_
lab var tufw`i' "Time at minute 1 and minute 2 for Nonesense Words"
}
*

lab def rp_ 1 "Incorrect" 0 "Correct" , replace 
forval i=1/93 {
lab var rp`i'  "Passage Reading"
lab val rp`i' rp_

lab var trp`i' "Time at minute 1 and minute 2 for Passage Reading"
}
*

forval i=1/11 {
lab var dct`i' "Dictation (0-2)" 

}
*
forval i=1/5 {
lab var rpc`i' "Reading Comprehension" 
}
*

forval i=1/4 {
lab var lc`i' "Listening Comprehension"
}
*

*Ordering some variables that are out of order 
order rpc5 , after(rpc4)
order rp42-trp48 rp49-trp80  rp81-trp93 , after(trp41)
order dct9 dct10 dct11, after(dct8)
order ufwti2 ufwti3 ufw_time_used , after(ufwti1)
order fwtim3 , after(fwtim2)


sort rp_permin
br lp_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score

di "********* Score Means by Grade *****************"
tabstat lp_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score , by(grade)   longstub    stat(n mean)
di "********* Grade 2 Score Means by Language *****************"
tabstat lp_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score  if grade==2, by(language)   longstub stat(n mean)
di "********* Grade 4 Score Means by Language *****************"
tabstat lp_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score  if grade==4, by(language)  longstub stat(n mean)





*Cleaning ID {Amy}
******************

/*

/*********************
Create student ID*/


*make right digits= district2, school3, student2

gen str2 District = string(district,"%02.0f")
gen str3 School = string(school,"%03.0f")
gen str2 Student = string(student,"%02.0f")
*br District district School school Student student
tostring region grade, replace

gen StudentID="1"+ region+District+School+grade+section+Student
unique StudentID // 2760 records, 2787 unique
duplicates tag StudentID, gen(dup_ID)
sort StudentID
*br StudentID if dup>0

gen SchoolID="1"+ region+District+School
unique SchoolID // 2787 records, 95 unique
tab SchoolID

merge m:1 SchoolID using "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\KG2016sample.dta"
*/ 







save "${wdata}\KG_2016_allgrades_appended.dta" , replace 
saveold "${wdata}\KG_2016_allgrades_appended.dta" , replace   //saving to stata 13 


