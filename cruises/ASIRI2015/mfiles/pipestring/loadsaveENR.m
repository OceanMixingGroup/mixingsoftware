%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% loadsaveENR.m
%
% Load the raw .ENR (beam coordinates) pipestring ADCP files and save as
% .mat . Also add time_offset and do beam-to-earth transformation.
%
% Time offsets are found in Time_Offset_pipestring.m
%
% Further processing done in process_pipestring.m
%
% For Aug 2015 ASIRI cruise. Started with script from 2014 cruise, from Emily Shroyer.
%
%--------------------------
% 08/25/15 - A. Pickering - Modifying for Aug 2015 cruise
% 09/18/15 - AP - Do beam2earth transform on each file here also (bogs down
% if we try to transform the huge combined file later)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% path to scienceparty_share (data)
SciencePath='/Volumes/Midge/ExtraBackup/scienceshare_092015/'

% path to Mfiles (github repo)
MfilePath='/Users/Andy/Cruises_Research/mixingsoftware/cruises/ASIRI2015/mfiles/'
%
addpath(fullfile(MfilePath,'shared'))
addpath(fullfile(MfilePath,'nav'))

%addpath('/Volumes/scienceparty_share/mfiles/shared/')

rawdir = fullfile(SciencePath,'pipestring','raw');
savedir = fullfile(SciencePath,'pipestring','mat');
cruise ='ASIRI2015';

files = dir([rawdir cruise '*.ENR']);
files_processed_beam=dir([savedir '*beam.mat']);
files_processed_earth=dir([savedir '*earth.mat']);
%%

% load time-offset fit
%load('/Volumes/scienceparty_share/pipestring/time_offset_fit.mat')
load(fullfile(SciencePath,'pipestring','time_offset_fit.mat'))

hb=waitbar(0,'working on pipestring files');

for ifile=2:length(files)
    waitbar(ifile/length(files),hb)
    clear fname fname_beam fname_earth adcp config
    fname=files(ifile).name
    fname_beam=['ADCP_' fname(1:end-4) '_beam.mat'];
    fname_earth=['ADCP_' fname(1:end-4) '_earth.mat'];

    clear adcp
    
    if ~exist(fullfile(savedir,fname_beam),'file')
        disp(['Reading ' fname ' into mat'])
        [adcp,config]=rdradcp(fullfile(rawdir,files(ifile).name),1);
        adcp.mtime(adcp.mtime==0)=nan; %
        adcp.mtime(adcp.mtime<datenum(2015,8,22))=nan;
        
        % apply time offset for adcp data
        clear time_offset
        time_offset=polyval(P,nanmean(adcp.mtime))
        adcp.mtime=adcp.mtime+time_offset/86400;
        adcp.timeoffsetinfo=['Time off set of ' num2str(time_offset) ' sec appied'];
        adcp.MakeInfo=['Made ' datestr(now) ' w/ loadsaveENR.m'];
        adcp.source=fullfile(rawdir,fname);
        
        % no bottom-tracking, remove un-needed fields
        adcp=rmfield(adcp,'bt_range');
        adcp=rmfield(adcp,'bt_vel');
        adcp=rmfield(adcp,'bt_corr');
        adcp=rmfield(adcp,'bt_ampl');
        adcp=rmfield(adcp,'bt_perc_good');
                
        save(fullfile(savedir,fname_beam),'adcp')
    else
        disp([fname_beam ' already exists'])
    end
    
    if ~exist(fullfile(savedir,fname_earth),'file')
        
        % load beam velocity mat file
%        if ~exist(adcp,'var')
        clear adcp
        disp('loading beam velocities')
        load(fullfile(savedir,fname_beam));
        
        clear xadcp nadcp N       
        
        disp('loading nav data')
        N=loadNavSpecTime([nanmin(adcp.mtime) nanmax(adcp.mtime)]);
        if numel(N.head)>2
        
        ttemp_nav=N.dnum_hpr; ig=find(diff(ttemp_nav)>0); ig=ig(1:end-1)+1;
        
        adcp.config.orientation='down';
        xadcp = adcp;
        %         xadcp.east_vel = xadcp.v1;
        %         xadcp.north_vel = xadcp.v2;
        %         xadcp.vert_vel = xadcp.v3;
        %         xadcp.error_vel = xadcp.v4;
        clear ttemp ig
        ttemp=N.dnum_hpr; ig=find(diff(ttemp)>0); ig=ig(1:end-1)+1;
        xadcp.heading=interp1(ttemp(ig),N.head(ig),xadcp.mtime);
        xadcp.pitch=interp1(ttemp(ig),N.pitch(ig),xadcp.mtime);
        xadcp.roll=interp1(ttemp(ig),N.roll(ig),xadcp.mtime);
        
        xadcp.Info='head/pitch/roll from ship nav';
        xadcp.MakeInfo=['Made ' datestr(now) ' w/ loadsaveENR.m'];
        
        disp(['rotating ' fname_beam ' from beam to earth'])
        nadcp=beam2earth_workhorse(xadcp);
        
        nadcp.Info='head/pitch/roll from ship nav';
        nadcp.MakeInfo=['Made ' datestr(now) ' w/ loadsaveENR.m'];
        save(fullfile(savedir,fname_earth),'xadcp','nadcp')
        else
           disp(['no nav data for this time period, skipping transform']) 
        end
        
    else
        disp([fname_earth ' already exists'])
    end
    
end

delete(hb)

%%

%
% filenames=[];
% for i=1:length(files)-1; % last file is partial and doesn't completely load? skip it
%     filenames{i}=char(files(i).name(end-13:end-4));
% end
%
% % check which files have been processed already
% kp=ones(1,length(filenames));
% for i=1:length(files_processed);
%     filenames_processed=char(files_processed(i).name(end-18:end-9));
%     if sum(strcmp(filenames_processed,filenames))==1;
%         kp(i)=0;
%     end
% end
% %
% ind=find(kp==1);
% %%
% if isempty(ind);
%     kp(end)=1;
% elseif kp(1)==1
%     kp=kp;
% else
%     kp(ind(1)-1)=1;
% end
% %%
% % read in the new files
% files=files(kp==1);
%
% disp(['Reading in ' num2str(length(files)) ' new files '])
% pause(1)
% for i=1:length(files)
%     [adcp,config]=rdradcp([rawdir files(i).name],1);
%     adcp.mtime(adcp.mtime==0)=nan; %
%     save([savedir 'ADCP_' files(i).name(1:end-4) '_beam.mat'],'adcp')
% end
%
% %%
%
%
