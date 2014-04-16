% set_chameleon_oceanus.m
%
% This gets called by almost every other function to determine paths, etc. 
% Input the paths of the raw data (which has already been copied by 
% backup_chameleon_timer.m). Input the processed path. Also input: 
% cruise_id, year, maximum depth, and start file number. Pre-set the 
% parameters to plot, their units, and their color limits. 
%
% Functions that call set_chameleon_oceanus:
%   - backup_chameleon_timer_oceanus
%   - make_chameleon_timer_oceanus
%   - show_chameleon_timer_oceanus
%
%
% modified by Sally Warner, January 2014
%
%
% ################################################
% ###### THESE PATH AND PLOTTING PARAMETERS ######
% ###### SHOULD BE AJUSTED FOR EVERY CRUISE ######
% ################################################


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PATHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the paths for the raw and processed chameleon data

% note: I have received error messages about a "corrupted file" when I have
% tried saving  the summary file on ganges. Process locally on my computer
% and copy later.

% path_raw='\\graf-zeppelin\data2\ttp10\data\Chameleon\';
% path_cham='\\masada\work\ttp10\chameleon\';
% path_raw='~/work/RESEARCH/shipboard_realtime_data/cham_test/ttp10/data/chameleon/';
% path_cham='~/work/RESEARCH/shipboard_realtime_data/cham_test/ttp10/processed/chameleon/';

% note the raw path should NOT be where the RAW data is saved by the
% chameleon, but instead, it is where the raw data is copied by
% backup_chameleon_timer_oceanus.
% path_raw = '~/data/yq14/data/chameleon/raw/';
% path_cham='~/data/yq14/processed/chameleon/';
path_raw = '~/ganges/data/Yq14/Chameleon/raw/';
% path_cham = '~/ganges/data/Yq14/Chameleon/processed/';
path_cham = '~/data/yq14/processed/chameleon/';

% path_writeraw is where the chameleon writes all of the data. Data must be
% copied FROM here to path_raw before it can be processed!
% path_writeraw = '/Volumes/mixing/Data/YQ14/data/Chameleon/raw/';
path_writeraw = '~/ganges/data/Yq14/Chameleon/raw/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS FOR PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the cruise ID and year
cruise_id='YQ14';
year=2014;

% set number of depth bins. This should be greater than the deepest depth
% of the casts (m)
max_depth_bins = 200;
n_dep=max_depth_bins;


% startnumber: what is the first cast that you would like to include in the
% summary file?
firstfile = 586;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS FOR PLOTTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WHAT TO PLOT
fig.toplot={'log10(cham.EPSILON1)','log10(cham.EPSILON2)','cham.SIGMA',...
        'cham.T1','cham.T2','cham.SAL'};
% fig.toplot={'log10(cham.EPSILON1)','log10(cham.EPSILON2)','cham.SIGMA',...
%         'cham.T','cham.N2','cham.S'};

% CORRESPONDING SUBPLOT TITLES
fig.names={'log_{10} \epsilon_1','log_{10} \epsilon_2','\sigma', ... 
        'T1 [^oC]','T2 [^oC]','S [psu]'};
% fig.names={'log_{10} \epsilon_1','log_{10} \epsilon_2','\sigma', ... 
%         'T [^oC]','N2 [s^{-2}]','S [psu]'};
    
% INITIAL COLOR LIMITS, CORRESPONDING TO PLOTTING VARIABLES
% limits can be changed within the figure once the plot has been made
fig.colmin=[-10 -10  24   8.5   8.5  31];
fig.colmax=[-6  -6   26   9.2   9.2  32.5];
% fig.colmin=[-10 -10  21   7   0  29];
% fig.colmax=[-6  -6   24  13  0.1  31];

