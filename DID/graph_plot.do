/*USO:

do "$directorio\DoFiles\graphtemp.do" ///
 name 
 ti	
*/

args name   /*Name of graph*/  ///
	ti 		/*Periods to graph*/


preserve
	*Degrees of freedom for p-values and confidence intervals:
	local df = e(df_r)

	*Store results in a matrix
	local td = monthly("2014m1","YM")
	qui sum monthly
	local hi=`r(max)'
	local lo=`r(min)'
	local rows = `hi' - `lo' + 1
	matrix results = J(`rows', 4, .) /*4 cols are: (1) time period, (2) beta, (3) std error, (4) pvalue*/

	local row = 0
	forval p = `lo'/`hi' {
		local ++row
		local k = `p' - `td' 
		*Period
		matrix results[`row',1] = `k'
		*Beta (event study coefficient)
		cap matrix results[`row',2] = _b[_ItreXmon_1_`p']
		*Standard error
		cap matrix results[`row',3] = _se[_ItreXmon_1_`p']
		*P-value
		cap matrix results[`row',4] = 2*ttail(`df', ///
			abs(_b[_ItreXmon_1_`p']/_se[_ItreXmon_1_`p']) ///
		)
	}
	matrix colnames results = "k" "beta" "se" "p"


	***************************
	** GRAPH THE EVENT STUDY **
	***************************
	// First, replace data in memory with results
	clear
	svmat results, names(col) 


	// GRAPH FORMATTING
	// For graphs:
	local labsize medlarge
	local bigger_labsize large
	local ylabel_options  notick labsize(`labsize') angle(horizontal)
	local xlabel_options  notick labsize(`labsize')
	local xtitle_options size(`labsize') margin(top)
	local title_options size(`bigger_labsize') margin(bottom) color(black)
	local manual_axis lwidth(thin) lcolor(black) lpattern(solid)
	local plotregion plotregion(margin(sides) fcolor(white) lstyle(none) lcolor(white)) 
	local graphregion graphregion(fcolor(white) lstyle(none) lcolor(white)) 
	// To put a line right before treatment
	local T_line_options lwidth(thin) lcolor(gray) lpattern(dash)
	// To show significance: hollow gray (gs7) will be insignificant from 0,
	//  filled-in gray significant at 10%
	//  filled-in black significant at 5%
	local estimate_options_0  mcolor(gs7)   msymbol(Oh) msize(medlarge)
	local estimate_options_90 mcolor(gs7)   msymbol(Oh)  msize(medlarge)
	local estimate_options_95 mcolor(black) msymbol(O)  msize(medlarge)
	local rcap_options_0  lcolor(gs7)   lwidth(thin)
	local rcap_options_90 lcolor(gs7)   lwidth(thin)
	local rcap_options_95 lcolor(black) lwidth(thin)

	// We have from k=-6 to 7, but smaller sample at the ends
	//  since less observations were treated early/late enough to have
	//  k=-6 or k=7 for the full sample, for example.
	// Suppose we just want to graph from k=-5 to k=5. (This is 
	//  better than binning at k<=-5 and k>=5 in the regression itself;
	//  see discussion above.)

	local lo_graph = -`ti'
	local hi_graph = `ti'
	if `ti'>=20 {
		local jump=4
		}
	else {
		local jump=2
		}
	keep if k >= `lo_graph' & k <= `hi_graph'

	// Confidence intervals (95%)
	local alpha = .05 // for 95% confidence intervals
	gen rcap_lo = beta - invttail(`df',`=`alpha'/2')*se
	gen rcap_hi = beta + invttail(`df',`=`alpha'/2')*se

	// GRAPH
	#delimit ;
	graph twoway 
		(scatter beta k if p<0.05,           `estimate_options_95') 
		(scatter beta k if p>=0.05 & p<0.10, `estimate_options_90') 
		(scatter beta k if p>=0.10,          `estimate_options_0' ) 
		(rcap rcap_hi rcap_lo k if p<0.05,           `rcap_options_95')
		(rcap rcap_hi rcap_lo k if p>=0.05 & p<0.10, `rcap_options_90')
		(rcap rcap_hi rcap_lo k if p>=0.10,          `rcap_options_0' )
		, 
		title("Treatment effects", `title_options')
		ylabel(, `ylabel_options') 
		yline(0, `manual_axis')
		xtitle("Period relative to treatment", `xtitle_options')
		ytitle("Beta (Kcal)", `xtitle_options')
		xlabel(`lo_graph'(`jump')`hi_graph', `xlabel_options') 
		xscale(range(`min_xaxis' `max_xaxis'))
		xline(-0.5, `T_line_options')
		xscale(noline) /* because manual axis at 0 with yline above) */
		`plotregion' `graphregion'
		legend(off) 
	;
	#delimit cr
graph export "$sharelatex\Figuras\betas_did_`name'.pdf", replace
	
restore
