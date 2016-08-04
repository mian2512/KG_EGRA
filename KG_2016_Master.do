
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

*Created by Paul Sirma on 07.06.2016
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

cou //297 observations for Russian Grade 4	
save "${wdata}\KG_2016_allgrades_appended.dta" , replace 
saveold "${wdata}\KG_2016_allgrades_appended.dta" , replace   //saving to stata 13 


* 2. Kyrgz Grade 4
*********************

do "${do}\KG4_2016"

cou  //1,101 observations for Kyrgzy Grade 4 

*Appenind Kyrgz and Russian Grade 4 together 

append using "${wdata}\KG_2016_allgrades_appended.dta"  
save "${wdata}\KG_2016_allgrades_appended.dta" , replace 
saveold "${wdata}\KG_2016_allgrades_appended.dta" , replace   //saving to stata 13 

cou //1398 observations for Grade 4
tab language , m

/*

   language |      Freq.     Percent        Cum.
------------+-----------------------------------
          K |      1,101       78.76       78.76
          R |        297       21.24      100.00
------------+-----------------------------------
      Total |      1,398      100.00



*/



* 3. Russian Grade 2
********************

do "${do}\RG2_2016"
cou  //300 observations 

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

cou  //1698 observations 
tab language grade , m 
/*

           |         grade
  language |         2          4 |     Total
-----------+----------------------+----------
         K |         0      1,101 |     1,101 
         R |       300        297 |       597 
-----------+----------------------+----------
     Total |       300      1,398 |     1,698 


*/



* 3. Kyrgzy Grade 2
********************

do "${do}\KG2_2016"
cou  //1089 observations 

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


