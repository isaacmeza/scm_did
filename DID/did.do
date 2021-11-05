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

*Month level calories consumption and expenditure
collapse (mean) tot_cal (mean) tot_cal_placebo (mean) sd_kcal (mean) hcf_kcal ///
		(mean) nonsd_kcal (mean) nonhcf_kcal (mean) taxable_exp , by(iddomicilio monthly)	
	
	
*Panel set
xtset iddomicilio monthly

*Smoothing
foreach var of varlist  tot_cal tot_cal_placebo ///
							sd_kcal hcf_kcal nonsd_kcal nonhcf_kcal {
	replace `var'=`var'/1000
	tssmooth ma `var'=`var',  window(3 1 2) replace
	}
tssmooth ma taxable_exp=taxable_exp,  window(3 1 2) replace	


do "$directorio\DoFiles\did_plot.do" ///
	tot_cal 100 105 1 1
do "$directorio\DoFiles\did_plot.do" ///
	tot_cal 65 110 1 2
do "$directorio\DoFiles\did_plot.do" ///
	tot_cal 90 90 2 1
do "$directorio\DoFiles\did_plot.do" ///
	tot_cal 60 150 2 2	
	
do "$directorio\DoFiles\did_plot.do" ///
	sd_kcal 105 140 1 1
do "$directorio\DoFiles\did_plot.do" ///
	sd_kcal 110 110 1 2
do "$directorio\DoFiles\did_plot.do" ///
	sd_kcal 90 90 2 1
do "$directorio\DoFiles\did_plot.do" ///
	sd_kcal 60 150 2 2	
	
do "$directorio\DoFiles\did_plot.do" ///
	hcf_kcal 65 65 1 1
do "$directorio\DoFiles\did_plot.do" ///
	hcf_kcal 70 85 1 2
do "$directorio\DoFiles\did_plot.do" ///
	hcf_kcal 90 90 2 1
do "$directorio\DoFiles\did_plot.do" ///
	hcf_kcal 60 150 2 2	

	
	

 
********************************************************************************
********************************************************************************



do "$directorio\DoFiles\did_plot.do" ///
	tot_cal_placebo 100 105 1 1
do "$directorio\DoFiles\did_plot.do" ///
	tot_cal_placebo 65 110 1 2
do "$directorio\DoFiles\did_plot.do" ///
	tot_cal_placebo 90 90 2 1
do "$directorio\DoFiles\did_plot.do" ///
	tot_cal_placebo 60 150 2 2	
	
do "$directorio\DoFiles\did_plot.do" ///
	nonsd_kcal 105 140 1 1
do "$directorio\DoFiles\did_plot.do" ///
	nonsd_kcal 110 110 1 2
do "$directorio\DoFiles\did_plot.do" ///
	nonsd_kcal 90 90 2 1
do "$directorio\DoFiles\did_plot.do" ///
	nonsd_kcal 60 150 2 2	
	
do "$directorio\DoFiles\did_plot.do" ///
	nonhcf_kcal 65 65 1 1
do "$directorio\DoFiles\did_plot.do" ///
	nonhcf_kcal 70 85 1 2
do "$directorio\DoFiles\did_plot.do" ///
	nonhcf_kcal 90 90 2 1
do "$directorio\DoFiles\did_plot.do" ///
	nonhcf_kcal 60 150 2 2	
	
