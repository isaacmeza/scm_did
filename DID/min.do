clear all

********************************************************************************

use "$directorio\DB\Panel_HH_week_FINAL_1314.dta", clear

*Define taxable expenditure
gen taxable_exp=sd_gasto+hcf_gasto

*Total Calories 
gen tot_cal=sd_kcal+hcf_kcal

*Panel set
xtset  iddomicilio fecha_sem

*Time since treated (in months)
gen monthly=mofd(dofw(fecha_sem))
format monthly %tm

*Month level calories consumption and expenditure
collapse (mean) tot_cal  (mean) sd_kcal (mean) hcf_kcal ///
		 (mean) taxable_exp , by(iddomicilio monthly)	
	
*Panel set
xtset iddomicilio monthly

*Smoothing
foreach var of varlist tot_cal sd_kcal hcf_kcal ///
				 taxable_exp {				
	tssmooth ma `var'=`var',  window(3 1 2) replace	
	}

*Treatment dummy variable
gen treatment=.

cap drop  mes
gen mes=month(dofm(monthly))

********************************************************************************
********************************************************************************
********************************************************************************


*Global-local variables
global td = monthly("2014m1","YM")  /*Treatment date*/
local mn = 50						/*Left side of distribution for cut*/
local mx = 150						/*Right side of distribution for cut*/
local step = 5						/*Step size*/ 



********************************************************************************

	 

	 
do "$directorio\DoFiles\opt.do" ///
	 `mn' `mx' `step' tot_cal 1 2

do "$directorio\DoFiles\opt.do" ///
	 `mn' `mx' `step' sd_kcal 1 2
	 
do "$directorio\DoFiles\opt.do" ///
	 `mn' `mx' `step' hcf_kcal 1 2
	 
	 
do "$directorio\DoFiles\opt.do" ///
	 `mn' `mx' `step' tot_cal 2 2

do "$directorio\DoFiles\opt.do" ///
	 `mn' `mx' `step' sd_kcal 2 2
	 
do "$directorio\DoFiles\opt.do" ///
	 `mn' `mx' `step' hcf_kcal 2 2		 
