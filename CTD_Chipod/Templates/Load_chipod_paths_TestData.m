%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Load_chipod_paths_TestData.m
%
% See also process_chipod_script_template.m
%
%------------------
% July 7, 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

CTD_out_dir_root=fullfile(mixpath,'CTD_chipod','/TestData/CTD/processed/')

% Folder to save processed 24Hz CTD mat files to
CTD_out_dir_24hz=fullfile(CTD_out_dir_root,'24hz')

% Folder to save processed and binned (1m) CTD mat files to
CTD_out_dir_bin=fullfile(CTD_out_dir_root,'binned')

% Folder to save processed figures to
CTD_out_dir_figs=fullfile(CTD_out_dir_root,'figures')

chi_data_path=fullfile(mixpath,'CTD_chipod','/TestData/Chipod/raw/')

chi_proc_path=fullfile(mixpath,'CTD_chipod','/TestData/Chipod/processed/')
%%