********************************************************************************

use "$directorio\DB\Panel_HH_week_FINAL_1314.dta", clear

*Define taxable expenditure
gen taxable_exp=sd_gasto+hcf_gasto

*Total Calories 
gen tot_cal=sd_kcal+hcf_kcal

*Placebo Calories
gen tot_cal_placebo=nonsd_kcal+nonhcf_kcal

*Panel set
xtset  iddomicilio fecha_sem

*Time since treated (in months)
gen monthly=mofd(dofw(fecha_sem))
format monthly %tm

*Daily level
foreach var of varlist tot_cal sd_kcal hcf_kcal ///
				tot_cal_placebo nonsd_kcal nonhcf_kcal {
	replace `var'=`var'/7
	}


*Month level calories consumption and expenditure
collapse (mean) tot_cal  (mean) sd_kcal (mean) hcf_kcal ///
		 (mean) tot_cal_placebo  (mean) nonsd_kcal (mean) nonhcf_kcal ///
		 (mean) taxable_exp , by(iddomicilio monthly)	
	
*Panel set
xtset iddomicilio monthly

*Smoothing
foreach var of varlist tot_cal sd_kcal hcf_kcal ///
				tot_cal_placebo nonsd_kcal nonhcf_kcal taxable_exp {				
	tssmooth ma `var'=`var',  window(3 1 2) replace	
	}


*Month of year
cap drop  mes
gen mes=month(dofm(monthly))
gen year=year(dofm(monthly))

			
				
				
*-------------------------------------------------------------------------------				
				
*DiD Regression	
	
do "$directorio\DoFiles\did_reg.do" ///
	sd_kcal 95 130 2 1
do "$directorio\DoFiles\did_reg.do" ///
	hcf_kcal 70 75 1 1	
	
