
ctd_processing

This folder is part of the OSU Ocean Mixing Group ‘mixing software’ github repository. It was added by A. Pickering on April 21, 2015.

This folder contains Matlab codes to process raw data files from Seabird CTDs that are deployed on most of the UNOLs ships.

The starting point for this folder was the folder ctd_proc2 from Jen MacKinnon (Scripps). Many of the core functions within this folder were written by Dan Rudnick and/or Shaun Johnston and/or and Robert Todd. Any pre-existing author credits in codes have been preserved (some files did not have any Author info).

The main reason for putting this in the repository is to have a stable, standard set of processing codes to use for ctd-chipod processing, which requires ctd data.

~~~~~
Processing outline:

- The main script to start with is Process_CTD_hex.m 

Steps:

- Copy CTD instrument calibration numbers into file cfgloadxxx.m . Calibrations are found in the xmlcon file from the seabird data. (replace xxx with the cruise name)

- Copy Process_CTD_hex.m to a new script and save as Process_CTD_hex_[cruise name]

- Modify the data directory and output paths

- Modify the cfgxxx.m file with the correct file you created previously. Change this 
filename in script below .

- Run script!
~~~~~


~~~~~
Known Issues and To-Dos:
~~~~~

- hex_parse sometimes needs to be modified slightly, depending on cruise. Input ‘h’ (from hex_read.m) can have different size. In the data we’ve looked at, there are two cases which differ by 6 characters. The problem can be fixed by switching the last line in hex_parse:

data.time =  hex2dec(h(:, [87:88 85:86 83:84 81:82]));

or

data.time =  hex2dec(h(:, [87:88 85:86 83:84 81:82]-6));

In the future, will try to modify code to detect this and choose correct size automatically.

- Will try to incorporate a file from JN that reads the xmlcon calibration file, instead of having to manually copy and paste it into cfgloadxxx.m

- 

