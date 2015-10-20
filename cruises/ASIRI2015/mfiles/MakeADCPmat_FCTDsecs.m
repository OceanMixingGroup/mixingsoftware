%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% MakeADCPmat_FCTDsecs.m
%
% Make mat files with ADCP data for same periods as FCTD sections in
% scienceparty_share/FTCD/FCTD_scratch/
%
% Saved in same folder, with '_adcp' appended to file names
%
%-----------
% 09/21/15 - A.Pickering - apickering@coas.oregonstate.edu
% 10/14/15 - AP - Copied from my science share copy to my laptop after
% cruise, now working on this copy.
% * working on adding pipestring
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

savedata=1

% path to my back-up of science share that has data files on it
SciencePath='/Volumes/Midge/ExtraBackup/scienceshare_092015/'
DataPath=fullfile(SciencePath,'data')

% path to save mat files to
savedir=fullfile(SciencePath,'adcp_secs')
ChkMkDir(savedir)

% load processed sidepople data
%Vfile='/Volumes/scienceparty_share/data/sentinel_1min.mat'
Vfile=fullfile(DataPath,'sentinel_1min.mat')
load(Vfile)

% load HDSS 140kHz data
%Hfile='/Volumes/scienceparty_share/data/hdss_bin_all.mat'
Hfile=fullfile(DataPath,'hdss_bin_all.mat')
load(Hfile)

Pfile=fullfile(DataPath,'pipestring_1min.mat');
load(Pfile)

% load Drew's file with section names and times
%load('/Volumes/scienceparty_share/FCTD/FCTD_scratch/fctd_names.mat')
load(fullfile(SciencePath,'FCTD','FCTD_scratch','fctd_names.mat'))

%%
for whsec=23:32%:length(fctd_names)
    
    clear adcp
    adcp=struct()l
    
    clear secname F FF time_range
    secname=fctd_names(whsec).name
    F=fctd_names(whsec)l
    
    try
        % load FCTD section to contour density
        load(fullfile(SciencePath,'FCTD','FCTD_scratch',[F.name '.mat']))
        %eval(['load([''/Volumes/scienceparty_share/FCTD/FCTD_scratch/' F.name '.mat''])' ])
        eval(['FF=' F.name ])l
       
        time_range=[nanmin(FF.grid.time) nanmax(FF.grid.time)]l
        
        % find indices for ADCP data in this time range
        clear idH idzh idV 
        idV=isin(V.dnum,time_range);
        idH=isin(sonar.datenum,time_range);
        idP=isin(P.dnum,time_range);
        
        % find depth indices
        idzh=find(sonar.depths>40);
        
        % sidepole data
        adcp.V.dnum=V.dnum(idV);
        adcp.V.z=V.z;
        adcp.V.u=V.u(:,idV);
        adcp.V.v=V.v(:,idV);
        adcp.V.lat=V.lat(idV);
        adcp.V.lon=V.lon(idV);
        adcp.V.source=Vfile;
        
        % compute distance also for plotting
        adcp.V.distkm=nan*ones(1,length(adcp.V.lat));
        for a=1:length(adcp.V.lat);
            [adcp.V.distkm(a),af,ar]=dist([adcp.V.lat(1) adcp.V.lat(a)],[adcp.V.lon(1) adcp.V.lon(a)]);
        end
        adcp.V.distkm=adcp.V.distkm/1e3;
        
        
        % pipestring data        
        adcp.P.dnum=V.dnum(idP);
        adcp.P.z=P.z;
        adcp.P.u=P.u(:,idP);
        adcp.P.v=P.v(:,idP);
        adcp.P.lat=P.lat(idP);
        adcp.P.lon=P.lon(idP);
        adcp.P.source=Pfile;        
        
        % compute distance also for plotting
        adcp.P.distkm=nan*ones(1,length(adcp.P.lat));
        for a=1:length(adcp.P.lat);
            [adcp.P.distkm(a),af,ar]=dist([adcp.P.lat(1) adcp.P.lat(a)],[adcp.P.lon(1) adcp.P.lon(a)]);
        end
        adcp.P.distkm=adcp.P.distkm/1e3;
        
        % HDSS 140kHz data
        adcp.H.dnum=sonar.datenum(idH);
        adcp.H.z=sonar.depths(idzh);
        adcp.H.lat=sonar.lat(idH);
        adcp.H.lon=sonar.lon(idH);
        adcp.H.u=real(sonar.U(idzh,idH));
        adcp.H.v=imag(sonar.U(idzh,idH));
        adcp.H.source=Hfile;
        
        % compute distance also for plotting
        adcp.H.distkm=nan*ones(1,length(adcp.H.lat));
        for a=1:length(adcp.H.lat);
            [adcp.H.distkm(a),af,ar]=dist([adcp.H.lat(1) adcp.H.lat(a)],[adcp.H.lon(1) adcp.H.lon(a)]);
        end        
        adcp.H.distkm=adcp.H.distkm/1e3;
        
        adcp.MakeInfo=['made ' datestr(now) ' w/ /mfiles/analysis/MakeADCPmat_FCTSsecs.m'];
        adcp.Info=['V=sidepole (0-40m),P=pipestring, H=HDSS140kHz (>40m)'];
        
        if savedata==1
        % save the mat file
        save(fullfile(savedir,[F.name '_adcp.mat']),'adcp')
        end
        
    end % try
    
end % which section

%%