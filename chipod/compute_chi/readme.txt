Calculate Chipod Chi:

run_calc_chipod_chi.m
	get_chipod_cals.m
		get_chipod_raw.m
			raw_load_chipod.m
                        clean_raw_chipod_(deployment).m - optional
                cali_chipod_(deployment).m
		calibrate_tp_forchi.m
		get_current_spd.m
                %%%%%%%%%% For Chipods with rate sensor %%%%%%%%%%%%%%%
                calc_filtered_rotations.m (in mixingsoftware/rotation/)
                calc_lp_rotations.m (in mixingsoftware/rotation/)
                remove_gravitation.m (in mixingsoftware/rotation)
                translatevectorrpy.m (in mixingsoftware/rotation)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		integrate_acc.m
		get_dTdz_byslope.m
	get_chipod_chi.m


Read function help for parameters
_____________________________________________

The file structure under dpath should be as follows
/data/(unit#)/(raw data files)
/current_data/current.mat (summary file with current data, contain
                           structure with fields 'time','u','v','depth')
/noise_spec/noise_spectra_chipod(unit#)_T1(and _T2).mat
/transfer_fcn/transfer_functions.mat

_______________________________________________

In first run do_noise in run_calculate chipod_chi.m should be set to 0
and chi & epsilon should be calculated without noise cutoff.
Then make_noise_spectra.m should be used to get noise spectra.
This script should be adjusted for every deployments.
After noise spectra is calculated and saved in
/noise_spec/noise_spectra_chipod(unit#)_T1(and _T2).mat
run_calculate chipod_chi.m should be run again with do_noise = 1.