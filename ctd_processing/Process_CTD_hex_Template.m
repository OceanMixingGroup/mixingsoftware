%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Process_CTD_hex_Template.m
%
%
% Script to process raw (.hex) shipboard (Seabird) CTD data. Part of
% ctd_processing folder in OSU mixing software github repo. Originally
% designed to make data needed for CTD-chipod proccesing, but also useful
% for regular CTD processing.
%
% OUTPUT:
% - Processed 24Hz data mat files. These are used in
% the CTD-chipod processing to align the accelerations up in time.
% - Procesed and binned (1m) data. The chipod processing uses N^2
% and dT/dz computed from these.
% - Summary figures.
%
% Instructions:
% - Copy this file to a new script and save as Process_CTD_hex_[cruise
% name]
% - Modify the data directory and output paths
% - Run script!
%
% Modified from original script from Jen MacKinnon @ Scripps. Modified by A. Pickering
%
% A. Pickering - April 21, 2015 - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

addpath /Users/Andy/Cruises_Research/mixingsoftware/ctd_processing/

% *** For recording filename used to process data
this_file_name='Process_CTD_hex_Template.m'

% ~ *** cruise name (in filename of CTD files) ***
% example: CTD file 'TS-cast002.hex', cruise='TS'
cruise='TS'

% *** Paths to raw and processed data ***

% Folder with raw CTD data (.hex and .XMLCON files)
datadir='/Users/Andy/Cruises_Research/IWISE/Data/2011/ctd/'

% Base directory for all output
root_dir='/Users/Andy/Cruises_Research/ChiPod/'

% Folder to save processed 24Hz CTD mat files to
outdir_raw=fullfile(root_dir,'processed','24hz')

% Folder to save processed and binned CTD mat files to
outdir_bin=fullfile(root_dir,'processed','binned')

% Folder to save figures to
figdir=fullfile(root_dir,'processed','figures')

% Check if folders exist, and make new if not
ChkMkDir(figdir)
ChkMkDir(outdir_bin)
ChkMkDir(outdir_raw)

dobin=1;  % bin data
doascii=0 % option to save data as text file for LADCP processing

%~~~
% Make list of all ctd files we have
ctdlist = dirs(fullfile(datadir, [cruise '*.hex']))

