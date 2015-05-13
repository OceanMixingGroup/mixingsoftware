%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% process_chipod_script_AP.m
%
% ** this is currently a work-in-progress (AP). I am working on T-tide data
% right now to get it running and fix things. Eventually there will be a
% general script that can be applied to any cruise.**
%
% Script to do CTD-chipod processing.
%
% This script is part of CTD_Chipod software folder in the the mixingsoftware github repo.
% For latest version, download/sync the mixingsoftware github repo at
% https://github.com/OceanMixingGroup/mixingsoftware
%
% Before running:
% -This script assumes that CTD data has been processed into mat files and
% put into folders in some kind of standard form (with 'ctd_processing').
% -CTD data are used for two purposes: (1) the 24Hz data is used to compute
% dp/dt and compare with chipod acceleration to find the time offset . (2)
% lower resolution (here 1m) N^2 and dTdz are needed to compute chi.
% -Chipod data files need to be downloaded and saved as well.
%
% Instructions to run:
% 1) Copy this file and add your cruise name to the end of the filename.
% Note - I have tried to put *** where you need to change paths in file
% 2) Modify paths for your computer and cruise
% 3) Modify chipod info for your cruise
% 4) Run!
%
% OUTPUT:
% Saves a file for each cast and chipod with:
% avg
% ctd
% Writes a text file called 'Results.txt' that summarizes the settings used
% and the results (whether it found a chipod file, if it had good data etc.
% for each cast).
%
% Dependencies:
% get_profile_inds.m
% TimeOffset.m
% load_chipod_data
% get_T_calibration
% calibrate_chipod_dtdt
% get_chipod_chi
%
%
% Notes/Issues/Todo:
%
% - On some cruises a RBR is also deployed with the chipods that measures P
% and T. Might modfiy codes so that RBR data can be used in place of cTd
% data (though not in places where salinity is important?)
%
% - Sometimes chipod T calibration is bad. Does this affect chi?
%
% -As of 31 Mar 2015 , this runs for Ttide data. Still need to test for
%  other cruises.
%
% Started with 'process_chipod_script_june_ttide_V2.m' on 24 Mar 2015 and
% modified from there. A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all ; clc

tstart=tic;

%~~~~ Modify these paths for your cruise/computer ~~~~

% *** path for 'mixingsoftware' ***
mixpath='/Users/Andy/Cruises_Research/mixingsoftware/'

cd (fullfile(mixpath,'CTD_Chipod'))
addpath(fullfile(mixpath,'general')) % makelen.m in /general is needed
addpath(fullfile(mixpath,'marlcham')) % for integrate.m
addpath(fullfile(mixpath,'adcp')) % need for mergefields_jn.m in load_chipod_data

% *** Path where ctd data are located (already processed into mat files). There
% should be a folder within it called '24Hz'
CTD_path='/Users/Andy/Dropbox/TTIDE_OBSERVATIONS/scienceparty_share/TTIDE-RR1501/data/ctd_processed/'

% *** Path where chipod data are located
chi_data_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/'

% *** path where processed chipod data will be saved
chi_processed_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/Processed/';

% path to save figures to
fig_path=[chi_processed_path 'figures/'];
ChkMkDir(fig_path)
% ~~~~~~

% Make a list of all ctd files
% *** replace 'leg1' with name that is in your ctd files ***
CTD_list=dir([CTD_path  '24hz/' '*_leg1_*.mat']);

% make a text file to print a summary of results to
txtfname=['Results' datestr(floor(now)) '.txt'];

if exist(fullfile(chi_processed_path,txtfname),'file')
    delete(fullfile(chi_processed_path,txtfname))
end

fileID= fopen(fullfile(chi_processed_path,txtfname),'a');
fprintf(fileID,['\n \n Created ' datestr(now) '\n']);
fprintf(fileID,'\n CTD path \n');
fprintf(fileID,[CTD_path '\n']);
fprintf(fileID,'\n Chipod data path \n');
fprintf(fileID,[chi_data_path '\n']);
fprintf(fileID,'\n Chipod processed path \n');
fprintf(fileID,[chi_processed_path '\n']);
fprintf(fileID,'\n figure path \n');
fprintf(fileID,[fig_path '\n \n']);

fprintf(fileID,[' \n There are ' num2str(length(CTD_list)) ' CTD files' ]);

% we loop through and do processing for each ctd file

