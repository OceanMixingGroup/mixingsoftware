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
% cruise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% during eq14 we had 3 separate legs to the cruise which all had different
% names: oc1411a, oc1411a_02, oc1411a_03
% Anna's experiment (what confilicts are there?)
%     oc1411a_04: os150 and wh300
%     oc1411a_05: os150 
%     oc1411a_06: os150 and os75
%     oc1411a_07: os75
%     oc1411a_08: os75 and wh300
%     oc1411a_09: wh300

legname = 'oc1411a_10';

if strcmp(legname(end-1:end),'04')
    ynprocesswh300 = 1;
    ynprocessos75  = 0;
    ynprocessos150 = 1;
elseif strcmp(legname(end-1:end),'05')
    ynprocesswh300 = 0;
    ynprocessos75  = 0;
    ynprocessos150 = 1;
elseif strcmp(legname(end-1:end),'06')
    ynprocesswh300 = 0;
    ynprocessos75  = 1;
    ynprocessos150 = 1;
elseif strcmp(legname(end-1:end),'07')
    ynprocesswh300 = 0;
    ynprocessos75  = 1;
    ynprocessos150 = 0;
elseif strcmp(legname(end-1:end),'08')
    ynprocesswh300 = 1;
    ynprocessos75  = 1;
    ynprocessos150 = 0;
elseif strcmp(legname(end-1:end),'09')
    ynprocesswh300 = 1;
    ynprocessos75  = 0;
    ynprocessos150 = 0; 
elseif strcmp(legname(end-1:end),'11') % just os75 with depth pinger
    ynprocesswh300 = 0;
    ynprocessos75  = 1;
    ynprocessos150 = 0; 
elseif strcmp(legname(end-1:end),'12') % just os75 without depth pinger
    ynprocesswh300 = 0;
    ynprocessos75  = 1;
    ynprocessos150 = 0;