cou //2787 observations 
tab language grade , m 
/*


           |         grade
  language |         2          4 |     Total
-----------+----------------------+----------
         K |     1,089      1,101 |     2,190 
         R |       300        297 |       597 
-----------+----------------------+----------
     Total |     1,389      1,398 |     2,787 

	 
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

lab var ufw`i' "Nonsense words" 
lab val ufw`i' ufw_
lab var tufw`i' "Time at minute 1 and minute 2 for Nonsense Words"
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

*Labeling questionnaire section 
********************************
label variable q1 "In what language do you study at school?"
label variable q2 "What language do you speak at home the majority of the time?"
label variable q3 "Do you have a school language/reading textbook for your grade?"
label variable q6 "How many books do you have in your hosue?"

label variable q7 "Of the books you have at home, are any of them children's books that are yours?"
label variable q8 "Do your parents or other(s) in the family read?"
label variable q9 "Do your paretns or others in the family read with you?"
label variable q10 "Do you ever read books that are not textbooks at home by yourself?"
label variable q11 "Does your family own a radio?"
label variable q12 "Does your family own a home telephone?"
label variable q13 "Does your family own a Mobile phone?"
label variable q14 "Does your family own a television?"
label variable q15 "Does your family own a refrigerator?"
label variable q16 "Does your family own a bicyle?"
label variable q17 "Does your family own a motorcycle?"
label variable q18 "Does your family own a computer?"
label variable q19 "Does your family own a computer with internet connection?"
label variable q20 "Does your family own an automobile?"
label variable q21 "Does your family own a tractor?"
label variable q22 "Does your family own a truck?"
label variable q23 "How many people live in your household?"
label variable q24 "How many many brothers and sister do you have who live with you?"
label variable q25 "How many rooms are used exclusively for sleeping?"
label variable q26 "Do you get reading homework?"
label variable q27 "If yes, How often do you get reading homework?"
label variable q28 "Does anyone in your family help you with your homework?"
//label variable q29 "If yes, who helps you?"
label variable q30 "Did your teacher check your reading skills (including letter knowledge) in the past month?"
//label variable q31 "Before you were enrolled in grade 1, did you attend...?"
label variable q32 "Which grade did you attend during the last academic year?"
label variable q33 "Have you been to a reading activity that was outside of your regular classes, or even otuside of school?"
rename q41-q46 , upper 
rename Q41 Q4a
rename Q42 Q4b
rename Q43 Q4c
rename Q44 Q4d
rename Q45 Q4e
rename Q46 Q4f
label variable Q4a "Besides school textbooks, do you have any newspapers in your house?"
label define yes_no 1"yes" 0"no"
label val Q4a yes_no
label variable Q4b "Besides school textbooks, do you have any magazines in your house?"
label val Q4b yes_no
label variable Q4c "Besides school textbooks, do you have any religious books in your house?"
label val Q4c yes_no
label variable Q4d "Besides school textbooks, do you have any books in your house?"
label val Q4d yes_no
label variable Q4e "Besides school textbooks, do you have any other reading materials in your house?"
label val Q4e yes_no
label variable Q4f "Besides school textbooks, do you have no other reading materials in your house?"
label val Q4f yes_no
rename Q4a-Q4f , lower 
rename  q311-q316 , upper 
rename Q311 Q31a
label variable Q31a "Before you were enrolled in grade 1, did you attend kindergarten?"
label drop yes_no
label define yes_no 1"yes" 0"no"
label val Q31a yes_no
rename Q312 Q31b
label variable Q31b "Before you were enrolled in grade 1, did you attend preschool?"
label val Q31b yes_no
rename Q313 Q31c
label variable Q31c "Before you were enrolled in grade 1, did you attend religious school?"
label val Q31c yes_no
rename Q314 Q31d
label variable Q31d "Before you were enrolled in grade 1, did you attend other school?"
label val Q31d yes_no
rename Q315 Q31e
label variable Q31e "Before you were enrolled in grade 1, did you NOT attend school?"
label val Q31e yes_no
rename Q316 Q31f
label variable Q31f "Before you were enrolled in grade 1, did you attend no response/don't know?"
label val Q31f yes_no
rename Q31a Q31b Q31c Q31d Q31e Q31f , lower 

*Fixing remark split error for q5
*NOTE: Q51 and q52 should all be q5 
replace q5 = q51 if q5==. & q51 != . 
replace q5 = q52 if q5==. & q52 != . 
*For students who gave two answears, I am creating q5_other which combines the two responses by a ; 
decode  q51  , gen(_q51) 
tab _q51
decode q52 , gen(_q52) 
cap drop  q5_other
egen q5_other = concat(_q51 _q52) if _q52 != "" &  _q51 != ""   ,  p(",") 
gsort - q5_other
br q51 q52 q5_other 
drop q51 _q51 q52 _q52 
br q5 q5_other
label variable q5 "If the answer is yes, in what language are the majority of the reading materials?"
label variable q5_other "If the answer is yes, in what language are the majority of the reading materials?"
order q5 q5_other, after(q4f)

rename q291-q295 , upper 
rename Q291 Q29_Mother
label var Q29_Mother "Mother helps with homework [for respondents with more than one response]"
rename Q292 Q29_Father
label var Q29_Father "Father helps with homework [for respondents with more than one response]"
rename Q293 Q29_Sibling
label var Q29_Sibling "Brother or sister helps with homework [for respondents with more than one response]"
rename Q294 Q29_Other
label var Q29_Other "Other helps with homework [for respondents with more than one response]"
rename Q295 Q29_DK_No_rep
label var Q29_DK_No_rep "Don't know/ no response helps with homework [for respondents with more than one response]"
rename Q29_Mother  Q29_Father Q29_Sibling Q29_Other Q29_DK_No_rep , lower 


*Ordering some variables that are out of order 
order rpc5 , after(rpc4)
order rp42-trp48 rp49-trp80  rp81-trp93 , after(trp41)
order dct9 dct10 dct11, after(dct8)
order ufwti2 ufwti3 ufw_time_used , after(ufwti1)
order fwtim3 , after(fwtim2)
order q23 , after(q22) 
order q27 , after(q26) 
order q33 , after(q32) 

sort rp_permin
br ln_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score

di "********* Score Means by Grade *****************"
tabstat ln_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score , by(grade)   longstub    stat(n mean)
di "********* Grade 2 Score Means by Language *****************"
tabstat ln_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score  if grade==2, by(language)   longstub stat(n mean)
di "********* Grade 4 Score Means by Language *****************"
tabstat ln_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score  if grade==4, by(language)  longstub stat(n mean)



*Cleaning ID and Create student ID by Amy T
*******************************************
*make right digits= district2, school3, student2
gen str2 District = string(district,"%02.0f")
gen str3 School = string(school,"%03.0f")
gen str2 Student = string(student,"%02.0f")
*br District district School school Student student
tostring region grade, replace

gen StudentID="1"+ region+District+School+grade+section+Student
unique StudentID // 2787 records, 2787 unique
cap drop dup_ID
duplicates tag StudentID, gen(dup_ID)
sort StudentID
br StudentID if dup_ID>0

cap drop SchoolID
gen SchoolID="1"+ region+District+School
unique SchoolID // 2787 records, 71 unique

merge m:1 SchoolID using "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\KG2016sample.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             2,787  (_merge==3)
    -----------------------------------------

*/
destring grade , replace
tab SchoolID _m
tab egra2016 , m
rename egra2016 treat 
tab treat 

*Adding weights by Amy T
************************
*first, adjusted school weight 
*4.285714286 russ control; 11.72413793 kg control; 15.14285714 russ treat; 41.78571429 kg treat
gen wt1=4.285714286 if treat==0 & language =="R"
replace wt1=11.72413793 if treat==0 & language =="K"
replace wt1=15.14285714 if treat==1 & language =="R"
replace wt1=41.78571429 if treat==1 & language =="K"
label var wt1 "Adjusted school weight for treatment assignment and language"

//calculate count separately by language

*keep if language==3  // what are we doing here? 

*second, student-level
*create student-level
bys SchoolID grade treat: gen count=_N 

*pop-level student numbers 
gen per_grade=totalprimarygradestudents2016/4 // this is the average number of students per grade in the sampled schools
gen wt2=per_grade
label var wt2 "pop-level number of students per grade"

*final weight

gen wt_final= (wt1*wt2)/count
label var wt_final "Final student-weight"
br SchoolID grade language treat wt_final



drop stoptime stopt1 stopt2 stopt3 stopt4 timeerror rptim1 rptim2 lntim1 fwtim1 start1 admin1 admin2 admin3 ufwti3 ufwti2 ufwti1


*Saving cleaned data
********************
save "${wdata}\KG_2016_allgrades_appended.dta" , replace 
saveold "${wdata}\KG_2016_allgrades_appended.dta" , replace   //saving to stata 13 

