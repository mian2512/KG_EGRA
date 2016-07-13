


/*KG 2016 EGRA for Russian Grade 4 
*************************************************************************************************************

This do file does the following:
	1) Clean the data
	2) Creates varaibles that will be used in the analysis 


 Created by Paul Sirma  on 07.05.2016
*************************************************************************************************************
*/


*Path to original data, working data, do files, and outreg tables
global data "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Original_data"
global wdata "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Working_data"
global outreg "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Outreg"
global do "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\do"

*Opening the data
use "${data}\KG_2016_K4(Final).dta"  , clear   // Russian Grade 4 



*Cleaning and creating variables 
********************************

*Familiar Word 
**************
br fw1-fwsto1
tab fwsto1 , m //checking stopping variable 
 
	
*Creating an indicator for students who were incorrectly stopped ealy in this section 
cap drop I_stop_err_fw
gen I_stop_err_fw = (fwsto1==1 & (fw1 ==0 | fw2 == 0 | fw3==0 | fw4==0 |fw5==0 |fw6==0 |fw7==0 |fw8==0 |fw9==0|fw10==0) ) 
lab var I_stop_err_fw  "Incorrectly stopped early in Familiar Word Section" 
order I_stop_err_fw , after(fwsto1) 
tab fwsto1 I_stop_err_fw, m

br fw* if fwsto1==1 & I_stop_err_fw==0   //6 students were correctly stopped early 
br fw* if fwsto1==1 & I_stop_err_fw==1   //3 students were incorrectly stopped 


*Creating total_time used variable in seconds 
tab fwtim1 //3 students used 0 seconds, this is a mistake 

*Creating a familiar word score 
cap drop fw_string 
egen fw_string = concat(fw1 fw2 fw3 fw4 fw5 fw6 fw7 fw8 fw9 fw10 fw11 fw12 fw13 fw14 fw15 fw16 fw17 fw18 fw19 fw20 fw21 fw22 fw23 fw24 fw25 fw26 fw27 fw28 fw29 fw30 fw31 fw32 fw33 fw34 fw35 fw36 fw37 fw38 fw39 fw40)
order  fw_string , after(fwtim1) 

cap drop fwt_string
egen fwt_string = concat(tfw1 tfw2 tfw3 tfw4 tfw5 tfw6 tfw7 tfw8 tfw9 tfw10 tfw11 tfw12 tfw13 tfw14 tfw15 tfw16 tfw17 tfw18 tfw19 tfw20 tfw21 tfw22 tfw23 tfw24 tfw25 tfw26 tfw27 tfw28 tfw29 tfw30 tfw31 tfw32 tfw33 tfw34 ///
							tfw35 tfw36 tfw37 tfw38 tfw39 tfw40)
order  fwt_string , after(fw_string) 
br fwt_string fw_string

cap drop fw_correct 
egen fw_correct = noccur(fw_string) , string(0)  //counting the number of correct words student got for familiar word subtask
order fw_correct , after( fwt_string) 
sort fw_correct

*Estimating per minute score, 
*Formula: (Total Correct / Time Used)*60
cap drop fw_permin
gen fw_permin = (fw_correct / fwtim1) *60
lab var fw_permin "Familiar Words"	
order fw_permin , after(fw_correct) 
*Replacing to zero fw score for students who were stopped early 
replace fw_permin = 0 if fwsto1==1 &    I_stop_err_fw==0 

br fw* if fwsto1==1 & I_stop_err_fw==0   //6 students were correctly stopped early 
br fw* if fwsto1==1 & I_stop_err_fw==1   //3 students were incorrectly stopped 

*Creating a nonesense word score 
br ufw1-ufwst1

tab ufwst1
cap drop I_stop_err_ufw 
gen I_stop_err_ufw = (ufwst1 ==1 & (ufw1==0 | ufw2==0| ufw3==0| ufw4==0| ufw5==0| ufw6==0 | ufw7==0 | ufw8 ==0 | ufw9==0 | ufw10==0))
lab var I_stop_err_ufw "Incorrectly stopped early in Nonesense Word Section" 
order I_stop_err_ufw , after(ufwst1)
tab I_stop_err_ufw ufwst1 , m

br ufw*  if ufwst1==1  &  I_stop_err_ufw==0  //15 students  were correctly stopped
br ufw*  if ufwst1==1  &  I_stop_err_ufw==1 //4 students  were incorrectly stopped 
	

*Recoding minutes to seconds
tab  ufwti1


*Creating a nonesence  word score 
cap drop ufw_string 
egen ufw_string = concat(ufw1 ufw2 ufw3 ufw4 ufw5 ufw6 ufw7 ufw8 ufw9 ufw10 ufw11 ufw12 ufw13 ufw14 ufw15 ufw16 ufw17 ufw18 ufw19 ufw20 ufw21 ufw22 ufw23 ufw24 ufw25 ufw26 ufw27 ufw28 ufw29 ufw30 ufw31 ufw32 ufw33 ufw34 ///
							ufw35 ufw36 ufw37 ufw38 ufw39 ufw40)
