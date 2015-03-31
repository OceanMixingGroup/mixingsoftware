%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% process_chipod_script_AP.m
%
% Script to do CTD-chipod processing. 
%
% This script is part of CTD_Chipod software folder in the the mixingsoftware github repo.
% For latest version, download/sync the mixingsoftware github repo at
% https://github.com/OceanMixingGroup/mixingsoftware
%
% Before running:
% -This script assumes that CTD data has been processed into mat files and
% put into folders in some kind of standard form (with ctd_proc2??).
% -Chipod data files need to be downloaded and saved as well.
%
% Instructions to run:
% 1) Modify paths for your computer and cruise
% 2) Modify chipod info for your cruise
% 3) Run!
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
% -As of 31 Mar 2015 , this runs for Ttide data. Still need to test for
%  other cruises.
%
% Started with 'process_chipod_script_june_ttide_V2.m' on 24 Mar 2015 and
% modified from there. A. Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all ; clc

tstart=tic;

%~~~~ Modify these paths for your cruise/computer ~~~~
cd /Users/Andy/Cruises_Research/mixingsoftware/CTD_Chipod
addpath /Users/Andy/Cruises_Research/mixingsoftware/general % makelen.m in /general is needed
addpath /Users/Andy/Cruises_Research/mixingsoftware/marlcham/ % for integrate.m
% ~~ Paths for Andy's laptop
% Path where ctd data are located (already processed into mat files). There
% should be a folder in it called /24Hz
CTD_path='/Users/Andy/Dropbox/TTIDE_OBSERVATIONS/scienceparty_share/TTIDE-RR1501/data/ctd_processed/'
% Path where chipod data are located
chi_data_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/'
% path where processed chipod data will be saved
chi_processed_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/Processed/';
% path to save figures to
fig_path=[chi_processed_path 'figures/'];
ChkMkDir(fig_path)
% ~~~~~~~


% Make a list of all ctd files
CTD_list=dir([CTD_path  '24hz/' '*_leg1_*.mat']);

% make a text file to print a summary of results to
if exist(fullfile(chi_processed_path,'Results.txt'),'file')
    delete(fullfile(chi_processed_path,'Results.txt'))
end
fileID= fopen(fullfile(chi_processed_path,'Results.txt'),'a');
fprintf(fileID,['Created ' datestr(now) '\n']);
fprintf(fileID,'CTD path \n');
fprintf(fileID,[CTD_path '\n']);
fprintf(fileID,'Chipod data path \n');
fprintf(fileID,[chi_data_path '\n']);
fprintf(fileID,'Chipod processed path \n');
fprintf(fileID,[chi_processed_path '\n']);
fprintf(fileID,'figure path \n');
fprintf(fileID,[fig_path '\n \n']);