hb=waitbar(0,'Looping through ctd files')

for a=1:20%:length(CTD_list)
    
    close all
    
    waitbar(a/length(CTD_list),hb)
    
    clear castname tlim time_range cast_suffix_tmp cast_suffix CTD_24hz
    castname=CTD_list(a).name;
    
    fprintf(fileID,[' \n \n ~' castname ]);
    
    %load CTD profile
    load([CTD_path '24hz/' castname])
    % 24Hz data loaded here is in a structure 'data2'
    CTD_24hz=data2;clear data2
    CTD_24hz.ctd_file=castname;
    % Sometimes the time needs to be converted from computer time into matlab (datenum?) time.
    % Time will be converted when CTD time is more than 5 years bigger than now.
    % JRM
    tlim=now+5*365;
    if CTD_24hz.time > tlim
        % jen didn't save us a real 24 hz time.... so create timeseries. JRM
        % from data record
        %disp('test!!!!!!!!!!')
        tmp=linspace(CTD_24hz.time(1),CTD_24hz.time(end),length(CTD_24hz.time));
        CTD_24hz.datenum=tmp'/24/3600+datenum([1970 1 1 0 0 0]);
    end
    
    clear tlim tmp
    time_range=[min(CTD_24hz.datenum) max(CTD_24hz.datenum)];
    
    % ** this might not work for other cruises/names ? - AP **
    cast_suffix_tmp=CTD_list(a).name; % Cast # may be different than file #. JRM
    cast_suffix=cast_suffix_tmp(end-8:end-6);
    
    % check if this is a towyo, if so skip for now
    clear splitlist
    splitlist=dir([CTD_path '*' cast_suffix '_split*.mat']);
    if size(splitlist,1)==0 % not a towyo, continue processing
        
        % load chipod info
        addpath /Users/Andy/Cruises_Research/Tasmania/
        Chipod_Deploy_Info_TTIDE
        
        %~~~ Enter Info for chipods deployed on CTD  ~~
        %~~~ This needs to be modified for each cruise ~~~
        
        for up_down_big=[1 2 4 5]
            
            close all
            
            % *** edit this info for your cruise/instruments ***
            short_labs={'SN1012','SN1013','SN1002','SN102','SN1010'};
            big_labs={'Ti UpLooker','Ti DownLooker','Unit 1002','Ti Downlooker','1010'};
            
            switch up_down_big
                case 1
                    whSN='SN1012' % uplooker
                case 2
                    whSN='SN1013' % downlooker
                case 3
                    whSN='SN1002' % this is a big chipod
                case 4
                    whSN='SN102'
                case 5
                    whSN='SN1010'
            end
            
            this_chi_info=ChiInfo.(whSN);
            clear chi_path az_correction suffix isbig cal is_downcast
            chi_path=fullfile(chi_data_path,this_chi_info.loggerSN);
            suffix=this_chi_info.suffix;
            isbig=this_chi_info.isbig;
            cal=this_chi_info.cal;
            
            fprintf(fileID,[ ' \n \n ' short_labs{up_down_big} ]);
            
            d.time_range=datestr(time_range); % Time range of cast
            
            chi_processed_path_specific=fullfile(chi_processed_path,['chi_' short_labs{up_down_big} ])
            ChkMkDir(chi_processed_path_specific)
            
            fig_path_specific=fullfile(fig_path,['chi_' short_labs{up_down_big} ])
            ChkMkDir(fig_path_specific)
            
            % filename for processed chipod data (will check if already exists)
            processed_file=fullfile(chi_processed_path_specific,['cast_' cast_suffix '_' short_labs{up_down_big} '.mat']);
            
            %~~ Load chipod data
            if  1%~exist(processed_file,'file') %commented for now becasue some files were made but contain no data
                %load(processed_file)
                %            else
                disp('loading chipod data')
                
                %~ For Ttide SN102, RTC on 102 was 5 hours 6mins behind for files 1-16?
                if strcmp(whSN,'SN102') && time_range(1)<datenum(2015,1,22,18,0,0)
                    % need to look at shifted time range
                    time_range_fix=time_range-(7/24)-(6/86400);
                    chidat=load_chipod_data(chi_path,time_range_fix,suffix,isbig);
                    % correct the time in chipod data
                    chidat.datenum=chidat.datenum+(7/24)+(6/86400);
                else
                    chidat=load_chipod_data(chi_path,time_range,suffix,isbig);
                end
                
                chidat.time_range=time_range;
                chidat.castname=castname;
                save(processed_file,'chidat')
                                
                %~ Moved this info here. For some chipods, this info changes
                % during deployment, so we will wire that in here for now...
                clear is_downcast az_correction
                
                %~ for T-tide SN1010, sensor was swapped and switched from up
                %to down at chipod file 25
                if strcmp(whSN,'SN1010')
                    
                    if chidat.datenum(1)>datenum(2015,1,25) % **check this, approximate **
                        % dowlooking
                        % is_downcast=1;
                        this_chi_info.InstDir='down'
                        az_correction=1;
                        this_chi_info.sensorSN='13-02D'
                    else
                        % uplooking
                        % is_downcast=0;
                        this_chi_info.InstDir='up'
                        az_correction=-1;
                        this_chi_info.sensorSN='11-23D'
                    end
                    
                else
                    %is_downcast=this_chi_info.is_downcast;
                    az_correction=this_chi_info.az_correction;
                end
                %~
                                
                % carry over chipdo info
                chidat.Info=this_chi_info;                
                chidat.cal=this_chi_info.cal;
                
                if length(chidat.datenum)>1000
                    
                    % Alisn and calibrate data
                    [CTD_24hz chidat]=AlignAndCalibrateChipodCTD(CTD_24hz,chidat,az_correction,cal,1)
                    
                    print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_w_TimeOffset'])
                    
                    % save again, with time-offset and calibration added
                    save(processed_file,'chidat')
                    
                    % check if T calibration is ok
                    clear out2 err pvar
                    %out2=interp1(chidat.datenum,chidat.cal.T1,CTD_24hz.datenum(ginds));
                    out2=interp1(chidat.datenum,chidat.cal.T1,CTD_24hz.datenum);
                    err=out2-CTD_24hz.t1;
                    pvar=100* (1-(nanvar(err)/nanvar(CTD_24hz.t1)) );
                    if pvar<50
                        disp('Warning T calibration not good')
                        fprintf(fileID,' *T calibration not good* ');
                    end
                    
                    %
                    ginds=1:length(CTD_24hz.p);
                    do_timeseries_plot=1;
                    if do_timeseries_plot
                        
                        xls=[min(CTD_24hz.datenum(ginds)) max(CTD_24hz.datenum(ginds))];
                        figure(2);clf
                        agutwocolumn(1)
                        wysiwyg
                        clf
                        
                        h(1)=subplot(411);
                        plot(CTD_24hz.datenum(ginds),CTD_24hz.t1(ginds))
                        hold on
                        plot(chidat.datenum,chidat.cal.T1)
                        plot(chidat.datenum,chidat.cal.T2-.5)
                        ylabel('T [\circ C]')
                        xlim(xls)
                        datetick('x')
                        title(['Cast ' cast_suffix ', ' short_labs{up_down_big} '  ' datestr(time_range(1),'dd-mmm-yyyy HH:MM') '-' datestr(time_range(2),15) ', ' CTD_list(a).name],'interpreter','none')
                        legend('CTD','chi','chi2-.5','location','best')
                        grid on
                        
                        h(2)=subplot(412);
                        plot(CTD_24hz.datenum(ginds),CTD_24hz.p(ginds));
                        ylabel('P [dB]')
                        xlim(xls)
                        datetick('x')
                        grid on
                        
                        h(3)=subplot(413);
                        plot(chidat.datenum,chidat.cal.T1P-.01)
                        hold on
                        plot(chidat.datenum,chidat.cal.T2P+.01)
                        ylabel('dT/dt [K/s]')
                        xlim(xls)
                        ylim(10*[-1 1])
                        datetick('x')
                        grid on
                        
                        h(4)=subplot(414);
                        plot(chidat.datenum,chidat.fspd)
                        ylabel('fallspeed [m/s]')
                        xlim(xls)
                        ylim(3*[-1 1])
                        datetick('x')
                        xlabel(['Time on ' datestr(time_range(1),'dd-mmm-yyyy')])
                        grid on
                        
                        linkaxes(h,'x');
                        orient tall
                        pause(.01)
                        
                        print('-dpng','-r300',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_T_P_dTdz_fspd.png']);
                    end
                    
                    test_cal_coef=0;
                    
                    if test_cal_coef
                        ccal.coef1(a,1:5)=cal.coef.T1;
                        ccal.coef2(a,1:5)=cal.coef.T2;
                        figure(104)
                        plot(ccal.coef1),hold on,plot(ccal.coef2)
                    end
                    
                    
                    %%% now let's do the computation of chi..
                    
                    clear datad_1m datau_1m chi_inds p_max ind_max ctd
                    
                    % load 1-m CTD data.
                    if exist([CTD_path castname(1:end-6) '.mat'],'file')
                        load([CTD_path castname(1:end-6) '.mat']);
                        
                        % find max p from chi (which is really just P from CTD)
                        [p_max,ind_max]=max(chidat.cal.P);
                        
                        %~ break up chi into down and up casts
                        
                        % upcast
                        chi_up=struct();
                        chi_up.datenum=chidat.cal.datenum(ind_max:length(chidat.cal.P));
                        chi_up.P=chidat.cal.P(ind_max:length(chidat.cal.P));
                        chi_up.T1P=chidat.cal.T1P(ind_max:length(chidat.cal.P));
                        chi_up.fspd=chidat.cal.fspd(ind_max:length(chidat.cal.P));
                        chi_up.castdir='up'
                        chi_up.Info=this_chi_info;
                        
                        chi_up.T2P=chidat.cal.T1P(ind_max:length(chidat.cal.P));
                        
                        % downcast
                        chi_dn=struct();
                        chi_dn.datenum=chidat.cal.datenum(1:ind_max);
                        chi_dn.P=chidat.cal.P(1:ind_max);
                        chi_dn.T1P=chidat.cal.T1P(1:ind_max);
                        chi_dn.fspd=chidat.cal.fspd(1:ind_max);
                        chi_dn.castdir='down'
                        chi_dn.Info=this_chi_info;
                        
                        % 2nd sensor on 'big' chipods
                        chi_dn.T2P=chidat.cal.T2P(1:ind_max);
                        %~
                        
                        
                        %~~~
                        % save these data here now ?
                        clear fname_dn fname_up
                        fname_dn=fullfile(chi_processed_path_specific,['cast_' cast_suffix '_' short_labs{up_down_big} '_downcast.mat']);
                        save(fname_dn,'chi_dn')
                        fname_up=fullfile(chi_processed_path_specific,['cast_' cast_suffix '_' short_labs{up_down_big} '_upcast.mat']);
                        save(fname_up,'chi_up')
                        %~~~
                        
                        
                        %~~
                        do_downcast=1
                        do_upcast=1
                        
                        
                        %~~ DOWNCAST
                        if do_downcast==1
                            clear ctd chi_todo_now
                            fallspeed_correction=-1;
                            ctd=datad_1m;                            
                            chi_todo_now=chi_dn;
                            
                            % AP May 11 - replace with function
                            ctd=Compute_N2_dTdz_forChi(ctd)
                            
                            %~~ plot N2 and dTdz
                            doplot=1;
                            if doplot
                                figure(3);clf
                                subplot(121)
                                h20= plot(log10(abs(ctd.N2_20)),ctd.p)
                                hold on
                                h50=plot(log10(abs(ctd.N2_50)),ctd.p)
                                hT=plot(log10(abs(ctd.N2)),ctd.p)
                                xlabel('log_{10}N^2'),ylabel('depth [m]')
                                title(castname,'interpreter','none')
                                grid on
                                axis ij
                                legend([h20 h50 hT],'20m','50m','largest','location','best')
                                
                                subplot(122)
                                plot(log10(abs(ctd.dTdz_20)),ctd.p)
                                hold on
                                plot(log10(abs(ctd.dTdz_50)),ctd.p)
                                plot(log10(abs(ctd.dTdz)),ctd.p)
                                xlabel('log_{10} dT/dz [^{o}Cm^{-1}]'),ylabel('depth [m]')
                                title([chi_todo_now.castdir 'cast'])
                                grid on
                                axis ij
                                
                                % print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_N2_dTdz'])
                                print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_' chi_todo_now.castdir 'cast_N2_dTdz'])
                            end
                            
                            %~~~ now let's do the chi computations:
                            
                            % remove loops in CTD data
                            extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
                            wthresh = 0.4;
                            [datau2,bad_inds] = ctd_rmdepthloops(CTD_24hz,extra_z,wthresh);
                            tmp=ones(size(datau2.p));
                            tmp(bad_inds)=0;
                                                        
                            % new AP
                            chi_todo_now.is_good_data=interp1(datau2.datenum,tmp,chi_todo_now.datenum,'nearest');
                            %
                            figure(55);clf
                            plot(chi_todo_now.datenum,chi_todo_now.P)
                            datetick('x')
                            %                       
                            
                            
                            %%% Now we'll do the main looping through of the data.
                            clear avg nfft todo_inds
                            nfft=128;                            
                            [avg todo_inds]=Prepare_Avg_for_ChiCalc(nfft,chi_todo_now,ctd);
                                                        
                            clear TP fspd good_chi_inds
                            fspd=chi_todo_now.fspd;

                            %~
                            TP=chi_todo_now.T1P;
                            %~
                            
                            good_chi_inds=chi_todo_now.is_good_data;
                            %~ compute chi in overlapping windows
                            avg=ComputeChi_for_CTDprofile(avg,nfft,fspd,TP,good_chi_inds,todo_inds)
                            
%                            ax=CTD_chipod_profile_summary(avg,chi_todo_now)
                            ax=CTD_chipod_profile_summary(avg,chi_todo_now,TP)
                            axes(ax(1))
                            title(['cast ' cast_suffix])
                            axes(ax(2))
                            title([short_labs{up_down_big}],'interpreter','none')
                            
                            print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_' chi_todo_now.castdir 'cast_chi_' short_labs{up_down_big} '_avg_chi_KT_dTdz_V2'])
                            
                            %~~~
                            avg.castname=castname;
                            avg.castdir=chi_todo_now.castdir;
                            avg.Info=this_chi_info
                            ctd.castname=castname;
                            
                            avg.castname=castname;
                            ctd.castname=castname;
                            avg.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                            ctd.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                            
                            chi_processed_path_avg=fullfile(chi_processed_path_specific,'avg');
                            ChkMkDir(chi_processed_path_avg)
                            processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' avg.castdir 'cast_' short_labs{up_down_big} '.mat']);
                            save(processed_file,'avg','ctd')
                            %~~~
                            
                            ngc=find(~isnan(avg.chi1));
                            if numel(ngc)>1
                                fprintf(fileID,'\n Chi computed for downcast ');
                                fprintf(fileID,['\n ' processed_file]);
                            end
                            
                            
                            % for 'big' chipods, do 2nd sensor also
                            if isbig==1
                            clear ctd chi_todo_now
                            fallspeed_correction=-1;
                            ctd=datad_1m;                            
                            chi_todo_now=chi_dn;
                            
                            % AP May 11 - replace with function
                            ctd=Compute_N2_dTdz_forChi(ctd)
                                
                            % remove loops in CTD data
                            extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
                            wthresh = 0.4;
                            [datau2,bad_inds] = ctd_rmdepthloops(CTD_24hz,extra_z,wthresh);
                            tmp=ones(size(datau2.p));
                            tmp(bad_inds)=0;
                                                        
                            % new AP
                            chi_todo_now.is_good_data=interp1(datau2.datenum,tmp,chi_todo_now.datenum,'nearest');
                            %
                            figure(55);clf
                            plot(chi_todo_now.datenum,chi_todo_now.P)
                            datetick('x')
                            %                       
                            
                            
                            %%% Now we'll do the main looping through of the data.
                            clear avg nfft todo_inds
                            nfft=128;                            
                            [avg todo_inds]=Prepare_Avg_for_ChiCalc(nfft,chi_todo_now,ctd);
                                                        
                            clear TP fspd good_chi_inds
                            fspd=chi_todo_now.fspd;

                            %~ Use SECOND sensor
                            TP=chi_todo_now.T2P;
                            %~
                            
                            good_chi_inds=chi_todo_now.is_good_data;
                            %~ compute chi in overlapping windows
                            avg=ComputeChi_for_CTDprofile(avg,nfft,fspd,TP,good_chi_inds,todo_inds)
                            
                            ax=CTD_chipod_profile_summary(avg,chi_todo_now,TP)
                            axes(ax(1))
                            title(['cast ' cast_suffix])
                            axes(ax(2))
                            title([short_labs{up_down_big}],'interpreter','none')
                            
                            print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_' chi_todo_now.castdir 'cast_chi_' short_labs{up_down_big} '_Sens2_avg_chi_KT_dTdz_V2'])
                            
                            %~~~
                            avg.castname=castname;
                            avg.castdir=chi_todo_now.castdir;
                            avg.Info=this_chi_info
                            ctd.castname=castname;
                            
                            avg.castname=castname;
                            ctd.castname=castname;
                            avg.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                            ctd.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                            
                            chi_processed_path_avg=fullfile(chi_processed_path_specific,'avg');
                            ChkMkDir(chi_processed_path_avg)
                            processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' avg.castdir 'cast_' short_labs{up_down_big} '_Sens2.mat']);
                            save(processed_file,'avg','ctd')

                            fprintf(fileID,['\n Chi computed for 2nd sensor on Big \n ' processed_file]);
                            
                            end % isbig
                            
                            
                        end % do_downcast
                        
                        
                        
                        %~ UPCAST
                        if do_upcast==1
                            
                            clear avg ctd chi_todo_now
                            fallspeed_correction=1;
                            ctd=datau_1m;
                            chi_todo_now=chi_up;
                            
                            % AP May 11 - replace with function
                            ctd=Compute_N2_dTdz_forChi(ctd)
                            
                            %~~ plot N2 and dTdz
                            doplot=1;
                            if doplot
                                figure(3);clf
                                subplot(121)
                                h20= plot(log10(abs(ctd.N2_20)),ctd.p)
                                hold on
                                h50=plot(log10(abs(ctd.N2_50)),ctd.p)
                                hT=plot(log10(abs(ctd.N2)),ctd.p)
                                xlabel('log_{10}N^2'),ylabel('depth [m]')
                                title(castname,'interpreter','none')
                                grid on
                                axis ij
                                legend([h20 h50 hT],'20m','50m','largest','location','best')
                                
                                subplot(122)
                                plot(log10(abs(ctd.dTdz_20)),ctd.p)
                                hold on
                                plot(log10(abs(ctd.dTdz_50)),ctd.p)
                                plot(log10(abs(ctd.dTdz)),ctd.p)
                                xlabel('log_{10} dT/dz [^{o}Cm^{-1}]'),ylabel('depth [m]')
                                title([chi_todo_now.castdir 'cast'])
                                grid on
                                axis ij
                                
                                % print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_N2_dTdz'])
                                print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_' chi_todo_now.castdir 'cast_N2_dTdz'])
                            end
                            
                            %~~~ now let's do the chi computations:
                            
                            % remove loops in CTD data
                            extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
                            wthresh = 0.4;
                            [datau2,bad_inds] = ctd_rmdepthloops(CTD_24hz,extra_z,wthresh);
                            tmp=ones(size(datau2.p));
                            tmp(bad_inds)=0;
                            %chidat.cal.is_good_data=interp1(datau2.datenum,tmp,chidat.cal.datenum,'nearest');
                            
                            % new AP
                            chi_todo_now.is_good_data=interp1(datau2.datenum,tmp,chi_todo_now.datenum,'nearest');
                            %
                            figure(55);clf
                            plot(chi_todo_now.datenum,chi_todo_now.P)
                            datetick('x')
                            
                            %%% Now we'll do the main looping through of the data.
                            
                            clear avg nfft todo_inds
                            nfft=128;
                            [avg todo_inds]=Prepare_Avg_for_ChiCalc(nfft,chi_todo_now,ctd);
                                                         
                            clear TP fspd good_chi_inds
                            fspd=chi_todo_now.fspd;
                            TP=chi_todo_now.T1P;
                            good_chi_inds=chi_todo_now.is_good_data;
                            %~ compute chi in overlapping windows
                            %avg=ComputeChi_for_CTDprofile(avg,nfft,chi_todo_now,todo_inds)
                            avg=ComputeChi_for_CTDprofile(avg,nfft,fspd,TP,good_chi_inds,todo_inds)
                            
                            
                            %~~~ Plot profiles of chi, KT, and dTdz
                            ax=CTD_chipod_profile_summary(avg,chi_todo_now,TP)
                           % ax=CTD_chipod_profile_summary(avg,chi_todo_now)
                            axes(ax(1))
                            title(['cast ' cast_suffix])
                            axes(ax(2))
                            title([short_labs{up_down_big}],'interpreter','none')
                            
                            print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_' chi_todo_now.castdir 'cast_chi_' short_labs{up_down_big} '_avg_chi_KT_dTdz_V2'])
                            % print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_chi_' short_labs{up_down_big} '_avg_chi_KT_dTdz_V2'])
                            
                            %~~~
                            
                            % *** save chi_todo_now here also (so we can look
                            % at T1P etc. after)
                            
                            avg.castname=castname;
                            avg.castdir=chi_todo_now.castdir;
                            avg.Info=this_chi_info
                            ctd.castname=castname;
                            avg.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                            ctd.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                            
                            chi_processed_path_avg=fullfile(chi_processed_path_specific,'avg');
                            ChkMkDir(chi_processed_path_avg)
                            processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' avg.castdir 'cast_' short_labs{up_down_big} '.mat']);
                            % processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' short_labs{up_down_big} '.mat']);
                            save(processed_file,'avg','ctd')
                            
                            ngc=find(~isnan(avg.chi1));
                            if numel(ngc)>1
                                fprintf(fileID,'\n Chi computed for upcast ');
                                fprintf(fileID,['\n ' processed_file]);
                            end
                            %~~~~
                            
                            
                            %~ for 'big' chipods, do 2nd sensor also
                            if isbig==1
                            clear ctd chi_todo_now
                            fallspeed_correction=1;
                            ctd=datau_1m;
                            chi_todo_now=chi_up;
                            
                            % AP May 11 - replace with function
                            ctd=Compute_N2_dTdz_forChi(ctd)
                                
                            % remove loops in CTD data
                            extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
                            wthresh = 0.4;
                            [datau2,bad_inds] = ctd_rmdepthloops(CTD_24hz,extra_z,wthresh);
                            tmp=ones(size(datau2.p));
                            tmp(bad_inds)=0;
                                                        
                            % new AP
                            chi_todo_now.is_good_data=interp1(datau2.datenum,tmp,chi_todo_now.datenum,'nearest');
                            %
                            figure(55);clf
                            plot(chi_todo_now.datenum,chi_todo_now.P)
                            datetick('x')
                            %                       
                            
                            
                            %%% Now we'll do the main looping through of the data.
                            clear avg nfft todo_inds
                            nfft=128;                            
                            [avg todo_inds]=Prepare_Avg_for_ChiCalc(nfft,chi_todo_now,ctd);
                                                        
                            clear TP fspd good_chi_inds
                            fspd=chi_todo_now.fspd;

                            %~ Use SECOND sensor
                            TP=chi_todo_now.T2P;
                            %~
                            
                            good_chi_inds=chi_todo_now.is_good_data;
                            %~ compute chi in overlapping windows
                            avg=ComputeChi_for_CTDprofile(avg,nfft,fspd,TP,good_chi_inds,todo_inds)
                            
                            ax=CTD_chipod_profile_summary(avg,chi_todo_now,TP)
                            axes(ax(1))
                            title(['cast ' cast_suffix])
                            axes(ax(2))
                            title([short_labs{up_down_big}],'interpreter','none')
                            
                            print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_' chi_todo_now.castdir 'cast_chi_' short_labs{up_down_big} '_Sens2_avg_chi_KT_dTdz_V2'])
                            
                            %~~~
                            avg.castname=castname;
                            avg.castdir=chi_todo_now.castdir;
                            avg.Info=this_chi_info
                            ctd.castname=castname;
                            
                            avg.castname=castname;
                            ctd.castname=castname;
                            avg.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                            ctd.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                            
                            chi_processed_path_avg=fullfile(chi_processed_path_specific,'avg');
                            ChkMkDir(chi_processed_path_avg)
                            processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' avg.castdir 'cast_' short_labs{up_down_big} '_Sens2.mat']);
                            save(processed_file,'avg','ctd')

                            fprintf(fileID,['\n Chi computed for 2nd sensor on Big \n' processed_file]);
                            
                            end % isbig

                        end % do_upcast
                        
                    end % if we have binned ctd data
                    
                else
                    disp('no good chi data for this profile');
                    fprintf(fileID,' No chi file found ');
                end % if we have good chipod data for this profile
                
            else
                disp('this file already processed')
                fprintf(fileID,' file already exists, skipping ');
            end % already processed
            
        end % each chipod on rosette (up_down_big)
        
    else
        fprintf(fileID,' Cast is a towyo, skipping ');
    end % if not towyo
    
end % each CTD file

delete(hb)

telapse=toc(tstart)
fprintf(fileID,['\n \n Done! \n Processing took ' num2str(telapse/60) ' mins to run']);

%
%%
