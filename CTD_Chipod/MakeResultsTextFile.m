%~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% MakeResultsTextFile.m
%
% Initialize a text file for results of CTD-chipod processing
%
% Replaces a bunch of lines in processing script (deletes any files of same
% name already existing in chi_proc_path).
% 
%---------------
% 10/7/15 - AP - apickering@coas.oregonstate.edu - initial coding
%~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% make a text file to print a summary of results to
txtfname=['Results' datestr(floor(now)) '.txt'];

if exist(fullfile(chi_proc_path,txtfname),'file')
%    delete(fullfile(chi_proc_path,txtfname))
end

fileID= fopen(fullfile(chi_proc_path,txtfname),'a');
fprintf(fileID,['\n \n CTD-chipod Processing Summary\n']);
fprintf(fileID,['\n \n Created ' datestr(now) '\n']);
fprintf(fileID,'\n CTD path \n');
fprintf(fileID,[CTD_out_dir_root '\n']);
fprintf(fileID,'\n Chipod data path \n');
fprintf(fileID,[chi_data_path '\n']);
fprintf(fileID,'\n Chipod processed path \n');
fprintf(fileID,[chi_proc_path '\n']);
%fprintf(fileID,'\n figure path \n');
%fprintf(fileID,[chi_fig_path '\n \n']);
fprintf(fileID,[' \n There are ' num2str(length(CTD_list)) ' CTD files' ]);

%%