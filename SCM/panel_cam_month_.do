*Creation of CAM Panel Dataset - Consumption & Expenditure (per week) 
*at the Household level

*Load exchange rate for CAM dataset
use "$directorio\Raw\tc_cam.dta", clear
gen ano=year(date)
collapse tc_*, by(ano)
tempfile temp_tc_prom_anual
foreach var of varlist tc_* {
	rename `var' anual_`var'
	}
save `temp_tc_prom_anual'

*Load CAM dataset
use "$directorio\Raw\CAM.dta" , clear
drop sem ano
gen ano=year(date2)
gen sem=week(date2)
keep if ano==2013 | ano==2014

*Homologation of products (Same between MEX and CAM)
replace  prod = "ACEITES Y ANTIADHERENTES"   if prod=="ACEITE"
replace  prod = "AGUA EMBOTELLADA"   if prod=="AGUA ENVASADA"
replace  prod = "ALIMENTOS INFANTILES"   if prod=="FORMULAS INFANTILES"
replace  prod = "ATUN ENVASADO"   if prod=="ATUN"
replace  prod = "BEBIDAS EN  POLVO"   if prod=="BEBIDAS EN POLVO"
replace  prod = "BEBIDAS GASEOSAS CON SABOR"   if prod=="BEBIDAS GASEOSAS"
replace  prod = "BEBIDAS SABORIZADAS SIN GAS"   if prod=="BEBIDAS REFRESCANTES"
replace  prod = "CAFE"   if prod=="CAFE INSTANTANEO"
replace  prod = "CAFE"   if prod=="CAFE TOSTADO Y MOLIDO"
replace  prod = "CEREALES PARA EL DESAYUNO"   if prod=="CEREALES"
replace  prod = "CREMAS COMESTIBLES"   if prod=="CREMA"
replace  prod = "GALLETAS"   if prod=="GALLETAS"
replace  prod = "JUGOS DE VERDURA"   if prod=="JUGOS NATURALES PREP. CASERA"
replace  prod = "JUGOS DE VERDURA"   if prod=="JUGOS Y NECTARES"
replace  prod = "LECHE CONDENSADA"   if prod=="LECHE CONDENSADA"
replace  prod = "LECHE EN POLVO"   if prod=="LECHE EN POLVO"
replace  prod = "LECHE EVAPORADA"   if prod=="LECHE EVAPORADA"
replace  prod = "LECHE LIQUIDA"   if prod=="LECHE LIQUIDA"
replace  prod = "MARGARINA"   if prod=="MARGARINAS"
replace  prod = "MAYONESA"   if prod=="MAYONESA"
replace  prod = "MODIFICADORES DE LECHE"   if prod=="MODIFICADORES DE LECHE"
replace  prod = "PAN INDUSTRIALIZADO"   if prod=="PAN INDUSTRIALIZADO"
replace  prod = "PASTAS PARA SOPA"   if prod=="PASTAS"
replace  prod = "POSTRE REFRIGERADO"   if prod=="PASTELITOS"
replace  prod = "PURE DE TOMATE"   if prod=="PRODUCTOS DE TOMATE"
replace  prod = "SALSA CATSUP"   if prod=="KETCHUP"
replace  prod = "SALSAS BOTANERAS"   if prod=="SALSAS LIQUIDAS"
replace  prod = "SOPAS"   if prod=="SOPAS"
replace  prod = "TE HELADO"   if prod=="TE LIQUIDO ENVASADO"
replace  prod = "YOGURT"   if prod=="YOGURT"
*Keep intersection of products (Same between MEX and CAM)
keep if prod=="ACEITES Y ANTIADHERENTES"   |    ///
			prod=="AGUA EMBOTELLADA"   |    ///
			prod=="ALIMENTOS INFANTILES"   |    ///
			prod=="ATUN ENVASADO"   |    ///
			prod=="BEBIDAS EN  POLVO"   |    ///
			prod=="BEBIDAS GASEOSAS CON SABOR"   |    ///
			prod=="BEBIDAS SABORIZADAS SIN GAS"   |    ///
			prod=="CAFE"   |    ///
			prod=="CEREALES PARA EL DESAYUNO"   |    ///
			prod=="CREMAS COMESTIBLES"   |    ///
			prod=="GALLETAS"   |    ///
			prod=="JUGOS DE VERDURA"   |    ///
			prod=="LECHE CONDENSADA"   |    ///
			prod=="LECHE EN POLVO"   |    ///
			prod=="LECHE EVAPORADA"   |    ///
			prod=="LECHE LIQUIDA"   |    ///
			prod=="MARGARINA"   |    ///
			prod=="MAYONESA"   |    ///
			prod=="MODIFICADORES DE LECHE"   |    ///
			prod=="PAN INDUSTRIALIZADO"   |    ///
			prod=="PASTAS PARA SOPA"   |    ///
			prod=="POSTRE REFRIGERADO"   |    ///
			prod=="PURE DE TOMATE"   |    ///
			prod=="SALSA CATSUP"   |    ///
			prod=="SALSAS BOTANERAS"   |    ///
			prod=="SOPAS"   |    ///
			prod=="TE HELADO"   |    ///
			prod=="YOGURT"   

merge m:1 prod using "$directorio\Raw\clasificacion_prod.dta", nogen keep(3)
*Keep foods & beverages
keep if alimento==1 | bebida==1

rename date2 date
merge m:1 date using "$directorio\Raw\tc_cam.dta", keep(1 3) nogen
merge m:1 ano using `temp_tc_prom_anual', nogen keep(1 3)

