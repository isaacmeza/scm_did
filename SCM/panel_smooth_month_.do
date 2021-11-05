*Append CAM and Mexico Dataset
*Group Household by clusters according to HH characteristics in order to
*prepare it for SCM in R.


use "$directorio\DB\Panel_CAM_month.dta", clear
*Append Mex data
append using "$directorio\DB\Panel_MEX_month.dta"

replace pais=7 if missing(pais)
label define pais 7 "Mexico", add
label values pais pais
replace descrip_ciudad="MEX" if missing(descrip_ciudad)
encode descrip_ciudad, gen(ciudad)

*Unique panel variable
egen id_domicilio=group(iddomicilio pais)
drop iddomicilio
rename id_domicilio iddomicilio

*Balance
sort iddomicilio monthly
bysort iddomicilio: gen nmes=_N
bysort iddomicilio: gen start=monthly[1]
bysort iddomicilio: gen end=monthly[_N]

*Keep households in pre-treatment and post-treatment date
keep if start<=mofd(date("01/01/2013","DMY")) & end>=mofd(date("01/12/2014","DMY"))
*Panel set
xtset iddomicilio monthly
sort iddomicilio monthly
*Fill between-gaps in data
tsfill, full
foreach var of varlist descrip_ciudad pais ciudad  {
	bysort iddomicilio: replace `var'=`var'[_n-1] if missing(`var')
	bysort iddomicilio: replace `var'=`var'[_n+1] if missing(`var')
	}
	
foreach var of varlist *_gasto *_litros *_kilos {
	bysort iddomicilio: replace `var'=(`var'[_n-1]+`var'[_n+1])/2 if missing(`var')
	bysort iddomicilio: replace `var'=`var'[_n-1] if missing(`var')
	bysort iddomicilio: replace `var'=`var'[_n+1] if missing(`var')
	}
drop if missing(pais)  	

	
*PANEL
xtset iddomicilio monthly
*Numeric coding
decode pais, gen(pais_str) 
egen country=group(pais)
decode ciudad, gen(ciudad_str) 
egen city=group(ciudad)
sort monthly
egen time=group(monthly)
	
	
*Keep relevant variables	
sort monthly
keep pais monthly ciudad iddomicilio pais_str country ciudad_str city time *r_*
*Balance
keep if inrange(monthly, mofd(date("01/01/2013","DMY")),mofd(date("01/12/2014","DMY")))

*Reshape data (so that we can cluster all the time series)
keep *kilos *litros *_gasto iddomicilio monthly pais ciudad
reshape wide *_kilos *_litros *_gasto,  i(iddomicilio) j(monthly)


*Cluster formation (to speed up 'matching' in SCM)
	*Cluster CAM
cluster kmedians SDr_litros* if pais!=7, k(100) s(kr(325617)) name(cl_cam)
	*Cluster MEX
cluster kmedians SDr_litros* if pais==7, k(400) s(kr(385917)) name(cl_mex)
	
*Median HH in cluster
collapse (median) *_kilos* *_litros* *gasto* (max) ciudad , by(cl*)

	*Mexico id - 1:k(#)
sort cl_mex cl_cam
gen treatment=(!missing(cl_mex))
gen id_domicilio=_n
tostring id_domicilio, gen(hh_str)
replace hh_str=hh_str+"_s"

	*Reshape data
reshape long SDr_litros nonSDr_litros HCFr_kilos nonHCFr_kilos SDr_gasto ///
		nonSDr_gasto HCFr_gasto nonHCFr_gasto, i(id_domicilio) j(monthly)
		
egen time=group(monthly)
drop monthly

	*Save csv
export delimited using "$directorio\DB\panel_hh_SDr_litros.csv", replace
	
	
	
