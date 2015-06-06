%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% process_chipod_script_towyo_New.m
%
% Modified version of process_chipod_script_AP.m designed to handle towyos
% (specifically for T-Tide, hopefully will apply to other cruises also).
%
% Everything up to line 293 is the same. At that point, the script looks
% for the 1m CTD files and doesn't find it because the ctd data was instead
% split into a bunch of separate profiles. This version of script is
% modified to deal with that and loop through those 'split' files.
%
% 26 Mar. 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all ; clc

cd /Users/Andy/Cruises_Research/mixingsoftware/CTD_Chipod

% makelen.m in /general is needed
addpath /Users/Andy/Cruises_Research/mixingsoftware/general

%% Set Paths etc.

% ~~ Paths for Andy's laptop
% Path where ctd data are located (already processed into mat files). There
% should be a folder in it called /24Hz
CTD_path='/Users/Andy/Dropbox/TTIDE_OBSERVATIONS/scienceparty_share/TTIDE-RR1501/data/ctd_processed/'
% Path where chipod data are located
chi_data_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/'
% path where processed chipod
chi_processed_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/Processed/';
% path to save figures to
fig_path=[chi_processed_path 'figures/'];
ChkMkDir(fig_path)


% Make a list of all ctd files
CTD_list=dir([CTD_path  '24hz/' '*_leg1_*.mat']);

% make a text file to print a summary of results to
if exist(fullfile(chi_processed_path,'TowyoResults.txt'),'file')
    %    delete(fullfile(chi_processed_path,'TowyoResults.txt'))
end
fileID= fopen(fullfile(chi_processed_path,'TowyoResults.txt'),'a');

fprintf(fileID,['\n Created ' datestr(now) '\n'])
fprintf(fileID,[CTD_path '\n'])
fprintf(fileID,[chi_data_path '\n'])
fprintf(fileID,[chi_processed_path '\n'])
fprintf(fileID,[fig_path '\n'])

% we loop through and do processing for each ctd file
hb=waitbar(0,'Looping through ctd files')

% ind for TTide towyos: 61-68, 102-117,120-131, 151-206

