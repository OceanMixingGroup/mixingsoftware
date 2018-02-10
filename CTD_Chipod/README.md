
# CTD_chipod
  

This folder contains Matlab codes to process data from chi pods deployed on CTD rosettes. This folder is part of the OSU Ocean Mixing Group ‘mixing software’ github repository. It was added by A. Pickering in March 2015.

The starting point for these codes were codes written by Jonathan Nash, June Marion, and others at OSU. These codes call many pre-existing chi-pod functions (see the ‘chipod’ folder in the repository), also written by others at OSU. 

### Organization

*Note templates are being replaced w/ general functions so we don't have to make a separate copy of each mfile for each cruise.*

- **mixingsoftware/chipod** contains base chi-pod functions (including the actual chipod calculations).
- **mixingsoftware/CTD_chipod/mfiles** contains Matlab functions called during the processing of CTD-chipod data. Many of these call the base /chipod functions after prepping the data.
- **mixingsoftware/CTD_chipod/templates** contains template scripts that can be modified to process a specific cruise.
- The chi pod processing requires CTD data as well, the processing of the CTD data will be done using the **mixingsoftware/ctd_processing** folder. This will ensure a standard, reproducible format of CTD data, so that the chi pod processing software can be applied to any cruise. 

### Basic Processing Outline 

A guide to processing CTD-chipod cruise data is at: <https://github.com/OceanMixingGroup/mixingsoftware/blob/master/CTD_Chipod/ChipodProcessingGuide/CtdChipodProcessingGuide.pdf>

If you encounter any mistakes or missing information in the guide, please contact us or open an issue.

*Note* CTD-chipod processing and analysis is a work in progress. Any results should be considered with caution. If you have any questions about the processing, or plan to make any major changes to the codes, please contact Andy Pickering. (andypicke@gmail.edu)
