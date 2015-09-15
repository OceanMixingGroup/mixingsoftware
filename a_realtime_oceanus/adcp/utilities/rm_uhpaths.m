function rm_uhpaths(adcppathname)
%
% rm_uhpaths(adcppathname)
%
% This code removes the UHDAS+CODAS functions used to process the shipboard
% ADCP data. These functions are saved in a folder called uh_programs/matlab/.
% They need to be added to the matlab path in order for the processing to
% take place, however, do not add them permanently because there are many
% functions that have names of functions ALREADY in mixingsoftware which do
% different things. 
%
% The function add_uhpaths gets called at the BEGINNING of make_adcp.
% This function (rm_uhpaths) gets called at the END of make_adcp.
%
% Sally Warner, January 2014, Oceanus

rmpath(adcppathname)
rmpath([adcppathname 'misc']);
rmpath([adcppathname 'rawadcp' filesep 'utils' filesep]);
rmpath([adcppathname 'rawadcp' filesep 'rdi']);
rmpath([adcppathname 'rawadcp' filesep 'average']);
rmpath([adcppathname 'rawadcp' filesep 'codasutils']);
rmpath([adcppathname 'rawadcp' filesep 'logging']);
rmpath([adcppathname 'utils']);
rmpath([adcppathname 'codas3']);