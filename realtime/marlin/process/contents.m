% At sea processing is in three steps, back up data, process data
% to make a summary file, and plot the summary file.  Hey, thats
% four steps!
%  
% add_to_sum.m
% 	% add_to_sum.m
% 	% adds averaged data to a summary file.  
% cali_realtime.m
% 	% Script to calibrate sensors:
% 	% Specific for instrument and or cruise
% copy_ct01b_files.m
% 	% function copy_files(root_from_path,root_to_path) copies files
% 	% from subdirectories in root_FROM_PATH and places them into subdirs
% copy_hm02_files.m
% 	% Runs run_backup for HOME02 cruise
% 	% see run_backup
% copyfilecareful.m
% 	% function [status,msg]=copyfilecareful(from,to);
% 	%  This is a slight exageration of copyfile.m that runs diff.exe on
% initialize_summary_file.m
% 	% initializes the summary file.  Not sure why this is neede.
% 	% called before process_file.
% plot_cham_summary.m
% 	% plots a summary of the chameleon data.
% 	% updated once in a while.  Should be run on a separate computer
% process_file.m
% 	% Top routine for processing: from raw_load, calibrate, average,
% 	% adding to sum. Called by save_files.m
% run_backup.m
% 	% function run_backup(frompath,topath,dataprefix);
% 	% This is the top-level script for the back-up computer....
% save_files.m
% 	% top level routine for processing files and making the summary
% 	% file.  
% set_chameleon.m
% 	% I don't remember what this is for.  Seems to set a bunch of stuff
% 	% for initializing the plotting.
% show_chameleon.m
% 	% appears to run the plotting for chameleon summary plots.   
% 	% Querries user for summary to plot up.
