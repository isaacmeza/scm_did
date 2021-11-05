
args min_                  /*Left side of distribution for cut*/   ///
	 max_				   /*Right side of distribution for cut*/  ///
	 ss 			       /*Step size*/                           ///
	 var				   /*Dependent variable*/ 				   ///
	 spec				   /*Specification of DiD*/				   ///
	 met                   /*Metric*/


preserve	 
timer clear
timer on 1
local sizem = round((`max_'-`min_')/(`ss'))+1
matrix metric=J(`sizem',`sizem',0)

local q=1
local j=1
local numop=round((`sizem')*(`sizem'+1)/2)

*Loop that looks optimal right cut	
forvalues right_cut_s=`max_'(`=-`ss'')`min_' {

	local i=1
	*Loop that looks optimal left cut
	forvalues left_cut_s=`min_'(`ss')`right_cut_s' {
		
		*Counter
		local counter=round((`q'/`numop')*100)
		
		di `counter'
		local ++q
		
		*Treatment dummy
		qui replace treatment=.
		qui replace treatment=1 if taxable_exp>=`right_cut_s' & !missing(taxable_exp)

		*Control dummy
		qui replace treatment=0 if taxable_exp<=`left_cut_s' & !missing(taxable_exp)

		*# Obs in Treatment group
		qui su treatment, mean
		local obs=`r(mean)'
		
		*Dummies
		qui xi i.treatment*i.monthly, noomit			
			
		*DiD Regression
		if `spec'==1 {
			qui xtreg `var'  1.treatment ///
			_Imonthly_636-_Imonthly_647 ///
			_Imonthly_649-_Imonthly_659 ///
			_ItreXmon_1_636-_ItreXmon_1_647  ///
			_ItreXmon_1_649-_ItreXmon_1_659  ///
				, fe cluster(iddomicilio)
			}
		else {
			qui xtreg `var'  1.treatment ///
			_Imonthly_636-_Imonthly_647 ///
			_Imonthly_649-_Imonthly_659 ///
			_ItreXmon_1_636-_ItreXmon_1_647  ///
			_ItreXmon_1_649-_ItreXmon_1_659  ///
			i.mes#1.treatment i.mes	, fe cluster(iddomicilio)
			}
			
		*Metric looks to minimize coefficient that "tests" for parallel trends
		forvalues k=`=${td}-12'/`=${td}-1' {
			if `met'==1 {
				local coef=abs(_b[_ItreXmon_1_`k'])
				}
			else {
				local coef=abs(_b[_ItreXmon_1_`k']/(_se[_ItreXmon_1_`k']*(-abs((2/(exp(1)-1))*(exp(`obs')-1)-1)+1)))
				}
			matrix metric[`i',`j']=metric[`i',`j']+`coef'
			
			}
		local ++i	
		}
	local ++j
	}
timer off 1
timer list
	

*Get matrix results
clear
svmat metric
qui export delimited using "$directorio\_aux\method_`var'_`spec'_`met'.csv", replace novarnames
*/
restore