order  ufw_string , after(ufwti1) 

cap drop ufwt_string
egen ufwt_string = concat(tufw1 tufw2 tufw3 tufw4 tufw5 tufw6 tufw7 tufw8 tufw9 tufw10 tufw11 tufw12 tufw13 tufw14 tufw15 tufw16 tufw17 tufw18 tufw19 tufw20 tufw21 tufw22 tufw23 tufw24 tufw25 tufw26 tufw27 tufw28 tufw29 tufw30 ///
							tufw31 tufw32 tufw33 tufw34 tufw35 tufw36 tufw37 tufw38 tufw39 tufw40)
order  ufwt_string , after(ufw_string) 
br ufwt_string ufw_string

cap drop ufw_correct 
egen ufw_correct = noccur(ufw_string) , string(0)  //counting the number of correct words student got for familiar word subtask
order ufw_correct , after( ufwt_string) 
sort ufw_correct


*Estimating per minute score, 
*Formula: (Total Correct / Time Used)*60
cap drop ufw_permin
gen ufw_permin = (ufw_correct / ufwti1) *60
lab var ufw_permin "Nonsense Words"
order ufw_permin , after(ufw_correct) 
*Replacing to zero ufw score for students who were stopeed early 
replace ufw_permin = 0 if ufwst1==1 &  I_stop_err_ufw==0 

br ufw*  if ufwst1==1  &  I_stop_err_ufw==0  //15 students  were correctly stopped
br ufw*  if ufwst1==1  &  I_stop_err_ufw==1 //4 students  were incorrectly stopped 



*Passage Reading Score
**********************
br rp1-rpsto1 

*Creating total_time used variable in seconds 
tab rptim1  //5 students used 0 seconds which is imposible. these are students who were stopped early 
br rp* if rptim1== 0  

tab rpsto1
*Flag mistakes in early stop rule 
cap drop I_stop_err_rp
gen I_stop_err_rp = (rpsto1==1 & (rp1==0 |rp2== 0 | rp3==0 | rp4==0 | rp5==0 | rp6==0 | rp7 ==0 | rp8 ==0 | rp9==0 |rp10==0))
lab var I_stop_err_rp "Incorrectly stopped early in Passage Reading Section" 
order I_stop_err_rp , after(rpsto1) 
tab  I_stop_err_rp rpsto1


br rp* if rpsto1==1 &  I_stop_err_rp==0  // 6 students who were correctly stopped early
br rp* if rpsto1==1 &  I_stop_err_rp==1  // 7 students who were incorrectly stopped early


*Creating a reading passage score 
cap drop rp_string 
egen rp_string = concat(rp1 rp2 rp3 rp4 rp5 rp6 rp7 rp8 rp9 rp10 rp11 rp12 rp13 rp14 rp15 rp16 rp17 rp18 rp19 rp20 rp21 rp22 rp23 rp24 rp25 rp26 rp27 rp28 rp29 rp30 rp31 rp32 rp33 rp34 rp35 rp36 rp37 rp38 rp39 rp40  ///
							rp41 rp42 rp43 rp44 rp45 rp46 rp47 rp48 rp49 rp50 rp51 rp52 rp53 rp54 rp55 rp56 rp57 rp58 rp59 rp60 rp61 rp62 rp63 rp64 rp65 rp66 rp67 rp68 rp69 rp70 rp71 rp72 rp73 rp74 rp75 rp76 rp77 rp78  ///
							rp79 rp80)
order  rp_string , after(rptim1) 

cap drop rpt_string
egen rpt_string = concat(trp1 trp2 trp3 trp4 trp5 trp6 trp7 trp8 trp9 trp10 trp11 trp12 trp13 trp14 trp15 trp16 trp17 trp18 trp19 trp20 trp21 trp22 trp23 trp24 trp25 trp26 trp27 trp28 trp29 trp30 trp31 trp32 trp33 trp34 ///
							trp35 trp36 trp37 trp38 trp39 trp40 trp41 trp42 trp43 trp44 trp45 trp46 trp47 trp48 trp49 trp50 trp51 trp52 trp53 trp54 trp55 trp56 trp57 trp58 trp59 trp60 trp61 trp62 trp63 trp64 trp65 trp66 trp67 ///
							trp68 trp69 trp70 trp71 trp72 trp73 trp74 trp75 trp76 trp77 trp78 trp79 trp80 )
order  rpt_string , after(rp_string) 
br rpt_string rp_string

cap drop rp_correct 
egen rp_correct = noccur(rp_string) , string(0)  //counting the number of correct words student got for familiar word subtask
order rp_correct , after( rpt_string) 
sort rp_correct

*Estimating per minute score, 
*Formula: (Total Correct / Time Used)*60
cap drop rp_permin
gen rp_permin = (rp_correct / rptim1) *60
lab var rp_permin "Reading Passage"
order rp_permin , after(rp_correct) 
*replacing rp score for students who were incorrectly stopped 
replace rp_permin = 0 if rpsto1==1 & I_stop_err_rp==0


