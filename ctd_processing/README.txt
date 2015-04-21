
ctd_processing

This folder is part of the OSU Ocean Mixing Group ‘mixing software’ github repository. It was added by A. Pickering on April 21, 2015.

This folder contains Matlab codes to process raw data files from Seabird CTDs that are deployed on most of the UNOLs ships.

The starting point for this folder was the folder ctd_proc2 from Jen MacKinnon (Scripps). Many of the core functions within this folder were written by Dan Rudnick, Shaun Johnston, and Robert Todd.

The main reason for putting this in the repository is to have a stable, standard set of processing codes to use for ctd-chipod processing, which requires ctd data.

Processing outline:

- Copy CTD instrument calibration numbers into file cfgloadxxx.m . Calibrations are found in the xmlcon file from the seabird data.

- Run load_hex_xxx.m 

- 