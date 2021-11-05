global directorio C:\Users\xps-seira\Dropbox\Statistics\P13

set seed 928371

*-------------------------------------------------------------------------------

*Cleaning and creation of CAM dataset
do "$directorio\panel_cam_month.do"

*Cleaning and creation of MEX dataset
do "$directorio\panel_mex_month.do"

*Dataset to pass SCM (synth) in R
do "$directorio\panel_smooth_month.do"
