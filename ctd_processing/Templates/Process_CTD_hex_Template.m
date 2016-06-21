%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Process_CTD_hex_Template.m
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
%---------------------
% 04/21/15 - A. Pickering - apickering@coas.oregonstate.edu
% 06/15/16 - AP - updating template
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

mixpath='/Users/Andy/Cruises_Research/mixingsoftware/'
addpath(fullfile(mixpath,'ctd_processing'))

% *** For recording filename used to process data
this_file_name='Process_CTD_hex_Template.m'

%***
%Paths to raw and processed data ***
Load_chipod_paths_Template
Chipod_Deploy_Info_Template

% Identifying string in filename of CTD files
% example: CTD file 'TS-cast002.hex', CastString='TS'
CastString=ChiInfo.CastString

% CTD processing params
ctdParams.wthresh=0.4;
ctdParams.dzbin=1;

dobin=1;  % bin data

% Make list of all ctd files we have
ctdlist = dirs(fullfile(CTD_data_dir, [CastString '*.hex']))
%
% Loop through each cast
for icast=1:length(ctdlist)
    
    
    try
        
        close all
        
        clear data1 data2 data3 data4 data5 data6 data7
        clear ctdname outname matname confile cfg d
        
        disp('=============================================================')
        
        % name of file we are working on now
        castnameshort=ctdlist(icast).name
        % file with full path
        castnamefull = fullfile(CTD_data_dir,ctdlist(icast).name)
        % remove the .hex
        castStr=castnameshort(1:end-4)
        disp(['CTD file: ' castnamefull])
        %~~~
        
        % *** Load calibration info for CTD sensors
        confile=[castnamefull(1:end-3) 'XMLCON']
        cfg=MakeCtdConfigFromXMLCON(confile);
        
        % Load Raw data
        disp(['loading: ' castnamefull])
        % Read the hex file in
        d = hex_read(castnamefull);
        % Parse the hex file
        disp(['parsing: ' castnamefull ])
        %data1 = hex_parse(d);
        data1 = hex_parse_v2(d);
        
        % check for modcount errors
        clear dmc mmc fmc
        dmc = diff(data1.modcount);
        mmc = mod(dmc, 256);
        %figure; plot(mmc); title('mod diff modcount')
        fmc = find(mmc - 1);
        if ~isempty(fmc);
            disp(['Warning: ' num2str(length(dmc(mmc > 1))) ' bad modcounts']);
            disp(['Warning: ' num2str(sum(mmc(fmc))) ' missing scans']);
        end
        
        % check for time errors
        clear dt ds np mds
        dt = data1.time(end) - data1.time(1); % total time range of cast (seconds?)
        ds = dt*24; % # expected samples at 24Hz ?
        np = length(data1.p); % # samples
        mds = np - ds;  % difference between expected and actual # samples
        if abs(mds) >= 24; disp(['Warning: ' num2str(mds) ' difference in time scans']); end
        
        % time is discretized
        clear nt time0
        nt=length(data1.time);
        time0=data1.time(1):1/24:data1.time(end);
        
        % convert freq, volatage data
        disp('converting:')
        % *** fl, trans, ch4
        data2 = physicalunits(data1, cfg);
        
        % Plot raw profiles of temp and cond.
        h=PlotRawCTDprofiles(data2,ctdlist,icast)
        print('-dpng',fullfile(CTD_out_dir_figs,[castStr '_Raw_Temp_Cond_vsP']))
        %~~~
        
        % add correct time to data
        tlim=now+5*365;
        if data2.time > tlim
            tmp=linspace(data2.time(1),data2.time(end),length(data2.time));
            data2.datenum=tmp'/24/3600+datenum([1970 1 1 0 0 0]);
        end
        
        % output raw data
        matname24hz = fullfile(CTD_out_dir_24hz,[castStr '_24hz.mat'])
        disp(['saving: ' matname24hz])
        save(matname24hz, 'data2')
        
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
        
        datad6 = ctd_rmloops(datad5, ctdParams.wthresh, 1);
        datau6 = ctd_rmloops(datau5, ctdParams.wthresh, 0);
        
        %% despike
        
        datad7 = ctd_cleanup2(datad6);
        datau7 = ctd_cleanup2(datau6);
        
        %% 1-m bin
        
        if dobin
            disp('binning:')
            dz = ctdParams.dzbin; % m
            zmin = 0; % surface
            [zmax, imax] = max([max(datad7.depth) max(datau7.depth)]);
            zmax = ceil(zmax); % full depth
            datad_1m = ctd_bincast(datad7, zmin, dz, zmax);
            datau_1m = ctd_bincast(datau7, zmin, dz, zmax);
            datad_1m.datenum=datad_1m.time/24/3600+datenum([1970 1 1 0 0 0]);
            datau_1m.datenum=datau_1m.time/24/3600+datenum([1970 1 1 0 0 0]);
            
            
            datad_1m.MakeInfo=['Made ' datestr(now) ' w/ ' this_file_name  ' in Matlab ' version]
            datau_1m.MakeInfo=['Made ' datestr(now) ' w/ ' this_file_name  ' in Matlab ' version]
            
            datad_1m.source=castnamefull;
            datau_1m.source=castnamefull;
            
            datad_1m.confile=confile;
            datau_1m.confile=confile;
            
            datad_1m.ctdParams=ctdParams;
            datau_1m.ctdParams=ctdParams;
            
            matname_bin=fullfile(CTD_out_dir_bin,[castStr '.mat'])
            disp(['saving: ' matname_bin])
            save(matname_bin, 'datad_1m', 'datau_1m')%,
            
        end
        
        %% Plot binned profiles
        
        h=PlotBinnedCTDprofiles(datad_1m,datau_1m,castStr)
        print('-dpng',fullfile(CTD_out_dir_figs,[castStr '_binned_Temp_Sal_vsP']))
        
    end % try
    
end % cast #
%%

