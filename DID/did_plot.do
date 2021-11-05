args var    /*Variable*/ ///
	left_cut ///
	right_cut ///
	spec ///
	metric
	
	
preserve
*Treatment dummy
qui gen treatment=.
qui replace treatment=1 if taxable_exp>=`right_cut' & !missing(taxable_exp)

*Control dummy
qui replace treatment=0 if taxable_exp<=`left_cut' & !missing(taxable_exp)


*Collapse (Control/Treatment group & time variable) level
collapse (mean) sd_kcal (mean) hcf_kcal (mean) nonsd_kcal (mean) nonhcf_kcal ///
		(mean) tot_cal (mean) tot_cal_placebo, by(treatment monthly)

*Panel set
xtset  treatment monthly


*Graph
twoway (tsline `var' if treatment==1 , tline(2014w1, lwidth(thick) ) lwidth(thick) ///
			lpattern(solid) lcolor(navy)) ///
		(lfit `var' monthly if treatment==1 & monthly<=monthly("2014m1","YM"), ///
			lwidth(medthick) lpattern(dash) ) ///
		(lfit `var' monthly if treatment==1 & monthly>=monthly("2014m1","YM"), ///
			lwidth(medthick) lpattern(dash)) ///
		(tsline `var' if treatment==0 , lwidth(thick) lpattern(solid) lcolor(red) ) ///
		(lfit `var' monthly if treatment==0 & monthly<=monthly("2014m1","YM"), ///
			lwidth(medthick) lpattern(dash) ) ///
		(lfit `var' monthly if treatment==0 & monthly>=monthly("2014m1","YM"), ///
			lwidth(medthick) lpattern(dash)) , ///
		legend(order(1 "Treatment" 4 "Control")) scheme(s2mono) graphregion(color(white)) ///
		xtitle("Date") ytitle("Kcal (thousands)")
			
graph export "$directorio\Figuras\did_`spec'_`metric'_`var'.pdf", replace 
graph export "$sharelatex\Figuras\did_`spec'_`metric'_`var'.pdf", replace 	
restore	
