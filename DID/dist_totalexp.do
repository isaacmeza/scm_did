use "$directorio\DB\Panel_HH_week_FINAL_1314.dta", clear

*Define taxable expenditure
gen taxable_exp=sd_gasto+hcf_gasto

*Define nontaxable expenditure
gen nontaxable_exp=nonsd_gasto+nonhcf_gasto

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
collapse  (mean) taxable_exp , by(iddomicilio monthly)	
	
	
*Panel set
xtset iddomicilio monthly

*Smoothing
tssmooth ma taxable_exp=taxable_exp,  window(3 1 2) replace	


*Distribution of taxable exp and non-taxable exp
su taxable_exp, d
xtile perc=taxable_exp, nq(100)
sort perc  taxable_exp
hist taxable_exp if inrange(perc,5,95), percent graphregion(color(white)) lcolor(black) fcolor(none) ///
	scheme(s2mono) xtitle("Pesos") ytitle("Percent") 
graph export "$directorio\Figuras\dist_te.pdf", replace 
graph export "$sharelatex\Figuras\dist_te.pdf", replace 

 