else % legs 01, 02, 03, 10 and 13: all instruments were collecting scientific data  
    ynprocesswh300 = 1;
    ynprocessos75  = 1;
    ynprocessos150 = 1; 
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path to utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% since the version of the code that I'm running right now is not in
% mixingsoftware, it is therefore not on my matlab path. Add them here:
addpath('~/GDrive/data/eq14/adcp/shipboard/mfiles/')
addpath('~/GDrive/data/eq14/adcp/shipboard/mfiles/utilities/')
% addpath('c:\data\eq14\adcp\shipboard\mfiles\')
% addpath('c:\data\eq14\adcp\shipboard\mfiles\utilities\')


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
% adcppathname = '~/work/RESEARCH/shipboard_realtime_data/uh_programs/matlab/';
% adcppathname = 'c:\work\swarner\uh_programs\matlab\';
adcppathname = '~/GDrive/work/RESEARCH/shipboard_ADCP/uh_programs/matlab/';
% adcppathname = 'c:\data\eq14\adcp\uh_programs\matlab\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using the ocean surveyor 150kHz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matthew Alford left his 150kHz in the hull of Oceanus back in August
% 2014. It's here for our eq14 cruise. Likely it will not be there in the
% future. Set os150exist = 1 if this ADCP is mounted in the hull of the
% ship and being processed by UHDAS+CODAS software.
os150exist = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define directories of raw data on the ship's server (vega NOW rigel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% note: generally, scientists are only supposed to access data from ttwo,
% however, the ADCP files are not updates continuously on ttwo and
% therefore they must be read from vega.
% Also, check that the computer is mounted and these directories are
% accessible. The code will quit if these directories cannot be found.
% wh300dir = '/Volumes/cruise/raw/wh300/';
% os75dir = '/Volumes/cruise/raw/os75/';
% wh300dir = 'z:\current_cruise\raw\wh300\';
% os75dir = 'z:\current_cruise\raw\os75\';
% wh300dir = '~/rigel/cruise/raw/wh300/';
% os75dir  = '~/rigel/cruise/raw/os75/';
% wh300dir = 'z:\oc1411a_03\raw\wh300\';
% os75dir  = 'z:\oc1411a_03\raw\os75\';
wh300dir = ['~/GDrive/data/eq14/adcp/shipboard/uhdas_' legname '/raw/wh300/'];
os75dir = ['~/GDrive/data/eq14/adcp/shipboard/uhdas_' legname '/raw/os75/'];

if os150exist == 1
%     os150dir = '~/rigel/cruise/raw/os150/';
%     os150dir = 'z:\oc1411a_03\raw\os150\/';
    os150dir = ['~/GDrive/data/eq14/adcp/shipboard/uhdas_' legname '/raw/os150/'];
end

if ~exist(wh300dir)
    disp('Raw data path not found. Be sure the ship''s ADCP computer is mounted')
    disp('Quitting...')
    return
end
if ~exist(os75dir)
    disp('Raw data path not found. Be sure the ship''s ADCP computer is mounted')
    disp('Quitting...')
    return
end
if os150exist == 1
    if ~exist(os150dir)
        disp('Raw data path not found. Be sure the ship''s ADCP computer is mounted')
        disp('Quitting...')
        return
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define directories of processed data on a local directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save directory
% savedir = '~/data/yq14/processed/adcp/';
% savedir = 'c:\data\eq14\adcp\processed\';
% savedir = 'w:\data\eq14\ADCP\shipboard\reprocessed\';
savedir = ['~/GDrive/data/eq14/adcp/shipboard/processed/' legname filesep];
% savedir = 'c:\data\eq14\adcp\shipboard\reprocessed\';

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

if os150exist == 1
    mkdir(savedir,'os150')
    mkdir([savedir filesep 'os150' filesep],'nobottomtrk')
    mkdir([savedir filesep 'os150' filesep],'bottomtrk')
    mkdir([savedir filesep 'os150' filesep 'nobottomtrk' filesep],'1min')
    mkdir([savedir filesep 'os150' filesep 'nobottomtrk' filesep],'singleping')
    mkdir([savedir filesep 'os150' filesep 'bottomtrk' filesep],'1min')
    mkdir([savedir filesep 'os150' filesep 'bottomtrk' filesep],'singleping')
end
warning on

% name all of the save directories
wh300matdir1min     = [savedir 'wh300' filesep 'nobottomtrk' filesep '1min' filesep];
wh300matdir         = [savedir 'wh300' filesep 'nobottomtrk' filesep 'singleping' filesep];
wh300matdir1minbt   = [savedir 'wh300' filesep 'bottomtrk' filesep '1min' filesep];
wh300matdirbt       = [savedir 'wh300' filesep 'bottomtrk' filesep 'singleping' filesep];

os75matdir1min      = [savedir 'os75' filesep 'nobottomtrk' filesep '1min' filesep];
os75matdir          = [savedir 'os75' filesep 'nobottomtrk' filesep 'singleping' filesep];
os75matdir1minbt    = [savedir 'os75' filesep 'bottomtrk' filesep '1min' filesep];
os75matdirbt        = [savedir 'os75' filesep 'bottomtrk' filesep 'singleping' filesep];

if os150exist == 1
    os150matdir1min      = [savedir 'os150' filesep 'nobottomtrk' filesep '1min' filesep];
    os150matdir          = [savedir 'os150' filesep 'nobottomtrk' filesep 'singleping' filesep];
    os150matdir1minbt    = [savedir 'os150' filesep 'bottomtrk' filesep '1min' filesep];
    os150matdirbt        = [savedir 'os150' filesep 'bottomtrk' filesep 'singleping' filesep];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define plotting directories and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define the directories where the processed data is saved. Within these
% directories, the directory setup should be set by make_raw_mat_os75_wh300_uhdas.m
% wh300dirshort='~/work/RESEARCH/shipboard_realtime_data/adcp_test/processed/wh300/';
% os75dirshort='~/work/RESEARCH/shipboard_realtime_data/adcp_test/processed/os75/';
wh300dirshort = [savedir 'wh300' filesep];
os75dirshort  = [savedir 'os75' filesep];
if os150exist == 1
    os150dirshort  = [savedir 'os150' filesep];
end
% plotting information to be sent to show_current.m
plotinfo.ylim300 = [0 120]; % m
plotinfo.ylim75 = [0 800]; % m
if os150exist == 1
    plotinfo.ylim150 = [0 400]; % m
end
plotinfo.xlim = 0.5;  % days
plotinfo.clim =[-1 1]*1.5; % m/s
plotinfo.climamp = [0 200]; %dB
depth_offset=5; %

% lon and lat limits for the adcp position plot. This is *not* included in
% the gui at this point. So define positions here and plan not to change
% them without stopping the code.
% plotinfo.xlimpos = 
% plotinfo.ylimpos = 

% how long to wait before read *.mat file next time
waittime=5*60; % [sec] 

% Do you want to plot the bottom-track data or the no-bottom-track data?
% options are: 'bottomtrk' or 'nobottomtrk'
% Most likely, you want the no bottom-track data (which means that that
% bottom track velocity has been removed from the measured velocity)
% NOTE: when the depth is greater than about 1000m, bottomtracking doesn't
% work. The processing code computes the velocity BOTH using bottom
% tracking and the ship's navigation. This flag is just for the plots.
btvsnbt = 'nobottomtrk'; 

% Do you want the single ping or the 1 minute averaged data?
% options are: '1min' or 'singleping'
% Most likely, you want the 1 minute averages for the plots
spvsavg = '1min';

% make the correct directories to access the data when plotting
wh300plotdir = [wh300dirshort btvsnbt filesep spvsavg filesep];
os75plotdir = [os75dirshort btvsnbt filesep spvsavg filesep];
if os150exist == 1
    os150plotdir = [os150dirshort btvsnbt filesep spvsavg filesep];
end

% name of the file where the gui controls are
% guifilename = 'adduicontrols_oceanus';
guifilename = 'adduicontrols_oceanus';




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define backup directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The adcp data will be backed up every other hour. For now, we are just
% copying over the entire adcp directory from ttwo (which includes both raw
% data and data processed by UHDAS+CODAS.) 
%
% We are NOT copying over Sasha's processed ADCP data becuase it can just
% be reprocessed from the raw data if necessary.
%
% Note: eventually, this should be make more fast by looking at the
% directories and only copying files that have been changed since the last
% update. But it really doesn't take that much time, so maybe this is okay.

% directory on ark01 or rigel or vega or tfour where adcp data is saved
% frompathbackup = '/Volumes/ttwo_cruises/current/adcp/';
% frompathbackup = 'z:\current_cruise\';
% frompathbackup = '~/ark01/cruise/current/adcp/';
% frompathbackup = 'z:\oc1411a_03\';
frompathbackup = '~/rigel/cruise/';

% directory where uhdas data is backed up to on wdmycloud
% topathbackup = '~/data/yq14/data/adcp/';
% topathbackup = 'w:\data\EQ14\ADCP\shipboard\uhdas\';
% topathbackup = '~/GDrive/data/eq14/adcp/shipboard/uhdas/';
% topathbackup = '~/wdmycloud/mixing/data/EQ14/ADCP/shipboard/uhdas/';
% topathbackup = 'w:\data\EQ14\ADCP\shipboard\uhdas\';
topathbackup = '~/wdmycloud/mixing/data/EQ14/ADCP/shipboard/uhdas_second_backup/';

% local directory where uhdas data is backed up to
topathbackuplocal = ['~/GDrive/data/eq14/adcp/shipboard/uhdas_' legname filesep];
% topathbackuplocal = 'c:\data\eq14\adcp\shipboard\uhdas\';


 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we also want to copy the data processed by Sasha's code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copy data that was processed with sasha's code
% only neeed nobottomtrack but will copy both single ping and 1min
% procfrompath = 'c:\data\eq14\adcp\processed\';
% procfrompath = '~/GDrive/data/eq14/adcp/shipboard/processed/';
% procfrompath = 'c:\data\eq14\adcp\shipboard\reprocessed\';
procfrompath = ['~/GDrive/data/eq14/adcp/shipboard/processed/' legname filesep];

% make the save paths
% this will save this data to the wdmycloud 
% proctopath = 'w:\data\EQ14\ADCP\shipboard\reprocessed\';
proctopath = ['~/wdmycloud/mixing/data/EQ14/ADCP/shipboard/reprocessed/' legname filesep];



% seconds between backup
% polltime = 60*60; 
polltime = waittime;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define a default header correction angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The ashtech gives better heading than the gyro, however, the ashtech is
% not as reliable. If the ashtech is giving good data, a correction
% factor is calculated that changes the angle of the gyro heading (which
% is used to correct the measured velocities with respect to the ship's
% speed). If the ashtech is uniformly bad, it **MAY** be better to define a
% default correction angle. This applies most importantly when the ship is
% moving quickly over ground at a constant velocity.
% 
% For instance, during eq14, when we were transecting southward, there were
% problems with the zonal velocity ? it changed drastically when we
% stopped. (This correction affects the cross-track velocity way more than
% the along-track velocity.) A default correction factor of -4.25 degrees
% was used. 
%
% On November 14 at 3:40pm, we changed the UHDAS software to use a default
% correction angle. This is applied when processing the
% raw data, therefore, I still want to apply a correction factor here. If
% not, I will see this in the data and have to add an "if" statement to
% change the correction factor for any data collected after the ADCPs were
% reset.
%
% Calculate a default correction factor VERY roughly as: 
% verr = resting cross-track velocity minus cross-track velocity while ship is moving [m/s]
% shipspeed = speed of ship used when calculating verr (in m/s (1 m/s = 2kt))
% hcorrang = 2*asin(verr)*shipspeed
% h_corrang = -4.25; % for the southward transecting part of eq14
h_corrang = -4.4; % the default angle set on Nov 14 at 3:30pm local (22:30pm UTC)

% further note on this:
% using the correct header angle has been integrated into the code. The
% mean error is written to the screen when both sensors are working well.
% If the ashtech goes bad, h_corrang should be set to an angle that is
% close to the calculated heading error during times when both the ashtech
% and gyro are returning good data.

