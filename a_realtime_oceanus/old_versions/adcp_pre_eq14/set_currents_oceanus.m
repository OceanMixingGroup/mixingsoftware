% set_currents_oceanus
% 
% Originally written by Sasha Perlin
% adapted and commented by Sally Warner, January 2014
%
% this code is based on set_workhorse originally. I think Sasha named it
% set_currents around 2011
%
% Set the directory and some basic plotting information
%
% note: the January 2014 version of this code was written on a mac and all
% pathnames have mac syntax. Directory separators within the code do not
% use '/' or '\', but instead use 'filesep' so they should run on either a
% mac or a pc.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path to the uhdas matlab functions. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These are written by Jules Hummon and
% used by UHDAS+CODAS to process ADCP data. We are not using the
% UHDAS+CODAS system to process the realtime ship ADCP data because it does
% not work on the time-scales at which we need to see the data. Our
% processing routines do, however, make use a a lot of her matlab
% functions. Note, you do not want to permanently add the
% uh_programs/matlab folder to your matlab path because it contains
% functions with the same name as many of the mixingsoftware functions.
adcppathname = '~/work/RESEARCH/shipboard_realtime_data/uh_programs/matlab/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define directories of raw data on the ship's server (vega)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% note: generally, scientists are only supposed to access data from ttwo,
% however, the ADCP files are not updates continuously on ttwo and
% therefore they must be read from vega.
% Also, check that the computer is mounted and these directories are
% accessible. The code will quit if these directories cannot be found.
wh300dir = '/Volumes/cruise/raw/wh300/';
os75dir = '/Volumes/cruise/raw/os75/';
if ~exist(wh300dir)
    disp('Raw data path not found. Be sure the ship''s ADCP computer is mounted')
    disp('Quitting...')
    break
end
if ~exist(os75dir)
    disp('Raw data path not found. Be sure the ship''s ADCP computer is mounted')
    disp('Quitting...')
    break
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define directories of processed data on a local directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save directory
savedir = '~/data/yq14/processed/adcp/';

% Make sure all of the subfolders in the save directory are made
% note: mkdir does not overwrite existing directories
warning off
mkdir(savedir,'wh300')
mkdir(savedir,'os75')
mkdir([savedir filesep 'wh300' filesep],'nobottomtrk')
mkdir([savedir filesep 'wh300' filesep],'bottomtrk')
mkdir([savedir filesep 'os75' filesep],'nobottomtrk')
mkdir([savedir filesep 'os75' filesep],'bottomtrk')
mkdir([savedir filesep 'wh300' filesep 'nobottomtrk' filesep],'1min')
mkdir([savedir filesep 'wh300' filesep 'nobottomtrk' filesep],'singleping')
mkdir([savedir filesep 'wh300' filesep 'bottomtrk' filesep],'1min')
mkdir([savedir filesep 'wh300' filesep 'bottomtrk' filesep],'singleping')
mkdir([savedir filesep 'os75' filesep 'nobottomtrk' filesep],'1min')
mkdir([savedir filesep 'os75' filesep 'nobottomtrk' filesep],'singleping')
mkdir([savedir filesep 'os75' filesep 'bottomtrk' filesep],'1min')
mkdir([savedir filesep 'os75' filesep 'bottomtrk' filesep],'singleping')
warning on

% name all of the save directories
wh300matdir1min     = [savedir 'wh300' filesep 'nobottomtrk' filesep '1min' filesep];
os75matdir1min      = [savedir 'os75' filesep 'nobottomtrk' filesep '1min' filesep];
wh300matdir         = [savedir 'wh300' filesep 'nobottomtrk' filesep 'singleping' filesep];
os75matdir          = [savedir 'os75' filesep 'nobottomtrk' filesep 'singleping' filesep];
wh300matdir1minbt   = [savedir 'wh300' filesep 'bottomtrk' filesep '1min' filesep];
os75matdir1minbt    = [savedir 'os75' filesep 'bottomtrk' filesep '1min' filesep];
wh300matdirbt       = [savedir 'wh300' filesep 'bottomtrk' filesep 'singleping' filesep];
os75matdirbt        = [savedir 'os75' filesep 'bottomtrk' filesep 'singleping' filesep];







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define plotting directories and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define the directories where the processed data is saved. Within these
% directories, the directory setup should be set by make_raw_mat_os75_wh300_uhdas.m
% wh300dirshort='~/work/RESEARCH/shipboard_realtime_data/adcp_test/processed/wh300/';
% os75dirshort='~/work/RESEARCH/shipboard_realtime_data/adcp_test/processed/os75/';
wh300dirshort = [savedir 'wh300/'];
os75dirshort  = [savedir 'os75/'];


% plotting information to be sent to show_current.m
plotinfo.ylim300 = [0 100]; % m
plotinfo.ylim75 = [0 300]; % m
plotinfo.xlim = 0.5;  % days
plotinfo.clim =[-1 1]*0.5; % m/s
plotinfo.climamp = [0 200]; %dB
depth_offset=5; %

% lon and lat limits for the adcp position plot. This is *not* included in
% the gui at this point. So define positions here and plan not to change
% them without stopping the code.
% plotinfo.xlimpos = 
% plotinfo.ylimpos = 

% how long to wait before read *.mat file next time
waittime=120; % [sec] 

% Do you want to plot the bottom-track data or the no-bottom-track data?
% options are: 'bottomtrk' or 'nobottomtrk'
% Most likely, you want the no bottom-track data (which means that that
% bottom track velocity has been removed from the measured velocity)
btvsnbt = 'nobottomtrk'; 

% Do you want the single ping or the 1 minute averaged data?
% options are: '1min' or 'singleping'
% Most likely, you want the 1 minute averages
spvsavg = '1min';

% make the correct directories to access the data when plotting
wh300plotdir = [wh300dirshort btvsnbt filesep spvsavg filesep];
os75plotdir = [os75dirshort btvsnbt filesep spvsavg filesep];


% name of the file where the gui controls are
guifilename = 'adduicontrols_oceanus';




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define backup directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The adcp data will be backed up every other hour. For now, we are just
% copying over the entire adcp directory from ttwo (which includes both raw
% data and data processed by UHDAS+CODAS.) 
%
% Note: eventually, this should be make more fast by looking at the
% directories and only copying files that have been changed since the last
% update.

% directory on ttwo where adcp data is saved
frompathbackup = '/Volumes/ttwo_cruises/current/adcp/';

% local directory where adcp data is backed up to
topathbackup = '~/data/yq14/data/adcp/';

% seconds between backup
polltime = 3600; 



