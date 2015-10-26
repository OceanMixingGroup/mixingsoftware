%~~~~~~~~~~~~~~~~~~~~~~
%
% DoChiCalc_Template.m
%
% Do chi calculations; this is new format where this is done in a separate
% script from the script that breaks data into casts and calibrates etc.
% (See MakeCasts_CTDchipod_Template.m)
%
%------------
% 10/26/15 - AP - Initial coding
%~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

this_script_name='DoChiCalc_IWISE11_V2.m'

% load/set paths for data
Load_chipod_paths_TestData

% choose which sensor to work on (if multiple, would have loop here)
%whSN='SN600'

% specific paths for this sensor
chi_proc_path_specific=fullfile(chi_proc_path,[whSN]);
chi_fig_path_specific=fullfile(chi_proc_path_specific,'figures')
savedir_cal=fullfile(chi_proc_path_specific,'cal')

% get list of cast files we have
Flist=dir(fullfile(savedir_cal,['*' whSN '.mat']))
disp(['There are ' num2str(length(Flist)) ' casts to process '])

% load deployment info for this sensor
Chipod_Deploy_Info_template

%isbig=ChiInfo.SN600.isbig;

% set some params for following calcs
%~~
do_T2_big=1; % do calc for T2 if big chipod
% define some parameters that are the same for up/down and
% T1/T2:
Params.z_smooth=20
Params.nfft=128;
Params.extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
Params.wthresh = 0.3;