for a=1:length(CTD_list)
    waitbar(a/length(CTD_list),hb)
    
    clear castname tlim time_range cast_suffix_tmp cast_suffix data2
    castname=CTD_list(a).name;
    
    fprintf(fileID,['\n ~~~' castname '~~~\n']);
    
    %load CTD profile
    load([CTD_path '24hz/' castname]);
    
    % 24Hz data loaded here is in a structure 'data2'
    CTD_24hz=data2;clear data2
    CTD_24hz.ctd_file=castname;
    
    % create a CTD time:
    % Sometimes the time needs to be converted from computer time into matlab (datenum?) time.
    % Time will be converted when CTD time is more than 5 years bigger than now.
    % JRM
    tlim=now+5*365;
    if CTD_24hz.time > tlim
        tmp=linspace(CTD_24hz.time(1),CTD_24hz.time(end),length(CTD_24hz.time));
        CTD_24hz.datenum=tmp'/24/3600+datenum([1970 1 1 0 0 0]);
    end
    
    clear tlim tmp
    time_range=[min(CTD_24hz.datenum) max(CTD_24hz.datenum)];
    cast_suffix_tmp=CTD_list(a).name; % Cast # may be different than file #. JRM
    cast_suffix=cast_suffix_tmp(end-8:end-6);
    
    
    % check if this is a towyo (only do towyos)
    %if ~exist(fullfile(CTD_path,[] '_leg1_' cast_suffix '_split*.mat']
    clear splitlist
    splitlist=dir([CTD_path '*' cast_suffix '_split*.mat']);
    if size(splitlist,1)>1
        
        % Info for chipods deployed on CTD is entered here (SN, up/down, etc.).
        % Might run into issues if chipods are switched out during cruise...
        
        % load chipod info
        addpath /Users/Andy/Cruises_Research/Tasmania/
        Chipod_Deploy_Info_TTIDE
        
        for up_down_big=1:2
            % load chipod data
%             short_labs={'up_1012','down_1013','big'};
%             big_labs={'Ti UpLooker','Ti DownLooker','Unit 1002'};
            
            % *** edit this info for your cruise/instruments ***
            short_labs={'SN1012','SN1013','SN1002','SN102','SN1010'};
            %            big_labs={'Ti UpLooker','Ti DownLooker','Unit 1002','Ti Downlooker','1010'};
            
            switch up_down_big
                case 1
                    whSN='SN1012'; % uplooker
                case 2;
                    whSN='SN1013' ;% downlooker
                case 3
                    whSN='SN1002'; % this is a big chipod
                case 4
                    whSN='SN102';
                case 5
                    whSN='SN1010';
            end
            
            this_chi_info=ChiInfo.(whSN);
            clear chi_path az_correction suffix isbig cal is_downcast
            chi_path=fullfile(chi_data_path,this_chi_info.loggerSN);
            suffix=this_chi_info.suffix;
            isbig=this_chi_info.isbig;
            cal=this_chi_info.cal;
            
            fprintf(fileID,[ ' \n \n ' short_labs{up_down_big} ]);
            
            d.time_range=datestr(time_range); % Time range of cast
            
            chi_processed_path_specific=fullfile(chi_processed_path,['chi_' short_labs{up_down_big} ]);
            ChkMkDir(chi_processed_path_specific)
            
            fig_path_specific=fullfile(fig_path,['chi_' short_labs{up_down_big} ]);
            ChkMkDir(fig_path_specific)
            
            % filename for processed chipod data (will check if already exists)
            processed_file=fullfile(chi_processed_path_specific,['cast_' cast_suffix '_' short_labs{up_down_big} '.mat']);
            
            %
            
            %~~
            if  1%~exist(processed_file,'file')
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
                %~~
                if length(chidat.datenum)>1000
                    
                    % Alisn and calibrate data
                    [CTD_24hz chidat]=AlignAndCalibrateChipodCTD(CTD_24hz,chidat,az_correction,1);
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
                    
                    %~~~~
                    do_timeseries_plot=1;
                    if do_timeseries_plot
                        
                        xls=[min(CTD_24hz.datenum) max(CTD_24hz.datenum)];
                        figure(2);clf
                        agutwocolumn(1)
                        wysiwyg
                        clf
                        
                        h(1)=subplot(411);
                        plot(CTD_24hz.datenum,CTD_24hz.t1)
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
                        plot(CTD_24hz.datenum,CTD_24hz.p);
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
                    %~~~~
                    
                    %%% now let's do the computation of chi..
                    
                    % need to make list of split filenames and figure out how many
                    % there are
                    SplitFiles=dir([CTD_path '*_leg1_' cast_suffix '_split*.mat'])
                    Nsplit=length(SplitFiles)
                    fprintf(fileID,['\n There are ' num2str(Nsplit) ' split files \n'])
                    %
                    CTD_24hz_All_towyo=CTD_24hz;
                    cal_All_towyo=cal;
                    
                    pause
                    
                    for whsplit=1:Nsplit
                        
                        clear splitfilename
                        splitfilename=SplitFiles(whsplit).name;
                        
                        fprintf(fileID,['\n ' splitfilename ])
                        
                        %
                        if exist(fullfile(CTD_path,splitfilename),'file') && strcmp(splitfilename(1),'t')
                            disp('Loading split file')
                            load(fullfile(CTD_path,splitfilename))
                            
                            clear split_range idt_split idt_split_cal
                            split_range=[nanmin(datad_1m.datenum) nanmax(datau_1m.datenum)];
                            idt_split=isin(CTD_24hz.datenum,split_range);
                            idt_split_cal=isin(cal.datenum,split_range);
                            
                            if ~isempty(idt_split_cal)
                                
                                clear p_max ind_max
                                %                [p_max,ind_max]=max(cal.P);% this sisn't going to work...
                                [p_max,ind_max]=nanmax(cal.P(idt_split_cal));% this sisn't going to work...
                                
                                figure(77);clf
                                plot(cal.datenum,cal.P)
                                hold on
                                plot(cal.datenum(idt_split_cal),cal.P(idt_split_cal))
                                plot(cal.datenum(idt_split_cal(ind_max)),cal.P(idt_split_cal(ind_max)),'o')
                                axis ij
                                datetick('x')
                                ylabel('P [db]')
                                title(splitfilename,'interpreter','none')
                                %                pause
                                
                                if is_downcast
                                    fallspeed_correction=-1;
                                    ctd=datad_1m;
                                    %                    chi_inds=[1:ind_max];
                                    chi_inds=[1:idt_split_cal(ind_max)];
                                    sort_dir='descend';
                                else
                                    fallspeed_correction=1;
                                    ctd=datau_1m;
                                    %                    chi_inds=[ind_max:length(cal.P)];
                                    chi_inds=[idt_split_cal(ind_max):idt_split_cal(end)];
                                    sort_dir='ascend';
                                end
                                ctd.s1=interp_missing_data(ctd.s1,100);
                                ctd.t1=interp_missing_data(ctd.t1,100);
                                smooth_len=20;
                                [bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); % JRM removed "vort,p_ave" from outputs
                                ctd.N2=abs(conv2(bfrq,ones(smooth_len,1)/smooth_len,'same')); % smooth once
                                ctd.N2=conv2(ctd.N2,ones(smooth_len,1)/smooth_len,'same'); % smooth twice
                                ctd.N2_20=ctd.N2([1:end end]);
                                tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
                                ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(smooth_len,1)/smooth_len,'same'))./diff(ctd.p)];
                                ctd.dTdz_20=conv2(ctd.dTdz,ones(smooth_len,1)/smooth_len,'same');
                                
                                smooth_len=50;
                                [bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); %JRM removed "vort,p_ave" from outputs
                                ctd.N2=abs(conv2(bfrq,ones(smooth_len,1)/smooth_len,'same')); % smooth once
                                ctd.N2=conv2(ctd.N2,ones(smooth_len,1)/smooth_len,'same'); % smooth twice
                                ctd.N2_50=ctd.N2([1:end end]);
                                tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
                                ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(smooth_len,1)/smooth_len,'same'))./diff(ctd.p)];
                                ctd.dTdz_50=conv2(ctd.dTdz,ones(smooth_len,1)/smooth_len,'same');
                                
                                ctd.dTdz=max(ctd.dTdz_50,ctd.dTdz_20);
                                ctd.N2=max(ctd.N2_50,ctd.N2_20);
                                
                                
                                doplot=1;
                                if doplot
                                    disp('plotting N and dTdz')
                                    figure(3);clf
                                    subplot(121)
                                    plot(log10(abs(ctd.N2)),ctd.p),
                                    xlabel('log_{10}N^2'),ylabel('depth [m]')
                                    title(castname,'interpreter','none')
                                    grid on
                                    axis ij
                                    
                                    subplot(122)
                                    plot(log10(abs(ctd.dTdz)),ctd.p) % ,log10(abs(ctd.dTdz2)),ctd.p,log10(abs(ctd.dTdz3)),ctd.p)
                                    xlabel('dTdz [^{o}Cm^{-1}]'),ylabel('depth [m]')
                                    grid on
                                    axis ij
                                    
                                    print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_N2_dTdz'])
                                end
                                % now let's do the chi computations:
                                
                                
                                % remove loops in CTD data
                                disp('Removing loops from CTD data')
                                extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
                                wthresh = 0.4;
                                
                                %** This was an issue - rmloops meant to handle single
                                %profile only - AP
                                % [datau2,bad_inds] = ctd_rmdepthloops(data2,extra_z,wthresh);
                                %
                                % instead, make a new temporary 'data2split' structure that
                                % has just the indices for this time period
                                clear data2split
                                dnames=fieldnames(data2);
                                data2split=struct();
                                for whfield=1:length(dnames)
                                    data2split.(dnames{whfield})=CTD_24hz.(dnames{whfield})(idt_split);
                                end
                                %
                                
                                [datau2,bad_inds] = ctd_rmdepthloops(data2split,extra_z,wthresh);
                                tmp=ones(size(datau2.p));
                                tmp(bad_inds)=0;
                                cal.is_good_data=interp1(datau2.datenum,tmp,cal.datenum,'nearest');
                                %
                                
                                %%% Now we'll do the main looping through of the data.
                                clear avg
                                nfft=128;
                                todo_inds=chi_inds(1:nfft/2:(length(chi_inds)-nfft))';
                                tfields={'datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
                                    'chi1','eps1','chi2','eps2','KT1','KT2','TP1var','TP2var'};
                                for n=1:length(tfields)
                                    avg.(tfields{n})=NaN*ones(size(todo_inds));
                                end
                                avg.datenum=cal.datenum(todo_inds+(nfft/2)); % This is the mid-value of the bin
                                avg.P=cal.P(todo_inds+(nfft/2));
                                good_inds=find(~isnan(ctd.p));
                                avg.N2=interp1(ctd.p(good_inds),ctd.N2(good_inds),avg.P);
                                avg.dTdz=interp1(ctd.p(good_inds),ctd.dTdz(good_inds),avg.P);
                                avg.T=interp1(ctd.p(good_inds),ctd.t1(good_inds),avg.P);
                                avg.S=interp1(ctd.p(good_inds),ctd.s1(good_inds),avg.P);
                                
                                % note sw_visc not included in newer versions of sw?
                                addpath  /Users/Andy/Cruises_Research/mixingsoftware/seawater
                                % avg.nu=sw_visc(avg.S,avg.T,avg.P);
                                avg.nu=sw_visc_ctdchi(avg.S,avg.T,avg.P);
                                
                                % avg.tdif=sw_tdif(avg.S,avg.T,avg.P);
                                avg.tdif=sw_tdif_ctdchi(avg.S,avg.T,avg.P);
                                
                                avg.samplerate=1./nanmedian(diff(cal.datenum))/24/3600;
                                
                                h = waitbar(0,['Computing chi for cast ' cast_suffix ' split ' num2str(whsplit)]);
                                for n=1:length(todo_inds)
                                    inds=todo_inds(n)-1+[1:nfft];
                                    if all(cal.is_good_data(inds)==1) %
                                        avg.fspd(n)=mean(cal.fspd(inds));
                                        
                                        [tp_power,freq]=fast_psd(cal.T1P(inds),nfft,avg.samplerate);
                                        avg.TP1var(n)=sum(tp_power)*nanmean(diff(freq));
                                        if avg.TP1var(n)>1e-4
                                            fixit=0;
                                            if fixit
                                                trans_fcn=0;
                                                trans_fcn1=0;
                                                thermistor_filter_order=2;
                                                thermistor_cutoff_frequency=32;
                                                analog_filter_order=4;
                                                analog_filter_freq=50;
                                                
                                                tp_power=invert_filt(freq,invert_filt(freq,tp_power,thermistor_filter_order, ...
                                                    thermistor_cutoff_frequency),analog_filter_order,analog_filter_freq);
                                            end
                                            
                                            %try
                                            addpath /Users/Andy/Cruises_Research/mixingsoftware/marlcham/ % for integrate.m
                                            %[chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,avg.fspd(n),avg.nu(n),...
                                            %   avg.tdif(n),avg.dTdz(n),'nsqr',avg.N2(n));
                                            
                                            [chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,abs(avg.fspd(n)),avg.nu(n),...
                                                avg.tdif(n),avg.dTdz(n),'nsqr',avg.N2(n));
                                            %catch
                                            %	chi1=NaN;
                                            %	epsil1=NaN;
                                            %end
                                            
                                            avg.chi1(n)=chi1(1);
                                            avg.eps1(n)=epsil1(1);
                                            avg.KT1(n)=0.5*chi1(1)/avg.dTdz(n)^2;
                                            
                                            
                                        else
                                            %  disp('fail1')
                                        end
                                    else
                                        %disp('fail')
                                    end
                                    
                                    
                                end
                                
                                
                                
                                delete(h)
                                
                                figure(4);clf
                                
                                subplot(131)
                                plot(log10(avg.chi1),avg.P),axis ij
                                xlabel('log_{10}(avg chi)')
                                ylabel('Depth [m]')
                                grid on
                                
                                subplot(132)
                                plot(log10(avg.KT1),avg.P),axis ij
                                xlabel('log_{10}(avg Kt1)')
                                grid on
                                
                                subplot(133)
                                plot(log10(abs(avg.dTdz)),avg.P),axis ij
                                grid on
                                xlabel('log_{10}(avg dTdz)')
                                print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_split' num2str(whsplit) '_avg_chi_KT_dTdz'])
                                
                                chi_processed_path_avg=fullfile(chi_processed_path_specific,'avg');
                                ChkMkDir(chi_processed_path_avg)
                                
                                %                processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' short_labs{up_down_big} '.mat']);
                                processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' short_labs{up_down_big} '_split' num2str(whsplit) '.mat']);
                                
                                save(processed_file,'avg','ctd')
                                
                                ngc=find(~isnan(avg.chi1));
                                
                                if numel(ngc)>1
                                    fprintf(fileID,' Chi computed \n')
                                end
                                
                            else
                                fprintf(fileID,' no chi data for this time period\n')
                            end % if there is good chipod data
                            
                        else
                            fprintf(fileID,' no ctd split file found\n')
                        end % if there exists a split file
                        
                    end % whsplit
                    
                else
                    %disp('no good chi data for this profile')
                    fprintf(fileID,' No chi file found \n')
                end % if we have good chipod data for this profile
                %catch
                %2end
                
            end % file exists
            
            
        end % each chipod on rosette (up_down_big)
        
    else
        fprintf(fileID,'Not a towyo \n')
    end % check if towyo
    
end % each CTD file

delete(hb)

%%



