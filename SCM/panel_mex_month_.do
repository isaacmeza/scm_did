*Creation of Mexico Panel Dataset - Consumption & Expenditure (per week) 
*at the Household level

forvalues yr=2013/2014 {
	*Load Mexico dataset
	use "$directorio\Raw\compras_`yr'.dta" , clear
	drop id_*
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
		
	*Prices
	destring preco, gen(price) dpcomma

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
	gen sem=week(date(substr(data_compra,1,10),"YMD"))
	gen fecha_sem=yw(ano, sem)
	format fecha_sem %tw
	drop if missing(fecha_sem)

	*Panel Household-Week
	*Sum to obtain the weekly-household level
	collapse (sum) *_gasto *_litros *_kilos, by(fecha_sem iddomicilio)
	foreach var of varlist *_gasto *_litros *_kilos {
		replace `var'=0 if missing(`var')
		}

	*Monthly date
	gen monthly=mofd(dofw(fecha_sem))
	format monthly %tm

	*Panel Household-Month
	*Average consumption per month-household (to smooth the series)
	collapse (mean) *_gasto *_litros *_kilos, by(monthly iddomicilio)

	save "$directorio\_aux\Panel_MEX_month_`yr'.dta", replace
	}

*Dataset creation	
use "$directorio\_aux\Panel_MEX_month_2013.dta", clear	
append using "$directorio\_aux\Panel_MEX_month_2014.dta"
save "$directorio\DB\Panel_MEX_month.dta", replace
