function PrintChiPathsGeneral(PathSetFile)
%~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PrintChiPathsGeneral(PathsetFile)
%
% Generate text giving data paths for a CTD_chipod project, to be pasted
% into Latex notes.
%
% INPUT:
% PathSetFile : m-file that sets paths for this deployment (should be string, in quotes)
%
%----------------------
% 10/26/15 - AP - initial coding
%~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

eval(PathSetFile)
clc
nl='\newline';

disp(['Raw CTD data is in: ' nl ])
disp(['\verb+' CTD_data_dir '+ ' nl])

disp(['Processed CTD data is in: ' nl ])
disp(['\verb+' CTD_out_dir_root '+ ' nl])

disp(['Raw chipod data is in: ' nl ])
disp(['\verb+' chi_data_path '+ ' nl])

disp(['Processed chipod data is in: ' nl ])
disp(['\verb+' chi_proc_path '+ ' nl])

%%