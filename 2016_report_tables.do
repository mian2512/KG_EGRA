
clear all
set more off

global data "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Original_data"
global wdata "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Working_data"
global outreg "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Outreg"
global do "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\do"

use "${wdata}\KG_2016_allgrades_appended.dta" , clear  
unique  SchoolID  //71 School 
tabmiss SchoolID

des gender
cap drop gender_
encode gender , gen(gender_) 
tab gender gender_ , nola
order gender_ ,after(gender) 
recode gender_ (2=0) 
label define sex  0 "Girl" 1 "Boy", replace
label values gender_ sex
tab gender_
tab gender_, nol
rename  gender_ male_student
drop gender
rename treat treatment
rename grade grade_c
rename SchoolID schoolid



tab urbansemiurbanrural, m
replace urbansemiurbanrural = lower(urbansemiurbanrural)
tab urbansemiurbanrural, m

*Creating indicator for urban 
cap drop type 
gen type = (urbansemiurbanrural == "urban" | urbansemiurbanrural == "semiurban") 
*replace type = . if urbansemiurbanrural== "semiurban"
tab urbansemiurbanrural type , m
 


**Tables 10 12 BY GENDER
*defining variables of interest 
local xname "ln_permin ils_score" 
foreach i of numlist 10 12 {
	*forvalues i = 10(2)12 to 16 {   //I am creating table 10 and 12
	gettoken _x xname:xname  // returns the first element in `xname' (ln_permin) and save it as `_x' which defines $output_var,
								//it then returns the second element (ils_score) ...
	global output_var "`_x'"  //defining our outcome variable 
	di "$output_var"  
	lab var ln_permin "Letter Name Recognition"
	lab var ils_score "Initial Letter Sound"
		 

	*Analysis for Kyrgyz Language Grade 2
	*************************************
	preserve
 	keep if language=="K"	& grade_c==2  
	************************************
	
	cap mat drop A
	mat A = J(1,2,.)  //declaring a martix to store the results 
	
	*Total mean score 
	*****************
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	svy: mean $output_var   // Total means score  
	*1.Obtaining mean and Standard deviation 
	qui estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	global p_sd = A[1,2]  //storing std.dev as a global. We will use it to calculate 
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"
	
	*Storing mat A in table1 
	qui frmttable , replace statmat(A)  substat(1) varlabels  store(table1)  /// 
	title("Table `i': `_x' RESULTS BY GENDER ") ctitle ("Subtask" ,"Kyrgyz Language"\"","Total" \"","n=`n'" ) ///
	/*rtitle("`_x'")*/ hlines(10101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") 	
	*****************************************************************************
	
	cap mat drop A  
	mat A = J(1,2,.)	//declaring a martix to store the results 
	*Boys mean score 
	****************
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	qui svy: mean $output_var if male_student==1  // Boys mean score
	*1.Obtaining mean and Standard deviation 
	qui estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"
	
	*Merge mat A with table 1 
	*************************
	qui frmttable , merge(table1) statmat(A)  substat(1) varlabels store(table1)  /// 
	title("Table `i': `_x' RESULTS BY GENDER ") ctitle ("", ""\"","Male" \"","n=`n'") ///
	/*rtitle("`_x'")*/ hlines(10101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") 
	****************************************************************************
	
	cap mat drop A
	mat A = J(1,2,.) //declaring a martix to store the results 	
	*Girls mean score
	*****************	
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	qui svy: mean $output_var if male_student==0  // Girls mean score 
	*1.Obtaining mean and Standard deviation 
	estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"
	qui frmttable , merge(table1) statmat(A)  substat(1) varlabels store(table1)  /// 
	title("Table `i': `_x' RESULTS BY GENDER ") ctitle ("" ,""\"","Fem."\"","n=`n'" ) ///
	/*rtitle("`_x'")*/ hlines(10101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") 	
	*******************************************************************************
 
	*Mean diffrence between Boys and Girls 
	**************************************
	svy: regress $output_var  male_student
	qui ereturn list
	
	cap mat drop c 
	mat c = e(b)'  //storing the b0 and b1 coeffients 
	cap mat drop c_mean
	mat c_mean = abs(c[1,1])  //storing the b1
	global dif =  abs(c[1,1])  //storing the absolute values of b1. We will use this value to calculate Cohens'D.
	global mean_dif = c[1,1] //storing b1 as a global. We will use this value to calculate t-stat
	di "$mean_dif"
	
	*Merge mat c_mean wiht table 1 
	frmttable , merge(table1) statmat(c_mean) ctitle (""\"Diff." \ "" ) varlabels  store(table1) ///
	
	qui return list
	cap mat drop d
	mat d =  r(table)' //storing the result of our regression in mat d 
	*mat list d
	global se_diff = d[1,2] //storing the Standard errors of b1. We will use this value when calculating the t-stat
	di "$se_diff"
	mat d = d[1,2]  
	*mat list d
	cap mat drop d_f 
	mat d_f =  r(table)'
	mat list d_f
	global d_f = d_f[1,7]  //storing degrees of freedom 
	di "$d_f"

	*Assigning Stars 
	cap mat drop stars
	matrix stars = J(1,4,0)  //declaring a matrix to store the pvalues. I want to store the "**" in the fourth column of table1. 
	*Calculating the t-stat 
	matrix stars[1,4] =  ///
	(abs($mean_dif /$se_diff) > invttail($d_f,0.05/2)) + ///
	(abs($mean_dif /$se_diff) > invttail($d_f,0.01/2))
	mat list stars 		
	
	*Use mat stars to add annotations and asymbol 
	frmttable , replace replay(table1) store(table1) ///
	annotate(stars) asymbol(*,**) varlabels
				
	*Calculting effect size,cohens'd column 
	***************************************
	*formula = mean diff btn boys and girls/ pooled Std.dev
	cap drop effect_size
	global  effect_size = abs($dif /$p_sd) 
	cap mat drop cohens_d
	mat cohens_d = J(1,1,.)
	mat cohens_d[1,1] = $effect_size  //storing effect size in a matrix 

	*Merging effect size  with table 1 
	frmttable  , merge(table1) statmat(cohens_d) ctitle (""\"Cohens' D" \ "" ) varlabels  store(table1) 
	***************************************************************************************************
	***************************************************************************************************
		
	restore , preserve  //restoring the data and preserve it be fore starting doing the analysis for Russian language 
	*************************************************************************
	*Note: The steps are similar to the ones I used above for Kryzy Grade 2
	************************************************************************
	
	*Analysis for Russian Language, Grade 2 
	***************************************
	keep if language=="R" & grade_c==2
	***************************************
	
	cap mat drop A
	mat A = J(1,2,.)  // declaring a matrix to store the results 
	*Total mean score 
	*****************
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	qui svy: mean $output_var   // Total means 
	*1.Obtaining mean and Standard deviation 
	qui estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	global p_sd = A[1,2]  //storing std.dev as a global. We will use it to calculate 
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui  estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"

	qui frmttable  , merge(table1) statmat(A)  substat(1) varlabels  store(table1)  /// 
	title("Table `i': `_x' RESULTS BY GENDER ") /*ctitle ("", "" , "", "" \"", "Total" \ "" , "n = `n' " )*/  ctitle ("" ,"Russian Language"\"", "Total" \ "" , "n = `n' " )  ///
	/*rtitle("`_x'")*/ hlines(10101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") 	
	**************************************************************************

	cap mat drop A
	mat A = J(1,2,.)
	*Boys mean score 
	****************	
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	qui  svy: mean $output_var if male_student==1  // Male means 
	*1.Obtaining mean and Standard deviation 
	qui estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"

	qui frmttable  , merge(table1) statmat(A)  substat(1) varlabels store(table1)  /// 
	title("Table `i': `_x' RESULTS BY GENDER ") /*ctitle ("", "", ""\"", "Male" \ "" , "n = `n' " )*/  ctitle ("", ""\"", "Male" \ "" , "n = `n' " )  ///
	/*rtitle("`_x'")*/ hlines(10101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") 
	****************************************************************************

	cap mat drop A
	mat A = J(1,2,.)
	*Girls mean score 
	****************			
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	qui  svy: mean $output_var if male_student==0  // Girls means 
	*1.Obtaining mean and Standard deviation 
	qui estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"

	qui frmttable , merge(table1) statmat(A)  substat(1) varlabels store(table1)  /// 
	title("Table `i': `_x' RESULTS BY GENDER ") /*ctitle ("", "", ""\"", "Fem." \ "" , "n = `n' " )*/  ctitle ("" , ""\"", "Fem." \ "" , "n = `n' " )   vlines(000010000)   ///
	/*rtitle("`_x'")*/  hlines(110101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") 	
	*************************************************************************

	*Mean diffrence between Boys and Girls 
	**************************************	
	svy: regress $output_var  male_student

	qui ereturn list
	cap mat drop c 
	mat c = e(b)'
	cap mat drop c_mean
	mat c_mean = abs(c[1,1])
	global dif =  abs(c[1,1])  //storing the absolute values of mean difference as a global for calculating cohens'd later on
	global mean_dif = c[1,1]
	* mat list c_mean
	global mean_dif = c[1,1]
	di "$mean_dif"

	frmttable  , merge(table1) statmat(c_mean) ctitle (""\"Diff." \ "" )    store(table1) ///
	
	qui return list
	cap mat drop d
	mat d =  r(table)' 
	*mat list d
	global se_diff = d[1,2]
	di "$se_diff"
	mat d = d[1,2]
	*mat list d
	cap mat drop d_f
	mat d_f =  r(table)'
	mat list d_f
	global d_f = d_f[1,7]
	di "$d_f"

	*Assigning Stars 
	cap mat drop stars
	matrix stars = J(1,9,0)
	matrix stars[1,9] =  ///
	(abs($mean_dif /$se_diff) > invttail($d_f,0.05/2)) + ///
	(abs($mean_dif /$se_diff) > invttail($d_f,0.01/2))
	
	*Use mat stars to add annotations and asymbol 
	frmttable , replace replay(table1) store(table1) ///
	annotate(stars) asymbol(*,**) varlabels	
	
	*Calculting effect size,cohens'd column 
	***************************************
	cap drop effect_size
	global  effect_size = abs($dif /$p_sd) //formula = mean_diff/pooled_sd
	cap mat drop cohens_d
	mat cohens_d = J(1,1,.)
	mat cohens_d[1,1] = $effect_size  //storing effect size in a matrix 

	*Merging effect size mat with table 1
	frmttable  , merge(table1) statmat(cohens_d) ctitle (""\"Cohens' D" \ "" ) varlabels  store(table1) //merging effect size to table1 


	frmttable , replace replay(table1) store(table1) ///
	annotate(stars) asymbol(*,**) varlabels  hlines(110101) vlines(010000100)  colwidth(10 5 5 5 5) noblankrows   multicol(1,2,5;1,7,5) ///
	coljust(l{c})  basefont(fs10) statfont(fs10)  landscape
	
	*Writting the tables to word
	****************************

	if `i' ==10 {
		frmttable using "$outreg/2016_table" , replace replay(table1) store(table1) ///
		annotate(stars) asymbol(*,**) varlabels  hlines(110101) vlines(010000100)   colwidth(10 5 5 5 5) noblankrows   multicol(1,2,5;1,7,5) ///
		coljust(l{c})  basefont(fs10) statfont(fs10)  landscape
		}
		
	else  {
		frmttable using "$outreg/2016_table" , addtable replay(table1) store(table1) ///
		annotate(stars) asymbol(*,**) varlabels  hlines(110101)  vlines(010000100)   colwidth(10 5 5 5 5) noblankrows   multicol(1,2,5;1,7,5) ///
		coljust(l{c})  basefont(fs10) statfont(fs10)  landscape
		}

	restore  // restoring the data at the end of the loop 
	}
**********************************$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$**************************$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$***************************
**********************************$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$**************************$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$***************************
	



*****Tables 11 13 by DEMOGRAPHICS
local xname "ln_permin ils_score" 
*local lang "Kyrgyz  Russian"
foreach i of numlist 11 13 {

	gettoken _x xname:xname  // returns the first element in `xname' (ln_permin) and save it as `_x' which defines $output_var,
							//it then returns the second element (ils_score) ...
							//it then returns the second element (ils_score) ...
	global output_var "`_x'"  //defining our outcome variable 
	di "$output_var"  
	lab var ln_permin "Letter Name Recognition"
	lab var ils_score "Initial Letter Sound"


	*Analysis for Kyrgyz Language Grade 2
	*************************************
	preserve
	keep if language=="K"	 & grade_c==2
	*************************************
 

	cap mat drop b
	mat b = J(1,1,.)
	*Total Mean Score 
	*****************
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	svy: mean $output_var   // Total means 
	*1.Obtaining mean and Standard deviation 
	estat  sd
	return list
	*Storing mean and std.deviation in a matrix
	mat b[1,1] = r(sd) //storing mean's of each var in column 1
	global p_sd = b[1,1]  //storing pooled sd for calculating effect size later on 
	di "$p_sd"
 
	cap mat drop A
	mat A = J(1,2,.)
	*Urban Mean Score
	*****************
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	svy: mean $output_var  if type ==1 // Urban means 
	*1.Obtaining mean and Standard deviation 
	qui estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	global p_sd = A[1,2]  //storing std.dev as a global. We will use it to calculate 
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"

	qui frmttable , replace statmat(A)  substat(1) varlabels  store(table1)  /// 
	title("Table `i': `_x' RESULTS BY SCHOOL LOCATION") ctitle ("Subtask" ,"Kyrgyz Language"\"","Urban" \"","n=`n'" ) ///
	/*rtitle("`_x'")*/ hlines(10101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") 	landscape 
	*****************************************************************************

	cap mat drop A
	mat A = J(1,2,.)		
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	qui svy: mean $output_var if type==0  // Rural means 
	*1.Obtaining mean and Standard deviation 
	estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"

	qui frmttable , merge(table1) statmat(A)  substat(1) varlabels store(table1)  /// 
	title("Table `i': `_x' RESULTS BY SCHOOL LOCATION") ctitle ("" ,""\"","Rural"\"","n=`n'" ) ///
	/*rtitle("`_x'")*/ hlines(10101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") 	landscape
 
	*Mean diffrence between Urban and Rural 
	**************************************	
	svy: regress $output_var  type
	qui ereturn list
	cap mat drop c 
	mat c = e(b)'
	cap mat drop c_mean
	mat c_mean = abs(c[1,1])
	global dif =  abs(c[1,1])  //storing the absolute values of b1. We will use this value to calculate Cohens'D.
	global mean_dif = c[1,1]
	di "$mean_dif"
	frmttable  , merge(table1) statmat(c_mean) ctitle (""\"Diff." \ "" ) varlabels  store(table1) landscape
	*******************
	qui return list
	cap mat drop d
	mat d =  r(table)' 
	global se_diff = d[1,2]
	di "$se_diff"
	*mat list d
	cap mat drop d_f
	mat d_f =  r(table)'
	mat list d_f
	global d_f = d_f[1,7]
	di "$d_f"

	*Assigning Stars 
	cap mat drop stars
	matrix stars = J(1,3,0)
	matrix stars[1,3] =  ///
	(abs($mean_dif /$se_diff) > invttail($d_f,0.05/2)) + ///
	(abs($mean_dif /$se_diff) > invttail($d_f,0.01/2))

	frmttable   ,  replay(table1) store(table1) ///
	annotate(stars) asymbol(*,**) varlabels

 	*Calculting effect size,cohens'd column 
	***************************************
	cap drop effect_size
	global  effect_size = abs($dif /$p_sd) //formula = mean_diff/pooled_sd
	cap mat drop cohens_d
	mat cohens_d = J(1,1,.)
	mat cohens_d[1,1] = $effect_size  //storing effect size in a matrix 

	*Merging effect size mat with table 1
	frmttable  , merge(table1) statmat(cohens_d) ctitle (""\"Cohens' D" \ "" ) varlabels  store(table1) //merging effect size to table1 
	****************************************************


	*Analysis for Russian Language Grade 2
	*************************************
	restore , preserve
	keep if language=="R" & grade_c==2
	**********************************

	cap mat drop b
	mat b = J(1,1,.)
	*Total Mean Score
	*****************
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	svy: mean $output_var   // Total means 
	*1.Obtaining mean and Standard deviation 
	estat  sd
	return list
	*Storing mean and std.deviation in a matrix
	mat b[1,1] = r(sd) //storing mean's of each var in column 1
	global p_sd =b[1,1]  //storing pooled sd for calculating effect size later on 
	di "$p_sd"

	cap mat drop A
	mat A = J(1,2,.)
	*Urban Mean Score
	*****************
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	qui svy: mean $output_var if type==1  // Urban means 
	*1.Obtaining mean and Standard deviation 
	qui estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	global p_sd = A[1,2]  //storing std.dev as a global. We will use it to calculate 
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui  estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"

	qui frmttable , merge(table1) statmat(A)  substat(1) varlabels  store(table1)  /// 
	title("Table `i': `_x' RESULTS BY SCHOOL LOCATION") /*ctitle ("", "" , "", "" \"", "Total" \ "" , "n = `n' " )*/  ctitle ("","Russian Language"\"", "Urban" \ "" , "n=`n'" )  ///
	/*rtitle("`_x'")*/ hlines(10101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") landscape
	*******************************************************************************

	cap mat drop A
	mat A = J(1,2,.)
	*Rural Mean Score
	*****************
	svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
	qui  svy: mean $output_var if type==0  // Rural means 
	*1.Obtaining mean and Standard deviation 
	qui estat  sd
	qui return list
	*Storing mean and std.deviation in a matrix
	mat A[1,1] = r(mean) //storing mean's of each var in column 1
	mat A[1,2] = r(sd)  //storing Std.deviation of each var in column 2
	mat rownames A = $output_var  //defining rownames as output variables  
	*2.Obtaining N= number of observations 
	qui estat size 
	qui ereturn list
	local n = e(N)
	di "`n'"

	qui frmttable , merge(table1) statmat(A)  substat(1) varlabels store(table1)  /// 
	title("Table `i': `_x' RESULTS BY SCHOOL LOCATION") /*ctitle ("", "", ""\"", "Fem." \ "" , "n = `n' " )*/  ctitle ("" ,""\"","Rural" \"","n =`n'" )   vlines(000010000)   ///
	/*rtitle("`_x'")*/  hlines(110101) colwidth(10 7) coljust(l{c})  basefont(fs11) statfont(fs11) ///
	notefont(fs9) note("* Significant at .05 level, ** Significant at .01 level") 	landscape
	******************************************************************************

	**** Calculating mean difference 	
	svy: regress $output_var  type
	qui ereturn list
	cap mat drop c 
	mat c = e(b)'
	cap mat drop c_mean
	mat c_mean = abs(c[1,1])
	global dif =  abs(c[1,1])  //storing the absolute values of b1. We will use this value to calculate Cohens'D.
	global mean_dif = c[1,1]
	di "$mean_dif"
	
	frmttable , merge(table1) statmat(c_mean) ctitle (""\"Diff." \ "" )    store(table1)
	***************
	qui return list
	cap mat drop d
	mat d =  r(table)' 
	*mat list d
	global se_diff = d[1,2]
	di "$se_diff"
	mat d = d[1,2]
	*mat list d
	cap mat drop d_f
	mat d_f =  r(table)'
	mat list d_f
	global d_f = d_f[1,7]
	di "$d_f"
				
	*Assigning Stars 
	cap mat drop stars
	matrix stars = J(1,3,0)
	matrix stars[1,3] =  ///
	(abs($mean_dif /$se_diff) > invttail($d_f,0.05/2)) + ///
	(abs($mean_dif /$se_diff) > invttail($d_f,0.01/2))
	mat list stars 		
	
	*Use mat stars to add annotations and asymbol 
	frmttable , replace replay(table1) store(table1) ///
	annotate(stars) asymbol(*,**) varlabels	
	
	
	*Calculting effect size,cohens'd column 
	***************************************
	cap drop effect_size
	global  effect_size = abs($dif /$p_sd) //formula = mean_diff/pooled_sd
	cap mat drop cohens_d
	mat cohens_d = J(1,1,.)
	mat cohens_d[1,1] = $effect_size  //storing effect size in a matrix 
	*Merging effect size mat with table 1
	frmttable  , merge(table1) statmat(cohens_d) ctitle (""\"Cohens' D" \ "" ) varlabels  store(table1) //merging effect size to table1 
	****************************************************

	
	frmttable using "$outreg/2016_table" , addtable replay(table1) store(table1) ///
	/*annotate(stars) asymbol(*,**)*/ varlabels  hlines(1110{0}1)    vlines(01000100)  colwidth(10 5 5 5 5) noblankrows    multicol(1,2,4;1,6,4) ///
	ctitle ("", " Kyrgyz Language","","","", "Russian Language", "","", ""\  ///
		 "", "Urban", "Rural", "Diff.", "Cohens' d" , "Urban" , "Rural" , "Diff." , "Cohens' d" ) ///
	coljust(l{c})  basefont(fs10) statfont(fs10)  landscape
		
	
	restore

 }
**********************************$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$**************************$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$***************************								
**********************************$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$**************************$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$***************************






preserve 
keep if language=="K"	 & grade_c==2

svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
 svy: mean ils_score   
qui svy: mean ils_score  if type ==1 
qui svy: mean ils_score  if type ==0 
svy :reg   ils_score type

restore 

preserve 
keep if language=="R"	 & grade_c==2

svyset  [pweight=wt_final],  psu(schoolid)  strata(treatment)
qui svy: mean ils_score   
estat sd
qui svy: mean ils_score  if type ==1 
qui svy: mean ils_score  if type ==0 
svy : reg   ils_score type

restore 