br rp* if rpsto1==1 &  I_stop_err_rp==0  // 6 students who were correctly stopped early
br rp* if rpsto1==1 &  I_stop_err_rp==1  // 7 students who were incorrectly stopped early

 
*Oral Vocab 
br ov1-ov10
des ov1-ov10

lab define _ov 1 "Correct" 0 "Incorrect" , replace
foreach var of varlist  ov1-ov10 { 
	di "***`var'*****"
	replace `var' = upper(`var')
	tab `var' 
	replace `var' = "1" if `var' == "CORRECT" 
	replace `var' = "" if `var' ==" "
	replace `var' = "0"  if `var' == "INCORRECT"
	replace `var' = "0"  if `var' == "NO ANSWER"
	replace `var' = "0"  if `var' == ""
	destring `var' , replace 
	tab `var' 
	lab val `var' _ov
}
*
*Oroal vocal percentage correct 
cap drop total_ov_correct
egen total_ov_correct = rowtotal(ov1-ov10)
la var total_ov_correct "OV Score (0-10)"
order total_ov_correct , after(ov10)
sort total_ov_correct

cap drop ov_score
gen ov_score = (total_ov_correct/10)*100
order ov_score , after(total_ov_correct) 
la var ov_score "Oral Vocabulary"	

*Reading Comprehension 
**********************
des rpc1-rpc5
br rpc1-rpc5


lab define _rpc 1 "Correct" 0 "Incorrect"
foreach var of varlist rpc1-rpc5 {
	di "***`var'*****"
	replace `var' = upper(`var')
	tab `var' 
	replace `var' = "1" if `var' == "CORRECT" 
	replace `var' = "" if `var' ==" "
	replace `var' = "0"  if `var' == "INCORRECT"
	replace `var' = "0"  if `var' == "NO ANSWER"
	replace `var' = "0"  if `var' == ""
	destring `var' , replace 
	tab `var' 
	lab val `var' _rpc
	}
*

*Reading comprehension socre 
cap drop total_rpc_correct
egen total_rpc_correct = rowtotal(rpc1-rpc5)
la var total_rpc_correct "RPC Score (0-5)"
order total_rpc_correct , after(rpc5)
sort total_rpc_correct

cap drop rpc_score
gen rpc_score = (total_rpc_correct/5)*100
order rpc_score , after(total_rpc_correct) 
la var rpc_score "Reading Comprehension"	


*Listening Comprehension 
************************
des lc1-lc4
br lc1-lc4
tab lc1 
tab lc1 , nol
lab def _lc 1 "Correct" 0 "Incorrect"

foreach var of varlist lc1-lc4 {
	di "***`var'*****"
	replace `var' = upper(`var')
	tab `var' 
	replace `var' = "1" if `var' == "CORRECT" 
	replace `var' = "" if `var' ==" "
	replace `var' = "0"  if `var' == "INCORRECT"
	replace `var' = "0"  if `var' == "NO ANSWER"
	replace `var' = "0"  if `var' == ""
	destring `var' , replace 
	tab `var' 
	lab val `var' _lc 
}
*


*Listening comprehension socre 
cap drop total_lc_correct
egen total_lc_correct = rowtotal(lc1-lc4)
la var total_lc_correct "LC Score (0-4)"
order total_lc_correct , after(lc4)
sort total_lc_correct

cap drop lc_score
gen lc_score = (total_lc_correct/4)*100
order lc_score , after(total_lc_correct) 
la var lc_score "Listening Comprehension"	

*Dictation
**********
des dct1-dct10
br dct1-dct10
tab dct1
tab dct1 , nol

	
*Dictation socre 
cap drop total_dct_correct
egen total_dct_correct = rowtotal(dct1-dct10)
la var total_dct_correct "DCT Score (0-20)"
order total_dct_correct , after(dct10)
sort total_dct_correct

cap drop dct_score
gen dct_score = (total_dct_correct/20)*100
order dct_score , after(total_dct_correct) 
la var dct_score "Dictation"	


*Removing Outliers 
******************
des  fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score 

*Flag observations that are 3 Standard Deviation Away 
foreach var of varlist   fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score  {
	cap drop `var'_sd
	cap drop `var'_flag
	di "***`var'****"
	egen `var'_sd = std(`var') 
	order `var'_sd , after(`var') 
	gen `var'_flag =(`var'_sd>= 3)
	order `var'_flag , after(`var'_sd)
	sum `var'_sd, d
	tab `var'_flag
	sum `var'_sd, d 
 }
 *
 cap drop sd_flags
 gen sd_flags=  fw_permin_flag+ ufw_permin_flag+ rp_permin_flag+ ov_score_flag+ rpc_score_flag+ dct_score_flag+ lc_score_flag
 tab sd_flags  //20 outliers
 
*tab Overall_Any_Error // this is the time error flag for a kid who has any time error on any timed subtest
 
 
 *drop if sd_flags!=0 | Overall_Any_Error==1
 drop if sd_flags!=0   //20 outliers are dropped 


 

