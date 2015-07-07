
CTD_chipod


This folder is part of the OSU Ocean Mixing Group ‘mixing software’ github repository. It was added by A. Pickering in March 2015.

This folder contains Matlab codes to process data from chi pods deployed on CTD rosettes.

The starting point for these codes were codes written by Jonathan Nash, June Marion, and others at OSU. These codes call many pre-existing chi pod functions (see the ‘chipod’ folder in the repository), also written by others at OSU. 

The chi pod processing requires CTD data as well, the processing of the CTD data will be done using the ‘ctd_processing’ folder. This will ensure a standard, reproducible format of CTD data, so that the chi pod processing software can be applied to any cruise. 

The file ‘process_chipod_script_template.m’ contains an example script that can be modified for a specific cruise. The folder ‘TestData’ contains processed CTD data and raw chi pod data for 1 cast (the processing template is set up to run for these files). This can be run to gain a better understanding of the processing and output, as well as testing after any changes to codes to ensure they still work. 

*Note* CTD-chipod processing and analysis is a work in progress. Any results should be considered with caution. If you have any questions about the processing, or plan to make any major changes to the codes, please contact Andy Pickering. (apickering@coas.oregon.state.edu)