*Imputation missing values for the exchange rate
foreach var of varlist tc_* {
	replace `var'=anual_`var' if missing(`var') & missing(date)
	}
	
*Normalization of prices (to MXN prices)
gen prices=.

forvalues i=1/4 {
	replace prices=preco*tc_0/tc_`i' if pais==`i'
	}
forvalues i=5/6 {
	replace prices=preco*tc_0 if pais==`i'
	}
	

*****
*Imputation of volume, when atypical values ocurr
egen city=group(descrip_ciudad)

#delimit ;

cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"ACEITES Y ANTIADHERENTES"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"ACEITES Y ANTIADHERENTES"
     & inrange(perc,25,95), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"ACEITES Y ANTIADHERENTES"
    & ( missing(vol_unitario) | !inrange(perc,25,95) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"AGUA EMBOTELLADA"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"AGUA EMBOTELLADA"
     & inrange(perc,2,99), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"AGUA EMBOTELLADA"
    & ( missing(vol_unitario) | !inrange(perc,2,99) );
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"ALIMENTOS INFANTILES"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"ALIMENTOS INFANTILES"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"ALIMENTOS INFANTILES"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"ATUN ENVASADO"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"ATUN ENVASADO"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"ATUN ENVASADO"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"BEBIDAS EN  POLVO"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"BEBIDAS EN  POLVO"
    , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"BEBIDAS EN  POLVO"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"BEBIDAS GASEOSAS CON SABOR"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"BEBIDAS GASEOSAS CON SABOR"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"BEBIDAS GASEOSAS CON SABOR"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"BEBIDAS SABORIZADAS SIN GAS"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"BEBIDAS SABORIZADAS SIN GAS"
    , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"BEBIDAS SABORIZADAS SIN GAS"
    & ( missing(vol_unitario) );
	

	
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"CAFE"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"CAFE"
     & inrange(perc,25,100), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"CAFE"
    & ( missing(vol_unitario) );
replace vol_unitario=vol_unitario*1000 
    if  prod == 
"CAFE" & !inrange(perc,25,100);  
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"CEREALES PARA EL DESAYUNO"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"CEREALES PARA EL DESAYUNO"
     & inrange(perc,2,100), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"CEREALES PARA EL DESAYUNO"
    & ( missing(vol_unitario) | !inrange(perc,2,100) );
 
 
 
replace vol_unitario=vol_unitario*1000 
    if  prod == 
"CREMAS COMESTIBLES" & vol_unitario<=1; 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"CREMAS COMESTIBLES"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"CREMAS COMESTIBLES"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"CREMAS COMESTIBLES"
    & ( missing(vol_unitario));
 
 
qui areg vol_unitario price i.ano
    if  prod == 
"GALLETAS"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"GALLETAS"
    & ( missing(vol_unitario) );
 
 
replace vol_unitario=vol_unitario*1000 
    if  prod == 
"JUGOS DE VERDURA" & vol_unitario<=1;  
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"JUGOS DE VERDURA"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"JUGOS DE VERDURA"
    , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"JUGOS DE VERDURA"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"LECHE CONDENSADA"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"LECHE CONDENSADA"
    , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"LECHE CONDENSADA"
    & ( missing(vol_unitario) );
 
 
replace vol_unitario=vol_unitario*1000 
    if  prod == 
"LECHE EN POLVO" & vol_unitario<=1;  
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"LECHE EN POLVO"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"LECHE EN POLVO"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"LECHE EN POLVO"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"LECHE EVAPORADA"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"LECHE EVAPORADA"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"LECHE EVAPORADA"
    & ( missing(vol_unitario) );
 
 
replace vol_unitario=vol_unitario*1000 
    if  prod == 
"LECHE LIQUIDA" & vol_unitario<=1;   
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"LECHE LIQUIDA"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"LECHE LIQUIDA"
     & inrange(perc,25,95), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"LECHE LIQUIDA"
    & ( missing(vol_unitario) | !inrange(perc,25,95) );
 
 
replace vol_unitario=vol_unitario*1000 
    if  prod == 
"MARGARINA" & vol_unitario<=1;   
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"MARGARINA"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"MARGARINA"
     & inrange(perc,25,95), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"MARGARINA"
    & ( missing(vol_unitario) | !inrange(perc,25,95) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"MAYONESA"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"MAYONESA"
     & inrange(perc,2,100), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"MAYONESA"
    & ( missing(vol_unitario) | !inrange(perc,2,100) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"MODIFICADORES DE LECHE"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"MODIFICADORES DE LECHE"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"MODIFICADORES DE LECHE"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"PAN INDUSTRIALIZADO"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"PAN INDUSTRIALIZADO"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"PAN INDUSTRIALIZADO"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"PASTAS PARA SOPA"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"PASTAS PARA SOPA"
     & inrange(perc,2,100), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"PASTAS PARA SOPA"
    & ( missing(vol_unitario) | !inrange(perc,2,100) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"POSTRE REFRIGERADO"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"POSTRE REFRIGERADO"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"POSTRE REFRIGERADO"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"PURE DE TOMATE"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"PURE DE TOMATE"
     & inrange(perc,2,100), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"PURE DE TOMATE"
    & ( missing(vol_unitario) | !inrange(perc,2,100) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"SALSA CATSUP"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"SALSA CATSUP"
     & inrange(perc,2,100), r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"SALSA CATSUP"
    & ( missing(vol_unitario) | !inrange(perc,2,100) );
 
 
replace vol_unitario=vol_unitario*1000 
    if  prod == 
"SALSAS BOTANERAS" & vol_unitario<=1;   
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"SALSAS BOTANERAS"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"SALSAS BOTANERAS"
   , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"SALSAS BOTANERAS"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"SOPAS"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"SOPAS"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"SOPAS"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"TE HELADO"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"TE HELADO"
      , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"TE HELADO"
    & ( missing(vol_unitario) );
 
 
 
cap drop perc;
xtile perc=vol_unitario 
    if  prod == 
"YOGURT"
 , nq(100);
qui areg vol_unitario price i.ano
    if  prod == 
"YOGURT"
     , r absorb(city);
cap drop pr;
predict pr;
replace vol_unitario=pr
    if  prod == 
"YOGURT"
    & ( missing(vol_unitario) );
 

#delimit cr
 
*****

*Expenditure
		*Sugary drinks /non-SD : the former defined as drinks subject to the tax
	gen SDr_gasto=price*quantidade if bebida==1 & impuesto_robusto==1
	gen nonSDr_gasto=price*quantidade if bebida==1 & impuesto_robusto==0
		*High caloric foods / non-HCF : the former defined as foods subject to the tax
	gen HCFr_gasto=price*quantidade if alimento==1 & impuesto_robusto==1
	gen nonHCFr_gasto=price*quantidade if alimento==1 & impuesto_robusto==0


	*Consumption volume
		*Sugary drinks /non-SD 
	gen SDr_litros=vol_unitario/1000 if bebida==1 & impuesto_robusto==1
	gen nonSDr_litros=vol_unitario/1000 if bebida==1 & impuesto_robusto==0
		*High caloric foods / non-HCF
	gen HCFr_kilos=vol_unitario/1000 if alimento==1 & impuesto_robusto==1
	gen nonHCFr_kilos=vol_unitario/1000 if alimento==1 & impuesto_robusto==0
	

*Weekly date
gen fecha_sem=yw(ano, sem)
format fecha_sem %tw
drop if missing(fecha_sem)

*Panel Household-Week
*Sum to obtain the weekly-household level
collapse (sum) *_gasto *_litros *_kilos, by(fecha_sem iddomicilio descrip_ciudad pais)
foreach var of varlist *_gasto *_litros *_kilos {
	replace `var'=0 if missing(`var')
	}

*Monthly date
gen monthly=mofd(dofw(fecha_sem))
format monthly %tm

*Panel Household-Month
*Average consumption per month-household (to smooth the series)
collapse (mean) *_gasto *_litros *_kilos, by(monthly iddomicilio descrip_ciudad pais)

save "$directorio\DB\Panel_CAM_month.dta", replace

