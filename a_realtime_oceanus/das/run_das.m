% This code is to copy, process and backup the DAS data on the EQ14 cruise
% on the RV Oceanus

 
clear all

tic

%% define paths and directories

disp(['running das timer at ' datestr(now+7/24) ' UTC'])

addpath('~/GDrive/data/eq14/das/mfiles/')
addpath('~/GDrive/data/eq14/das/mfiles/utilities/')

% arkdir = '/Volumes/cruise/current/das/';
arkdir = '~/ark01/cruise/current/das/';
ddark = dir([arkdir '2014*']);

% localdir = '~/Documents/MATLAB/oceanus2014/das_data/';
localdir = '~/GDrive/data/eq14/das/';

% wdmycloud = '/Volumes/mixing/data/EQ14/das/';
wdmycloud = '~/wdmycloud/mixing/data/EQ14/das/';


%% define important parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% either define a start day
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% startday = 20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% or determine the startday based on the date of avg_das.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
clear mm nn
ddproc = dir([localdir 'processed' filesep]);
for ii = 1:length(ddproc)
    if strcmp(ddproc(ii).name,'avg_das.mat')
        nn = ii;
    end
end
startdate = datestr(floor(ddproc(nn).datenum),'yyyy-mm-dd');
ddraw = dir([localdir 'raw' filesep '20*']);
for ii = 1:length(ddraw)
    if strcmp(ddraw(ii).name,startdate)
        mm = ii;
    end
end
startday = mm;

%% copy

disp(['     copying raw files to local computer..... at ' datestr(now + 7/24) ' UTC'])
copy_raw_das


%% process

disp(['     processing..... at ' datestr(now + 7/24) ' UTC'])
make_das_oceanus

%% combine and average

disp(['     combining..... at ' datestr(now + 7/24) ' UTC'])
combine_das_oceanus

disp(['     averaging..... at ' datestr(now + 7/24) ' UTC'])
average_das_data


%% copy back to wdmycloud

disp(['     copying processed files back to wdmycloud..... at ' datestr(now + 7/24) ' UTC'])
copy_proc_das


%% end

disp(['das data updated at ' datestr(now + 7/24) ' UTC'])

toc

