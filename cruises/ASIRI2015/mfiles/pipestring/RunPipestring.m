function RunPipestring
%~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% RunPipestring
%
% Run processing for pipestring ADCP on Aug 2015 ASIRI cruise
%
% Updated 09/20/15 A.Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
addpath('/Volumes/scienceparty_share/mfiles/pipestring')
addpath('/Volumes/scienceparty_share/mfiles/nav')

% read in any new nav data from ship
asiri_read_running_nav;

% read in any new raw ADCP files and save mat files
loadsaveENR;

% process (apply heading offset, smooth, etc)
process_pipestring;

% plot summary of data
PlotPipestringSummary


%%