% for each cast, do chi calculations
for icast=1:length(Flist)
    
    try
    close all
    
    if isbig==1 && do_T2_big==1
        Ncasestodo=4;
    else
        Ncasestodo=2;
    end
    
    whfig=6; % # for figure filename, so they can be viewed in order in Finder
    
    for whcasetodo=[3 4] %T1 bad, do only T2 1:Ncasestodo
        
        clear ctd chi_todo_now whsens TP
        close all
        switch whcasetodo
            
            case 1 % downcast T1
                clear ctd chi_todo_now
                % ~~ Choose which dT/dt to use (for mini
                % chipods, only T1P. For big, we will do T1P
                % and T2P).
                whsens='T1';
                castdir='down'
                disp('Doing T1 downcast')
            case 2 % upcast T1
                clear avg ctd chi_todo_now
                whsens='T1';
                castdir='up'
                disp('Doing T1 upcast')
            case 3 %downcast T2
                clear ctd chi_todo_now
                whsens='T2';
                castdir='down'
                disp('Doing T2 downcast')
            case 4 % upcast T2
                clear avg ctd chi_todo_now
                whsens='T2';
                castdir='up'
                disp('Doing T2 upcast')
        end
        
        %
        %-- load appropriate data for this case
        
        clear fname castfile id1
        castfile=Flist(icast).name
        id1=strfind(castfile,['_' whSN])
        cast_suffix=castfile(1:id1-1)
        fname=fullfile(savedir_cal,[cast_suffix '_' whSN '_' castdir 'cast.mat']);
        load(fname)
        
       %---
        
        clear TP ctd
        TP=C.([whsens 'P']);
        
        % compute background N^2 and dT/dz for chi calculations
        clear ctd
        ctd=Compute_N2_dTdz_forChi(C.ctd.bin,Params.z_smooth);
        
        %~~~ now let's do the chi computations:
        
        % remove loops in CTD data
        clear datau2 bad_inds tmp
        [datau2,bad_inds] = ctd_rmdepthloops(C.ctd.raw,Params.extra_z,Params.wthresh);
        tmp=ones(size(datau2.p));
        tmp(bad_inds)=0;
        
        %    chi_todo_now.is_good_data=interp1(datau2.datenum,tmp,chi_todo_now.datenum,'nearest');
        C.is_good_data=interp1(datau2.datenum,tmp,C.datenum,'nearest');
        
        clear ib_loop Nloop
        ib_loop=find(C.is_good_data==0);
        Nloop=length(ib_loop);
        %    fprintf(fileID,['\n  ' num2str(round(Nloop/length(C.datenum)*100)) ' percent of points removed for depth loops ']);
        disp(['\n  ' num2str(round(Nloop/length(C.datenum)*100)) ' percent of points removed for depth loops ']);
        
        %
        figure(55);clf
        plot(C.datenum,C.P)
        xlabel(['Time on ' datestr(floor(nanmin(C.datenum)))])
        ylabel('Pressure')
        title([cast_suffix '_' C.castdir],'interpreter','none')
        axis ij
        datetick('x')
        grid on
        %
        
        %------
        %~~~ ~ New
        
        % find segments of good data (where no glitches AND
        % no depth loops)
        clear idg b Nsegs
        TP(ib_loop)=nan;
        
        %-- get windows for chi calculation
        clear todo_inds Nwindows
        [todo_inds,Nwindows]=MakeCtdChiWindows(TP,Params.nfft);
        
        %~ make 'avg' structure for the processed data
        avg=struct();
        avg.Params=Params;
        tfields={'datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
            'chi1','eps1','KT1','TP1var'};
        for n=1:length(tfields)
            avg.(tfields{n})=NaN*ones(Nwindows,1);
        end
        
        avg.samplerate=1./nanmedian(diff(C.datenum))/24/3600;
        
        % get average time, pressure, and fallspeed in each window
        for iwind=1:Nwindows
            clear inds
            inds=todo_inds(iwind,1) : todo_inds(iwind,2);
            avg.datenum(iwind)=nanmean(C.datenum(inds));
            avg.P(iwind)=nanmean(C.P(inds));
            avg.fspd(iwind)=nanmean(C.fspd(inds));
        end
        
        %~~ plot histogram of avg.P to see how many good windows we have in
        %each 10m bin
        figure
        hi=histogram(avg.P,0:10:nanmax(avg.P));
        hi.Orientation='Horizontal';axis ij;
        ylabel('P [db]')
        xlabel('# good data windows')
        title([whSN ' cast ' cast_suffix ' - ' C.castdir 'cast'],'interpreter','none')
        print('-dpng',fullfile(chi_fig_path_specific,[whSN '_' cast_suffix '_Fig' num2str(whfig) '_' C.castdir 'cast_chi_' whsens '_avgPhist']))
        whfig=whfig+1
        
        % get N2, dTdz for each window
        good_inds=find(~isnan(ctd.p));
        % interpolate ctd data to same pressures as chipod
        avg.N2=interp1(ctd.p(good_inds),ctd.N2(good_inds),avg.P);
        avg.dTdz=interp1(ctd.p(good_inds),ctd.dTdz(good_inds),avg.P);
        avg.T=interp1(ctd.p(good_inds),ctd.t1(good_inds),avg.P);
        avg.S=interp1(ctd.p(good_inds),ctd.s1(good_inds),avg.P);
        
        % note sw_visc not included in newer versions of sw?
        avg.nu=sw_visc_ctdchi(avg.S,avg.T,avg.P);
        avg.tdif=sw_tdif_ctdchi(avg.S,avg.T,avg.P);
        
        % loop through each window and do the chi
        % computation
        for iwind=1:Nwindows
            clear inds
            inds=todo_inds(iwind,1) : todo_inds(iwind,2);
            
            % integrate dT/dt spectrum
            [tp_power,freq]=fast_psd(TP(inds),Params.nfft,avg.samplerate);
            avg.TP1var(iwind)=sum(tp_power)*nanmean(diff(freq));
            
            if avg.TP1var(iwind)>1e-4
                
                % apply filter correction for sensor response?
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
                
                % compute chi using iterative procedure
                [chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,abs(avg.fspd(iwind)),avg.nu(iwind),...
                    avg.tdif(iwind),avg.dTdz(iwind),'nsqr',avg.N2(iwind));
                %            'doplots',1 for plots
                avg.chi1(iwind)=chi1(1);
                avg.eps1(iwind)=epsil1(1);
                avg.KT1(iwind)=0.5*chi1(1)/avg.dTdz(iwind)^2;
                
            end
            
        end % windows
        
        
        %~ plot summary figure
        ax=CTD_chipod_profile_summary(avg,C,TP);
        axes(ax(1))
        title(['cast ' cast_suffix],'interpreter','none')
        axes(ax(2))
        title([whSN],'interpreter','none')
        axes(ax(3))
        title(['Sensor ' whsens])
        print('-dpng',fullfile(chi_fig_path_specific,[whSN '_' cast_suffix '_Fig' num2str(whfig) '_' C.castdir 'cast_chi_' whsens '_avg_chi_KT_dTdz']))
        whfig=whfig+1;
        
        %~~~
        
        % add lat/lon to avg structure
        avg.lat=nanmean(ctd.lat);
        avg.lon=nanmean(ctd.lon);
        
        castname=cast_suffix;
        
        avg.castname=castname;
        avg.castdir=C.castdir;
        avg.Info=C.Info;% this_chi_info;
        ctd.castname=castname;
        
        avg.castname=castname;
        ctd.castname=castname;
        avg.MakeInfo=['Made ' datestr(now) ' w/ ' this_script_name ];
        ctd.MakeInfo=['Made ' datestr(now) ' w/ ' this_script_name ];
        
        chi_proc_path_avg=fullfile(chi_proc_path_specific,'avg');
        ChkMkDir(chi_proc_path_avg)
        processed_file=fullfile(chi_proc_path_avg,['avg_' cast_suffix '_' avg.castdir 'cast_' whSN '_' whsens '.mat']);
        save(processed_file,'avg','ctd')
        %~~~
        
        %         ngc=find(~isnan(avg.chi1));
        %         if numel(ngc)>1
        %             fprintf(fileID,['\n Chi computed for ' C.castdir 'cast, sensor ' whsens]);
        %             fprintf(fileID,['\n ' processed_file]);
        %         end
        
    end % up/down, T1/T2
    
    catch
    end
    
end % cast #
%%