Calculate transfer functions:

1. Run plot_data_select_patch.m
Select turbulent patches. Length of the patch should be > 1.5 m.
Use GUI to plot power spectra for that patch, 
save it (if it looks reasonable) and load a new file
Continue untill all the calibration files are through.

2. Modify probnames.m: change deployment name, sensor names and 
maximum and minimum file numbers for each sensor

3. Run compute_transfer_functions_filters.m to create transfer functions.
This script uses saved spectra created during the first step.