% we loop through and do processing for each ctd file
hb=waitbar(0,'Looping through ctd files')
for a=1:length(CTD_list)
    waitbar(a/length(CTD_list),hb)
    
    clear castname tlim time_range cast_suffix_tmp cast_suffix data2
    castname=CTD_list(a).name;
    
    fprintf(fileID,[' \n \n ~' castname ])
    
    %load CTD profile
    load([CTD_path '24hz/' castname])
    
    % create a CTD time:
    % Sometimes the time needs to be converted from computer time into matlab (datenum?) time.
    % Time will be converted when CTD time is more than 5 years bigger than now.
    % JRM
    tlim=now+5*365;
    if data2.time > tlim
        % jen didn't save us a real 24 hz time.... so create timeseries. JRM
        % from data record
        %disp('test!!!!!!!!!!')
        tmp=linspace(data2.time(1),data2.time(end),length(data2.time));
        data2.datenum=tmp'/24/3600+datenum([1970 1 1 0 0 0]);
    end
    
    clear tlim tmp
    time_range=[min(data2.datenum) max(data2.datenum)];
    cast_suffix_tmp=CTD_list(a).name; % Cast # may be different than file #. JRM
    cast_suffix=cast_suffix_tmp(end-8:end-6);
    
    
    % check if this is a towyo, if so skip for now
    clear splitlist
    splitlist=dir([CTD_path '*' cast_suffix '_split*.mat']);
    if size(splitlist,1)==0
                
        %~~~ Info for chipods deployed on CTD is entered here ~~
        %~~~ This needs to be modified for each cruise ~~~
         
        for up_down_big=1:2
            % load chipod data
            short_labs={'up_1012','down_1013','big','down_1010'};
            big_labs={'Ti UpLooker','Ti DownLooker','Unit 1002','Ti Downlooker'};
            
            switch up_down_big
                case 1
                    % Specify uplooker path JRM
                    chi_path=fullfile(chi_data_path,'1012')
                    az_correction=-1; % -1 if the Ti case is pointed down or up
                    suffix='A1012';
                    isbig=0;
                    cal.coef.T1P=0.097;
                    is_downcast=0;
                case 2
                    % Specify downlooker JRM
                    chi_path=fullfile(chi_data_path,'1013')
                    az_correction=1;
                    suffix='A1013';
                    isbig=0;
                    cal.coef.T1P=0.097;
                    is_downcast=1;
                case 3 % For now not doing big Chi
                    chi_path='../data/A16S/Chipod_CTD/';az_correction=1;
                    suffix='1002';
                    isbig=1;
                    cal.coef.T1P=0.105;
                    cal.coef.T2P=0.105;
                    is_downcast=0;
                case 4
                    % another downlooker
                    chi_path=fullfile(chi_data_path,'1010')
                    az_correction=1;
                    suffix='A1010';
                    isbig=0;
                    cal.coef.T1P=0.097;
                    is_downcast=1;
            end
            
            fprintf(fileID,[ ' \n ' short_labs{up_down_big} ])
            
            d.time_range=datestr(time_range); % Time range of cast
            
            chi_processed_path_specific=fullfile(chi_processed_path,['chi_' short_labs{up_down_big} ])
            ChkMkDir(chi_processed_path_specific)
            
            fig_path_specific=fullfile(fig_path,['chi_' short_labs{up_down_big} ])
            ChkMkDir(fig_path_specific)
            
            % filename for processed chipod data (will check if already exists)
            % processed_file=fullfile(chi_processed_path,['chi_' short_labs{up_down_big} ],['cast_' cast_suffix '_' short_labs{up_down_big} '.mat']);
            processed_file=fullfile(chi_processed_path_specific,['cast_' cast_suffix '_' short_labs{up_down_big} '.mat']);
            
            % Load chipod data
            if  0 % exist(processed_file,'file') %commented for now becasue some files were made but contain no data
                load(processed_file)
            else
                disp('loading chipod data')
                addpath /Users/Andy/Cruises_Research/mixingsoftware/adcp/ % need for mergefields_jn.m in load_chipod_data
                chidat=load_chipod_data(chi_path,time_range,suffix,isbig);
                save(processed_file,'chidat')
            end
            
            if length(chidat.datenum)>1000
                %%% First we'll compute fallspeed from dp/dz and compare this to chipod's
                %%% AZ to get the time offset.
                
                fprintf(fileID,' Found good chi file ')
                
                % low-passed p
                data2.p_lp=conv2(medfilt1(data2.p),hanning(30)/sum(hanning(30)),'same');
                data2.dpdt=gradient(data2.p_lp,nanmedian(diff(data2.datenum*86400)));
                data2.dpdt(data2.dpdt>10)=mean(data2.dpdt); % JRM added to remove large spike spikes in dpdt
                
                % high-passed dpdt
                data2.dpdt_hp=data2.dpdt-conv2(data2.dpdt,hanning(750)/sum(hanning(750)),'same');
                data2.dpdt_hp(abs(data2.dpdt_hp)>2)=mean(data2.dpdt_hp); % JRM added to remove large spike spikes in dpdt_hp
                
                %~ AP - compute chipod w by integrating z-accelertion?
                %chidat.AZ_hp=filter_series(chidat.AX,100,'h.02');
                tmp=az_correction*9.8*(chidat.AZ-median(chidat.AZ)); tmp(abs(tmp)>10)=0;
                tmp2=tmp-conv2(tmp,hanning(3000)/sum(hanning(3000)),'same');
                w_from_chipod=cumsum(tmp2*nanmedian(diff(chidat.datenum*86400)));
                
                % here's the plot:
                figure(1);clf
                ax1= subplot(211)
                plot(data2.datenum,data2.dpdt_hp,'b',chidat.datenum,w_from_chipod,'r'),hold on
                legend('ctd dp/dt','w_{chi}','orientation','horizontal','location','best')
                title([castname],'interpreter','none')                
                ylabel('w [m/s]')
                datetick('x')
                grid on
                                  
                % find profile inds (ctd profile 'starts' at 10m )
                ginds=get_profile_inds(data2.p,10);
                
                % find time offset between ctd and chipod data (by matching w)
                offset=TimeOffset(data2.datenum(ginds),data2.dpdt_hp(ginds),chidat.datenum,w_from_chipod);
                
                % apply correction to chipod time
                chidat.datenum=chidat.datenum+offset; % JRM TimeOffset is not working right ??                
                chidat.time_offset_correction_used=offset;
                chidat.fspd=interp1(data2.datenum,-data2.dpdt,chidat.datenum);
                
                ax2=subplot(212)
                plot(data2.datenum,data2.dpdt_hp,'b',chidat.datenum,w_from_chipod,'g')
                legend('ctd dp/dt','corrected w_{chi}','orientation','horizontal','location','best')
                grid on
                datetick('x')
                ylabel('w [m/s]')
                
                linkaxes([ax1 ax2])
                print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_w_TimeOffset'])                
                
                %%% Now we'll calibrate T by comparison to the CTD.
                cal.datenum=chidat.datenum;
                cal.P=interp1(data2.datenum,data2.p_lp,chidat.datenum);
                cal.T_CTD=interp1(data2.datenum,data2.t1,chidat.datenum);
                cal.fspd=chidat.fspd;
                
                [cal.coef.T1,cal.T1]=get_T_calibration(data2.datenum(ginds),data2.t1(ginds),chidat.datenum,chidat.T1);
                
                % check if T calibration is ok
                clear out2 err pvar
                out2=interp1(chidat.datenum,cal.T1,data2.datenum(ginds));
                err=out2-data2.t1(ginds);
                pvar=100* (1-(nanvar(err)/nanvar(data2.t1(ginds))) );
                if pvar<50
                    disp('Warning T calibration not good')
                    fprintf(fileID,' *T calibration not good* ')
                end
                %
                
                %%% And now we apply our calibration for DTdt.
                cal.T1P=calibrate_chipod_dtdt(chidat.T1P,cal.coef.T1P,chidat.T1,cal.coef.T1);
                
                test_dtdt=0; %%% this does a digital differentiation to determine whether the differentiator time constant is correct.
                if test_dtdt
                    dt=median(diff(chidat.datenum))*3600*24;
                    cal.dTdt_dig=[0 ; diff(cal.T1)/dt];
                    oset=min(chidat.datenum);
                    plot(chidat.datenum-oset,cal.dTdt_dig,chidat.datenum-oset,cal.T1P);
                    paus, ax=axis
                    ginds2=find((chidat.datenum-oset)>ax(1) & (chidat.datenum-oset)<ax(2));
                    [p,f]=fast_psd(cal.T1P(ginds2),256,100);
                    [p2,f]=fast_psd(cal.dTdt_dig(ginds2),256,100);
                    figure(4)
                    loglog(f,p2,f,p);
                end
                
                
                if isbig
                    % big chipods have 2 sensors?
                    [cal.coef.T2,cal.T2]=get_T_calibration(data2.datenum(ginds),data2.t1(ginds),chidat.datenum,chidat.T2);
                    cal.T2P=calibrate_chipod_dtdt(chidat.T2P,cal.coef.T2P,chidat.T2,cal.coef.T2);
                else
                    cal.T2=cal.T1;
                    cal.T2P=cal.T1P;
                end
                
                
                do_timeseries_plot=1;
                if do_timeseries_plot
                    
                    xls=[min(data2.datenum(ginds)) max(data2.datenum(ginds))];
                    figure(2);clf
                    agutwocolumn(1)
                    wysiwyg
                    clf
                    
                    h(1)=subplot(411);
                    plot(data2.datenum(ginds),data2.t1(ginds),chidat.datenum,cal.T1,chidat.datenum,cal.T2-.5)
                    ylabel('T [\circ C]')
                    xlim(xls)
                    datetick('x')
                    title(['Cast ' cast_suffix ', ' big_labs{up_down_big} '  ' datestr(time_range(1),'dd-mmm-yyyy HH:MM') '-' datestr(time_range(2),15) ', ' CTD_list(a).name],'interpreter','none')
                    legend('CTD','chi','chi2-.5','location','best')
                    grid on
                    
                    h(2)=subplot(412);
                    plot(data2.datenum(ginds),data2.p(ginds));
                    ylabel('P [dB]')
                    xlim(xls)
                    datetick('x')
                    grid on
                    
                    h(3)=subplot(413);
                    plot(chidat.datenum,cal.T1P-.01,chidat.datenum,cal.T2P+.01)
                    ylabel('dTdt [K/s]')
                    xlim(xls)
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
                
                % this gives us 1-m CTD data.
                
                
                if exist([CTD_path castname(1:end-6) '.mat'],'file')
                    load([CTD_path castname(1:end-6) '.mat']);
                    [p_max,ind_max]=max(cal.P);
                    if is_downcast
                        fallspeed_correction=-1;
                        ctd=datad_1m;
                        chi_inds=[1:ind_max];
                        sort_dir='descend';
                    else
                        fallspeed_correction=1;
                        ctd=datau_1m;
                        chi_inds=[ind_max:length(cal.P)];
                        sort_dir='ascend';
                    end
                    
                    % this plot for diagnostics to see if we are picking
                    % right half of profile (up/down)
