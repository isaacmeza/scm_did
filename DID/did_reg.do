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

*Dummies
xi i.treatment*i.monthly, noomit

if `spec'==1 {
			qui xtreg `var'  1.treatment ///
			_Imonthly_636-_Imonthly_647 ///
			_Imonthly_649-_Imonthly_659 ///
			_ItreXmon_1_636-_ItreXmon_1_647  ///
			_ItreXmon_1_649-_ItreXmon_1_659  ///
				, fe cluster(iddomicilio)
			noi testparm _Imonthly_636-_Imonthly_647
			}
		else {
			qui xtreg `var'  1.treatment ///
			_Imonthly_636-_Imonthly_647 ///
			_Imonthly_649-_Imonthly_659 ///
			_ItreXmon_1_636-_ItreXmon_1_647  ///
			_ItreXmon_1_649-_ItreXmon_1_659  ///
			i.mes#1.treatment i.mes	, fe cluster(iddomicilio)
			noi testparm _Imonthly_636-_Imonthly_647
			}

	do "$directorio\DoFiles\graph_plot.do" ///
	 "`var'_`spec'_`metric'"	12
restore
