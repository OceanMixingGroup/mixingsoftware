function add_uhpaths(adcppathname)
%
% add_uhpaths(adcppathname)
%
% This code adds the UHDAS+CODAS functions used to process the shipboard
% ADCP data. These functions are saved in a folder called uh_programs/matlab/.
% They need to be added to the matlab path in order for the processing to
% take place, however, do not add them permanently because there are many
% functions that have names of functions ALREADY in mixingsoftware which do
% different things.
%
% This function (add_uhpaths) gets called at the BEGINNING of make_adcp.
% The function rm_uhpaths gets called at the END of make_adcp.
%
% Sally Warner, January 2014, Oceanus

addpath(adcppathname)
addpath([adcppathname 'misc']);
addpath([adcppathname 'rawadcp' filesep 'utils' filesep]);
addpath([adcppathname 'rawadcp' filesep 'rdi']);
addpath([adcppathname 'rawadcp' filesep 'average']);
addpath([adcppathname 'rawadcp' filesep 'codasutils']);
addpath([adcppathname 'rawadcp' filesep 'logging']);
addpath([adcppathname 'utils']);
addpath([adcppathname 'codas3']);