%                     figure(99);clf
%                     plot(chidat.datenum,chidat.T1P)
%                     hold on
%                     plot(chidat.datenum(chi_inds),chidat.T1P(chi_inds))
                    
                    ctd.s1=interp_missing_data(ctd.s1,100);
                    ctd.t1=interp_missing_data(ctd.t1,100);
                    smooth_len=20;
                    
                    % compute N^2 from 1m ctd data with 20 smoothing
                    [bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); % JRM removed "vort,p_ave" from outputs
                    ctd.N2=abs(conv2(bfrq,ones(smooth_len,1)/smooth_len,'same')); % smooth once
                    ctd.N2=conv2(ctd.N2,ones(smooth_len,1)/smooth_len,'same'); % smooth twice
                    ctd.N2_20=ctd.N2([1:end end]);
                    
                    % compute dTdz from 1m ctd data with 20 smoothing
                    tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
                    ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(smooth_len,1)/smooth_len,'same'))./diff(ctd.p)];
                    ctd.dTdz_20=conv2(ctd.dTdz,ones(smooth_len,1)/smooth_len,'same');
                    
                    % compute N^2 from 1m ctd data with 50 smoothing
                    smooth_len=50;
                    [bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); %JRM removed "vort,p_ave" from outputs
                    ctd.N2=abs(conv2(bfrq,ones(smooth_len,1)/smooth_len,'same')); % smooth once
                    ctd.N2=conv2(ctd.N2,ones(smooth_len,1)/smooth_len,'same'); % smooth twice
                    ctd.N2_50=ctd.N2([1:end end]);
                    
                    % compute dTdz from 1m ctd data with 50 smoothing
                    tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
                    ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(smooth_len,1)/smooth_len,'same'))./diff(ctd.p)];
                    ctd.dTdz_50=conv2(ctd.dTdz,ones(smooth_len,1)/smooth_len,'same');
                    
                    % pick max dTdz and N^2 from these two?
                    ctd.dTdz=max(ctd.dTdz_50,ctd.dTdz_20);
                    ctd.N2=max(ctd.N2_50,ctd.N2_20);                    
                    
                    %~~ plot N2 and dTdz
                    doplot=1;
                    if doplot
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
                    
                    
                    %~~~ now let's do the chi computations:
                                        
                    % remove loops in CTD data
                    extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
                    wthresh = 0.4;
                    [datau2,bad_inds] = ctd_rmdepthloops(data2,extra_z,wthresh);
                    tmp=ones(size(datau2.p));
                    tmp(bad_inds)=0;
                    cal.is_good_data=interp1(datau2.datenum,tmp,cal.datenum,'nearest');
                    %
                    
                    %%% Now we'll do the main looping through of the data.
                    clear avg
                    nfft=128;
                    todo_inds=chi_inds(1:nfft/2:(length(chi_inds)-nfft))';
                    %                plot(chidat.datenum(todo_inds),chidat.T1P(todo_inds))
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
                    
                    h = waitbar(0,['Computing chi for cast ' cast_suffix]);
                    for n=1:length(todo_inds)
                        clear inds
                        inds=todo_inds(n)-1+[1:nfft];
                        
                        if all(cal.is_good_data(inds)==1)
                            avg.fspd(n)=mean(cal.fspd(inds));
                            
                            [tp_power,freq]=fast_psd(cal.T1P(inds),nfft,avg.samplerate);
                            avg.TP1var(n)=sum(tp_power)*nanmean(diff(freq));
                        
                            if avg.TP1var(n)>1e-4
                                
                                % not sure what this is for...
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
                                                                
                                % [chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,avg.fspd(n),avg.nu(n),...
                                %  avg.tdif(n),avg.dTdz(n),'nsqr',avg.N2(n));
                                %  % AP 27 Mar - fspd needs to be positive?
                                %  wasn't working for downcasts before with
                                %    above function call
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
                                %disp('fail2')                                
                            end
                        else
                           % disp('fail1')
                        end
                        
                        if ~mod(n,10)
                            waitbar(n/length(todo_inds),h);
                        end
                        
                    end
                    delete(h)
                    
                    %~~ Plot chi, KT, and dTdz
                    figure(4);clf
                    
                    subplot(131)
                    plot(log10(avg.chi1),avg.P),axis ij
                    xlabel('log_{10}(avg chi)')
                    ylabel('Depth [m]')
                    grid on
                    title(['cast ' cast_suffix])                    
                    
                    subplot(132)
                    plot(log10(avg.KT1),avg.P),axis ij
                    xlabel('log_{10}(avg Kt1)')
                    grid on
                    title([short_labs{up_down_big}],'interpreter','none')
                    
                    subplot(133)
                    plot(log10(abs(avg.dTdz)),avg.P),axis ij
                    grid on
                    xlabel('log_{10}(avg dTdz)')
                    print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_chi_' short_labs{up_down_big} '_avg_chi_KT_dTdz'])
                    %~~
                    
                    avg.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                    ctd.MakeInfo=['Made ' datestr(now) ' w/ process_chipod_script_AP.m']
                    
                    chi_processed_path_avg=fullfile(chi_processed_path_specific,'avg');
                    ChkMkDir(chi_processed_path_avg)
                    %processed_file=[chi_processed_path 'chi_' short_labs{up_down_big} '/avg/avg_' ...
                    %cast_suffix '_' short_labs{up_down_big} '.mat'];
                    processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' short_labs{up_down_big} '.mat']);                    
                    save(processed_file,'avg','ctd')
                    
                    ngc=find(~isnan(avg.chi1));
                    if numel(ngc)>1
                        fprintf(fileID,'Chi computed ')
                    end
                end
                
            else
                disp('no good chi data for this profile');
                fprintf(fileID,' No chi file found ')
            end % if we have good chipod data for this profile
            
        end % each chipod on rosette (up_down_big)
       
    else
        fprintf(fileID,' Cast is a towyo, skipping ')
    end % if not towyo 
    
end % each CTD file

delete(hb)

telapse=toc(tstart)
fprintf(fileID,['\n Processing took ' num2str(telapse/60) ' mins to run'])

%
%
%%
