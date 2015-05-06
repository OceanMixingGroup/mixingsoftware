
CTD_chipod


This folder is part of the OSU Ocean Mixing Group ‘mixing software’ github repository. It was added by A. Pickering in March 2015.

This folder contains Matlab codes to process data from chi pods deployed in CTD rosettes. It is currently a work in progress.

The starting point for these codes were codes written by Jonathan Nash and June Marion at OSU. These codes call many pre-existing chi pod functions (see the ‘chipod’ folder in the repository), written by others at OSU. 

The chi pod processing requires CTD data as well, the processing of the CTD data will be done using the ‘ctd_processing’ folder. This will ensure a standard, reproducible format of CTD data, so that the chi pod processing software can be applied to any cruise. 


Known Issues and To-Do list:

- Does not work for ‘big’ chi pods yet. These have two sensors, need to do calculation for both.