% Loop through each cast
for icast=1%:length(ctdlist)
    
    close all
    
    disp('=============================================================')
    
    
    % name of file we are working on now
    ctdname = fullfile(datadir,ctdlist(icast).name)
    % name for processed matfile
    outname=[sprintf([cruise '_%03d'],icast) '.mat']
    matname=fullfile(outdir_bin, outname);
    disp(['CTD file: ' ctdname])
    %~~~
    
    % ~ load calibration info (should be updated for each cruise)
    disp('Loading calibrations')
    
    % *** Load calibration info for CTD sensors
    confile=[ctdname(1:end-3) 'XMLCON']
    cfg=MakeCtdConfigFromXMLCON(confile)
    
    % Load Raw data
    disp(['loading: ' ctdname])
    % include ch4
    d = hex_read(ctdname);
    disp(['parsing: ' ctdname ])
    data1 = hex_parse(d);
    
    % check for modcount errors
    dmc = diff(data1.modcount);
    mmc = mod(dmc, 256);
    %figure; plot(mmc); title('mod diff modcount')
    fmc = find(mmc - 1);
    if ~isempty(fmc);
        disp(['Warning: ' num2str(length(dmc(mmc > 1))) ' bad modcounts']);
        disp(['Warning: ' num2str(sum(mmc(fmc))) ' missing scans']);
    end
    
    % check for time errors
    dt = data1.time(end) - data1.time(1); % total time range of cast (seconds?)
    ds = dt*24; % # expected samples at 24Hz ?
    np = length(data1.p); % # samples
    mds = np - ds;  % difference between expected and actual # samples
    if abs(mds) >= 24; disp(['Warning: ' num2str(mds) ' difference in time scans']); end
    
    % time is discretized
    nt=length(data1.time);
    time0=data1.time(1):1/24:data1.time(end);
    
    % convert freq, volatage data
    disp('converting:')
    % *** fl, trans, ch4
    data2 = physicalunits(data1, cfg);
    
    %~~~
    figure(1);clf
    
    subplot(121)
    plot(data2.t1,data2.p,data2.t2,data2.p)
    axis ij
    ylabel('p [db]')
    grid on
    xlabel('temp [^oC]')
    title(ctdlist(icast).name,'interpreter','none')
    legend('t1','t2','location','Southeast')
    
    subplot(122)
    plot(data2.c1,data2.p,data2.c2,data2.p)
    axis ij
    ylabel('p [db]')
    grid on
    xlabel('cond.')
    legend('c1','c2','location','east')
    
    print('-dpng',fullfile(figdir,[ctdlist(icast).name(1:end-4) '_Raw_Temp_Cond_vsP']))
    %~~~
    
    % add correct time to data
    tlim=now+5*365;
    if data2.time > tlim
        tmp=linspace(data2.time(1),data2.time(end),length(data2.time));
        data2.datenum=tmp'/24/3600+datenum([1970 1 1 0 0 0]);
    end
    
    % output raw data
    disp(['saving: ' matname])
    matname0 = fullfile(outdir_raw,[outname(1:end - 4) '_0.mat'])
    save(matname0, 'data2')
    
    % specify the depth range over which t-c lag fitting is done. For deep
    % stations, use data below 500 meters, otherwise use the entire depth
    % range.
    
    if max(data2.p)>800
        data2.tcfit=[500 max(data2.p)];
    else
        data2.tcfit=[200 max(data2.p)];
    end
    
    
    %%
    disp('cleaning:')
    data3 = ctd_cleanup(data2, icast);
    
    %%
    
    disp('correcting:')
    % ***include ch4
    [datad4, datau4] = ctd_correction_updn(data3); % T lag, tau; lowpass T, C, oxygen
    
    disp('calculating:')
    % *** despike oxygen
    datad5 = swcalcs(datad4, cfg); % calc S, theta, sigma, depth
    datau5 = swcalcs(datau4, cfg); % calc S, theta, sigma, depth
    
    %%
    disp('removing loops:')
    % *** Might need to modify based on CTD setup
    wthresh = 0.4   ;
    datad6 = ctd_rmloops(datad5, wthresh, 1);
    datau6 = ctd_rmloops(datau5, wthresh, 0);
    
    %% despike
    
    datad7 = ctd_cleanup2(datad6);
    datau7 = ctd_cleanup2(datau6);
    
    
    %% compute epsilon now, as a test
    doeps=0;
    if doeps
        sigma_t=0.0042; sigma_rho=0.0011;
        
        disp('Calculating epsilon:')
        [Epsout,Lmin,Lot,runlmax,Lttot]=compute_overturns2(datad6.p,datad6.t1,datad6.s1,nanmean(datad6.lat),0,3,sigma_t,1);
        %[epsilon]=ctd_overturns(datad6.p,datad6.t1,datad6.s1,33,5,5e-4);
        datad6.epsilon1=Epsout;
        datad6.Lot=Lot;
    end
    %%
    
    if dobin
        disp('binning:')
        dz = 0.25; % m
        zmin = 0; % surface
        [zmax, imax] = max([max(datad7.depth) max(datau7.depth)]);
        zmax = ceil(zmax); % full depth
        datad = ctd_bincast(datad7, zmin, dz, zmax);
        datau = ctd_bincast(datau7, zmin, dz, zmax);
        datad.datenum=datad.time/24/3600+datenum([1970 1 1 0 0 0]);
        datau.datenum=datau.time/24/3600+datenum([1970 1 1 0 0 0]);
        
        disp(['saving: ' matname])
        save(matname, 'datad', 'datau')
        
    end
    
    %% 1-m bin
    
    if dobin
        disp('binning:')
        dz = 1; % m
        zmin = 0; % surface
        [zmax, imax] = max([max(datad7.depth) max(datau7.depth)]);
        zmax = ceil(zmax); % full depth
        datad_1m = ctd_bincast(datad7, zmin, dz, zmax);
        datau_1m = ctd_bincast(datau7, zmin, dz, zmax);
        datad_1m.datenum=datad_1m.time/24/3600+datenum([1970 1 1 0 0 0]);
        datau_1m.datenum=datau_1m.time/24/3600+datenum([1970 1 1 0 0 0]);
        %%%%%%%%% remove 0s from cast 153 %%%%%%%%%%%%%%%%%
        if icast == 153
            flds = fieldnames(datau);
            for a = 1:11
                datau.([flds{a}])(datau.([flds{a}])==0) = NaN;
                datad.([flds{a}])(datad.([flds{a}])==0) = NaN;
                datau_1m.([flds{a}])(datau_1m.([flds{a}])==0) = NaN;
                datad_1m.([flds{a}])(datad_1m.([flds{a}])==0) = NaN;
            end
        end
        
        datad_1m.MakeInfo=['Made ' datestr(now) ' w/ ' this_file_name  ' in ' version]
        datau_1m.MakeInfo=['Made ' datestr(now) ' w/ ' this_file_name  ' in ' version]
        datad.MakeInfo=['Made ' datestr(now) ' w/ ' this_file_name  ' in ' version]
        datau.MakeInfo=['Made ' datestr(now) ' w/ ' this_file_name  ' in ' version]
        
        
        datad_1m.source=ctdname;
        datau_1m.source=ctdname;
        datad.source=ctdname;
        datau.source=ctdname;
        
        datad_1m.confile=confile;
        datau_1m.confile=confile;
        datad.confile=confile;
        datau.confile=confile;
        
        disp(['saving: ' matname])
        save(matname, 'datad_1m', 'datau_1m','datad','datau')
        
    end
    
    %% Plot binned profiles
    
    figure(3);clf
    subplot(121)
    plot(datad_1m.t1,datad_1m.p,'-')
    hold on
    plot(datad_1m.t2,datad_1m.p,'--')
    axis ij
    grid on
    xlabel('Temp [^oC]')
    ylabel('Pressure [db]')
    title(ctdlist(icast).name,'interpreter','none')
    legend('t1','t2','location','Southeast')
    
    subplot(122)
    plot(datad_1m.s1,datad_1m.p,'-')
    hold on
    plot(datad_1m.s2,datad_1m.p,'--')
    axis ij
    grid on
    xlabel('Sal.')
    ylabel('Pressure [db]')
    legend('s1','s2','location','east')
    
    print('-dpng',fullfile(figdir,[ctdlist(icast).name(1:end-4) '_binned_Temp_Sal_vsP']))
    
    %% save as a text file for use by LADCP processing
    
    if doascii
        % a little  too high resolution in time, stalls ladcp processing
        % try to reduce a bit
        data3b = swcalcs(data3, cfg); % calc S, theta, sigma, depth
        
        sec=data3b.time-min(data3b.time);
        p=data3b.p;
        t=data3b.t1;
        s=data3b.s1;
        lat=data3b.lat;
        lon=data3b.lon;
        
        
        dataout=[sec p t s lat lon];
        ig=find(~isnan(mean(dataout,2))); dataout=dataout(ig,:);
        %save([outdir_bin outname(1:end-4) '.cnv'],'dataout','-ascii','-tabs')
        save(fullfile(outdir_bin,[outname(1:end-4) '.cnv']),'dataout','-ascii','-tabs')
    end
    %
    
    
    
end % cast #
%%
