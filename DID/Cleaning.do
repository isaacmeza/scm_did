*Import dataset
*import delimited "$directorio\Raw\Panel_HH_week_FINAL_1215_AllBarcodes.csv", clear
use "$directorio\Raw\Panel_HH_week_FINAL_1215_AllBarcodes.dta", clear

*Cleaning
foreach var of varlist iddomicilio fecha_sem sd_gasto - nonhcf_kilos {
	destring `var', replace force
	}
drop if missing(iddomicilio)	
		
*Keep id's which are in both time periods of study
bysort iddomicilio : gen flag1=1 if ///
				inrange(fecha_sem,  weekly("2014w1","YW")-52, weekly("2014w1","YW")-1)
bysort iddomicilio : gen flag2=1 if ///
				inrange(fecha_sem,  weekly("2014w1","YW"), weekly("2014w1","YW")+12)

	
bysort iddomicilio : egen f1=max(flag1)
bysort iddomicilio : egen f2=max(flag2)

egen flag=rowtotal(f1-f2)
keep if flag==2
	
save "$directorio\DB\Panel_HH_week_FINAL_1314.dta", replace
