
# CTD_chipod
  

This folder contains Matlab codes to process data from chi pods deployed on CTD rosettes. This folder is part of the OSU Ocean Mixing Group ‘mixing software’ github repository. It was added by A. Pickering in March 2015.

The starting point for these codes were codes written by Jonathan Nash, June Marion, and others at OSU. These codes call many pre-existing chi-pod functions (see the ‘chipod’ folder in the repository), also written by others at OSU. 

### Organization

- **mixingsoftware/chipod** contains base chi-pod functions (including the actual chipod calculations).
- **mixingsoftware/CTD_chipod/mfiles** contains Matlab functions called during the processing of CTD-chipod data. Many of these call the base /chipod functions after prepping the data.
- **mixingsoftware/CTD_chipod/templates** contains template scripts that can be modified to process a specific cruise.
- The chi pod processing requires CTD data as well, the processing of the CTD data will be done using the **mixingsoftware/ctd_processing** folder. This will ensure a standard, reproducible format of CTD data, so that the chi pod processing software can be applied to any cruise. 

### Basic Processing Outline 
(replace *Template* with *CRUISE* is the name of the specific cruise/deployment)
- Update **Load_chipod_paths_Template.m**
- Update **Chipod_Deploy_Info_Template.m** Contains info on chi-pods deployed (sensor SN, direction, etc.).
- Run **MakeCasts_Template.m** . The first time this is run, will need to look at alignment plot to determine if *az_correction* is correct and if *Ax* and *Az* need to be swapped, and update Chipod_Deploy_Info_Template.m and MakeCasts_Template.m accordingly.
- **SummarizeProc_Template** Makes some summary figures and tables from 'Xproc.mat', produced by MakeCasts_Template.m
- **Plot_TP_profiles_EachCast_Template** Plots the dT/dt signal from each sensor for each cast.
- **Run DoChiCalc_Template** Runs the chi calculation for each profile.
- **Make_Combined_Chi_Struct_Template** Combines all the profiles into one standard structure 'XC'.
- **PlotXCsummaries_Template** Makes standard summary figures from XC.

*Note* CTD-chipod processing and analysis is a work in progress. Any results should be considered with caution. If you have any questions about the processing, or plan to make any major changes to the codes, please contact Andy Pickering. (apickering@coas.oregonstate.edu)
