%~~~~~~~~~~~~~~~~~
%
% PDO_to_mat_sidepole_Asiri15.m
%
% Read RDI files from Sentinel 500kHz on sidepole into matlab, and do beam
% to earth rotation. Each large .PDO file downloaded from the ADCP is split
% into ~50MB files using BBslice. These are then read into matlab with this
% script. NO time offsets added here. Ship heading is used for
% beam-to-earth transform
%
% (Formerly part of process_pole_Aug2015_ASIRI_v2.m)
%
%-----------------
% 09/16/15 - A.Pickering
% 10/19/15 - AP - Make paths general relative to SciencePath
%~~~~~~~~~~~~~~~
%%

clear ; close all

% path to scienceparty_share
SciencePath='/Volumes/Midge/ExtraBackup/scienceshare_092015/'
MfilePath='/Users/Andy/Cruises_Research/mixingsoftware/cruises/ASIRI2015/mfiles/'
%
addpath(fullfile(MfilePath,'nav'))
%cd(fullfile(SciencePath,'mfiles','sidepole'))

% root directory for data
dir_data=fullfile(SciencePath,'sidepole','raw')

% filenames
%fnameshort='ASIRI_2Hz_deployment_20150824T043756.pd0';lab='File1';;t_offset=0
%fnameshort='ASIRI 2Hz deployment 20150828T043335.pd0';lab='File2';t_offset=10
%fnameshort='ASIRI 2Hz deployment 20150829T123832.pd0';lab='File3';t_offset=0
fnameshort='ASIRI 2Hz deployment 20150904T053350.pd0';lab='File4';t_offset=10
%fnameshort='ASIRI 2Hz deployment 20150908T141555.pd0';lab='File5';t_offset=30
%fnameshort='ASIRI 2Hz deployment 20150911T223729.pd0';lab='File6';t_offset=30
%fnameshort='ASIRI 2Hz deployment 20150915T165213.pd0';lab='File7';t_offset=30
%fnameshort='ASIRI 2Hz deployment 20150917T091838.pd0';lab='File8';t_offset=0

% list of split files (~50mb each)
Flist=dir(fullfile(dir_data,[fnameshort(1:end-4) '_split*'])) % some have capital 'S' in split
%%

for a=11%:length(Flist)
    
    clear fname adcp
    fname=fullfile(dir_data,Flist(a).name)
    
    % check if mat file of beam velocity data already exists
    clear fname_beam_mat
    fname_beam_mat=fullfile(SciencePath,'sidepole','mat',[Flist(a).name '_beam.mat'])
    if 0%exist(fname_beam_mat,'file')
        disp('file already exists, loading')
        load(fname_beam_mat)
    else
        disp('no mat exists, loading file')
        % not processed yet, read data into mat
        clear adcp
        [adcp]=rdradcpJmkFast_5beam([fname]);
        
        % fix dnum in adcp
        clear iii ttemp Adatenum
        iii=find(diff(adcp.time)==0);
        ttemp=adcp.time; ttemp(iii+1)=ttemp(iii)+.5/24/3600;
        Adatenum=ttemp+datenum(2000,1,1,0,0,0)-1;
        adcp.dnum=Adatenum;
        % not using beam 5 for now...
        %Adatenum5=Adatenum+.25/24/3600; %vertical beam is offset by .25 second from janus: they alternate
        %Atot.dnum=Adatenum;
        
        adcp.dnum=adcp.dnum+t_offset/86400;
        
        adcp=rmfield(adcp,'btrange');
        adcp=rmfield(adcp,'btvel');
        adcp=rmfield(adcp,'btcorr');
        adcp=rmfield(adcp,'btamp');
        adcp.source=fname
        adcp.t_offset=['Time offset of ' num2str(t_offset) 'sec added'];
        adcp.MakeInfo=['Made ' datestr(now) ' w/ PDO_to_mat_sideple_Asiri15']
        
        % save mat file here
        save(fname_beam_mat,'adcp')
    end
    
    
    disp('loading nav data')
    %load('/Volumes/scienceparty_share/data/nav_tot.mat')
    clear N
    N=loadNavSpecTime([nanmin(adcp.dnum) nanmax(adcp.dnum)],SciencePath)
    ttemp_nav=N.dnum_hpr; ig=find(diff(ttemp_nav)>0); ig=ig(1:end-1)+1;
        
    % check if mat file with Earth vels exists
    % the beam-to-earth transform takes a lot of time/memory, sometimes
    % bogs down if I wait until the end to transform all at once. INstead,
    % do each smaller file one at a time.
    clear xadcp nadcp
    clear fname_earth_mat
    fname_earth_mat=fullfile(SciencePath,'sidepole','mat',[Flist(a).name '_earth.mat'])
    if 0%exist(fname_earth_mat,'file')
        disp('Earth vel file already exists, loading')
        load(fname_earth_mat)
    else
        disp('no rotated mat exists, transforming to earth')
        
        clear xadcp nadcp
        % make a 'xadcp' structure to rotate
        xadcp.east_vel =  squeeze(adcp.vel(1,:,:))/1e3;
        xadcp.north_vel = squeeze(adcp.vel(2,:,:))/1e3;
        xadcp.vert_vel = squeeze(adcp.vel(3,:,:))/1e3;
        xadcp.error_vel = squeeze(adcp.vel(4,:,:))/1e3;        
        % NOTE we use ship heading, not ADCP compass
        xadcp.heading=interp1(ttemp_nav(ig),N.head(ig),adcp.dnum);
        xadcp.dnum=adcp.dnum;
        
        % when read into mat, pitch and roll for Sentinel have some weird offset. If I have
        % time, should figure out how to read these in correctly
        % ** should use ship pitch and roll here also?
        xadcp.pitch=adcp.pitch+655.36; %
        xadcp.roll =adcp.roll+655.36; %
        %xadcp.pitch_adcp=adcp.pitch+
        %xadcp.pitch=interp1(ttemp_nav(ig),N.pitch(ig),adcp.dnum);
        %xadcp.roll=interp1(ttemp_nav(ig),N.roll(ig),adcp.dnum);
        
        xadcp.config.orientation='down';
        disp('Transforming to earth coordinates')
        nadcp=beam2earth_sentinel5(xadcp);
        
        xadcp.source=fname;
        xadcp.MakeInfo=['Made ' datestr(now) ' w/ PDO_to_mat_sidepole_Asiri15'];
        xadcp.Info.heading='heading from ship nav';
        nadcp.source=fname;
        nadcp.MakeInfo=['Made ' datestr(now) ' w/ PDO_to_mat_sidepole_Asiri15'];
        save(fname_earth_mat,'xadcp','nadcp')
        nadcp.Info.heading='heading from ship nav';
    end % rotated mat file exists
    
    
end % which file
%%