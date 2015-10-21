
Updated 10/21/15 A.Pickering

Processing scripts for side pole ADCP on August 2015 ASIRI cruise on R/V Revelle. Starting point was scripts from previous cruise provided by Jen MacKinnon. Modified for use on this cruise by A. Pickering starting 08/281/15.

raw data is in /scienceparty_share/sidepole/raw/

processing is in /scienceparty_share/mfiles/sidepole (now in OSU github repository)


Current Processing Outline:

1) Use bbslice program to split the raw .PDO files into smaller 50 MB files. Raw files from ADCP are quite large (1-2GB) and crashed Matlab, so they are split with BBslice into files of 50Mb.

2) run asiri_read_running_nav to get latest ship navigation data (the heading and lat/lon from this is used for the processing). *Note for post-cruise processing, this has been run already so this step can be skipped.*

3) PDO_to_mat_sidepole_Asiri15.m . This reads the raw ADCP files into mat files, and also does beam-to-earth transform (saved as separate files). The first time this is run for a set of files, run for one file and find time-offset with FindTimeOffsetPole.m. Then run for all the split files using that time-offset. Note the ship heading is used for the beam-to-earth transform.

4) process_pole_Aug2015_ASIRI_vv.m . This loads the mat files and does processing on each one to produce absolute velocities (apply heading correction, remove ship speed). Saves mat files with ‘proc_raw’ at the end of name.

5) CombineSplitFilesSidepole_V2.m . This combines all the files made in previous step into one file, does despiking/averaging, and saves file named ‘/scienceparty_share/sidepole/mat/sentinel_1min_File7.mat’ or something.

6) CombineSidepoleMatFiles.m : This combines all the larger mat files into one file for the entire cruise, saved in /scienceparty_share/data/Sentinel_1min.mat

