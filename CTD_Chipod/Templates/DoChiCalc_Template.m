%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% DoChiCalc_Template.m
%
% Template for script to do chi calculations for CTD-chipod data. This is
% second step of CTD-chipod processing.
%
% '***' indicates where changes need to be made to modify the template for
% specific cruises
%
% *MakeCasts_CTDchipod_Template.m needs to be run first*
%
% The actual iterative chi computation is done with get_chipod_chi.m, which
% is in /mixingsoftware/chipod/compute_chi/.
%
% OUTPUT:
% For each cast, produces and saves a structure 'avg' with results
%
% This script is part of CTD-chipod routines maintained in a github repo at
% https://github.com/OceanMixingGroup/mixingsoftware/tree/master/CTD_Chipod
%
% Dependencies:
% - Compute_N2_dTdz_forChi.m
% - ctd_rmdepthloops.m
% - MakeCtdChiWindows.m
% - fast_psd.m
% - get_chipod_chi.m
%
%----------------
% 10/26/15 - AP - Initial coding
% 01/03/16 - AP - Modify for files saved as separate upcasts/downcasts
% 02/07/16 - AP - Add fmax to specified params
% 02/16/16 - AP - Add option for freq response correction
% 06/08/16 - AP - Clean up and organize
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

%~~~~~~~~~~~~~~~~~~~~~
% ***
this_script_name='DoChiCalc_Template.m'

% *** load/set paths for data
Load_chipod_paths_TestData

% *** load deployment info
Chipod_Deploy_Info_template

% *** Local path for /mixingsoftware repo ***
mixpath='/Users/Andy/Cruises_Research/mixingsoftware/';

savespec=1 % Option to save spectra

%~~ set some params for following calcs
do_T2_big=1;         % do calc for T2 if big chipod
Params.z_smooth=20;  % distance (m) over which to smooth N^2 and dT/dz
Params.nfft=128;     % nfft to use in computing wavenumber spectra
Params.extra_z=2;    % number of extra meters to get rid of due to CTD pressure loops.
Params.wthresh = 0.3;% w threshold for removing CTD pressure loops
Params.TPthresh=1e-6 % minimum TP variance to do calculation
Params.fmax=7;      % max freq to integrate TP spectrum to in chi calc
Params.resp_corr=0;  % correct TP spectra for freq response of thermistor
Params.fc=99;        % cutoff frequency for response correction
Params.gamma=0.2;    % mixing efficiency
%~~
%~~~~~~~~~~~~~~~~~~~~~

% Add paths we need from mixing software
addpath(fullfile(mixpath,'CTD_Chipod','mfiles')) ;
addpath(fullfile(mixpath,'chipod','compute_chi')); % get_chipod_chi.md

tstart=tic;

% use default fc=99 for no correction (to make file paths same)
if Params.resp_corr==0
    Params.fc=99;
end

% Initialize a text file for summary of processing
MakeResultsTextFile_ChiCalc_DoChiCalc

% Choose which sensor to work on
for iSN=1:length(ChiInfo.SNs)
    
    clear whSN
    whSN=ChiInfo.SNs{iSN}
    
    % Specific paths for this sensor
    clear chi_proc_path_specific chi_fig_path savedir_cal
    chi_proc_path_specific=fullfile(chi_proc_path,[whSN]);
    chi_fig_path_specific=fullfile(chi_proc_path_specific,'figures')
    savedir_cal=fullfile(chi_proc_path_specific,'cal')
    
    %##
    fprintf(fileID,['\n processed path: \n ' chi_proc_path  ]);
    %##
    
    % Get list of cast files we have
    clear Flist
    Flist=dir(fullfile(savedir_cal,['*' whSN '*cast.mat']));
    disp(['There are ' num2str(length(Flist)) ' casts to process '])
    
    %##
    fprintf(fileID,['\n There are ' num2str(length(Flist)) ' casts to process \n\n ']);
    %##
    
    if length(Flist)>1
        
        % For each cast, do chi calculations
        for icast=1:length(Flist)
            
            try
                
                %##
                fprintf(fileID,['\n\n--------------------------\n working on ' Flist(icast).name ' (iSN=' num2str(iSN) ', icast=' num2str(icast) ')\n--------------------------']);
                %##
                
                close all
                
                if ChiInfo.(whSN).isbig==1 && do_T2_big==1
                    Ncasestodo=2;
                else
                    Ncasestodo=1;
                end
                
                whfig=6; % # for figure filename, so they can be viewed in order in Finder
                
                for whcasetodo=1:Ncasestodo
                    
                    clear ctd chi_todo_now whsens TP
                    close all
                    switch whcasetodo
                        
                        % do T1
                        case 1
                            whsens='T1';
                            
                            % do T2
                        case 2
                            whsens='T2';
                    end
                    
                    %##
                    fprintf(fileID,['\n----\n  sensor ' whsens]);
                    %##
                    
                    %-- load data
                    clear fname castfile id1
                    castfile=Flist(icast).name;
                    id1=strfind(castfile,['_' whSN]);
                    castStr=castfile(1:id1-1);
                    %fname=fullfile(savedir_cal,[castStr '_' whSN '_' castdir 'cast.mat']);
                    fname=fullfile(savedir_cal,castfile)
                    load(fname)
                    %---
                    
                    clear TP ctd
                    TP=C.([whsens 'P']);
                    
                    % compute background N^2 and dT/dz for chi calculations
                    clear ctd
                    ctd=Compute_N2_dTdz_forChi(C.ctd.bin,Params.z_smooth);
                    
                    % remove loops in CTD data
                    clear datau2 bad_inds tmp
                    [datau2,bad_inds] = ctd_rmdepthloops(C.ctd.raw,Params.extra_z,Params.wthresh);
                    tmp=ones(size(datau2.p));
                    tmp(bad_inds)=0;
                    
                    %chi_todo_now.is_good_data=interp1(datau2.datenum,tmp,chi_todo_now.datenum,'nearest');
                    C.is_good_data=interp1(datau2.datenum,tmp,C.datenum,'nearest');
                    
                    clear ib_loop Nloop
                    ib_loop=find(C.is_good_data==0);
                    Nloop=length(ib_loop);
                    %##
                    fprintf(fileID,['\n  ' num2str(round(Nloop/length(C.datenum)*100)) ' percent of points removed for depth loops ']);
                    %##
                    disp(['\n  ' num2str(round(Nloop/length(C.datenum)*100)) ' percent of points removed for depth loops ']);
                    
                    figure(55);clf
                    plot(C.datenum,C.P)
                    xlabel(['Time on ' datestr(floor(nanmin(C.datenum)))])
                    ylabel('Pressure')
                    title([castStr '_' C.castdir],'interpreter','none')
                    axis ij
                    datetick('x')
                    grid on
                    %
                    
                    % Find segments of good data (where no glitches AND
                    % no depth loops)
                    clear idg b Nsegs
                    TP(ib_loop)=nan;
                    
                    % Get windows for chi calculation
                    clear todo_inds Nwindows
                    [todo_inds,Nwindows]=MakeCtdChiWindows(TP,Params.nfft);
                    
                    % Make 'avg' structure for the processed data
                    clear avg
                    avg=struct();
                    avg.Params=Params;
                    tfields={'datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
                        'chi1','eps1','KT1','TP1var'};
                    for n=1:length(tfields)
                        avg.(tfields{n})=NaN*ones(Nwindows,1);
                    end
                    
                    avg.samplerate=1./nanmedian(diff(C.datenum))/24/3600;
                    
                    % Get average time, pressure, and fallspeed in each window
                    for iwind=1:Nwindows
                        clear inds
                        inds=todo_inds(iwind,1) : todo_inds(iwind,2);
                        avg.datenum(iwind)=nanmean(C.datenum(inds));
                        avg.P(iwind)=nanmean(C.P(inds));
                        avg.fspd(iwind)=nanmean(C.fspd(inds));
                    end
                    
                    % make empty arrays for spectra
                    if savespec==1
                        % observed wavenumber
                        ks=nan*ones(Nwindows,Params.nfft /2);
                        % observed wave# spectra
                        kspec=nan*ones(Nwindows,Params.nfft /2);
                        % fit wavenumber
                        kks=nan*ones(Nwindows,56);
                        % fit wave# spectra
                        kkspec=nan*ones(Nwindows,56);
                        % observed frequency spectra
                        tpspec=nan*ones(Nwindows,Params.nfft /2);
                        %~
                    end
                    
                    %~~ Plot histogram of avg.P to see how many good windows we have in
                    % each 10m bin
                    figure
                    hi=histogram(avg.P,0:10:nanmax(avg.P));
                    hi.Orientation='Horizontal';axis ij;
                    ylabel('P [db]')
                    xlabel('# good data windows')
                    title([whSN ' cast ' castStr ' - ' C.castdir 'cast'],'interpreter','none')
                    print('-dpng',fullfile(chi_fig_path_specific,[whSN '_' castStr '_Fig' num2str(whfig) '_' C.castdir 'cast_chi_' whsens '_avgPhist']))
                    whfig=whfig+1;
                    
                    % Get N2, dTdz for each window
                    good_inds=find(~isnan(ctd.p));
                    % Interpolate ctd data to same pressures as chipod
                    avg.N2=interp1(ctd.p(good_inds),ctd.N2(good_inds),avg.P);
                    avg.dTdz=interp1(ctd.p(good_inds),ctd.dTdz(good_inds),avg.P);
                    avg.T=interp1(ctd.p(good_inds),ctd.t1(good_inds),avg.P);
                    avg.S=interp1(ctd.p(good_inds),ctd.s1(good_inds),avg.P);
                    
                    % Note sw_visc not included in newer versions of sw?
                    avg.nu=sw_visc_ctdchi(avg.S,avg.T,avg.P);
                    avg.tdif=sw_tdif_ctdchi(avg.S,avg.T,avg.P);
                    
                    % Loop through each window and do the chi
                    % computation
                    for iwind=1:Nwindows
                        clear inds
                        inds=todo_inds(iwind,1) : todo_inds(iwind,2);
                        
                        % Integrate dT/dt spectrum
                        clear tp_power freq
                        [tp_power,freq]=fast_psd(TP(inds),Params.nfft,avg.samplerate);
                        avg.TP1var(iwind)=sum(tp_power)*nanmean(diff(freq));
                        
                        if avg.TP1var(iwind)>Params.TPthresh
                            
                            % Apply filter correction for sensor response
                            if Params.resp_corr==1
                                trans_fcn=0;
                                trans_fcn1=0;
                                thermistor_filter_order=2;
                                thermistor_cutoff_frequency=Params.fc;
                                analog_filter_order=4;
                                analog_filter_freq=50;
                                tp_power=invert_filt(freq,invert_filt(freq,tp_power,thermistor_filter_order, ...
                                    thermistor_cutoff_frequency),analog_filter_order,analog_filter_freq);
                            end
                            
                            % Compute chi using iterative procedure
                            [chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,abs(avg.fspd(iwind)),avg.nu(iwind),...
                                avg.tdif(iwind),avg.dTdz(iwind),'nsqr',avg.N2(iwind),'fmax',Params.fmax,'gamma',Params.gamma);
                            %            'doplots',1 for plots
                            avg.chi1(iwind)=chi1(1);
                            avg.eps1(iwind)=epsil1(1);
                            avg.KT1(iwind)=0.5*chi1(1)/avg.dTdz(iwind)^2;
                            
                            if savespec==1
                                % 02/17/16 - AP - save spectra
                                
                                fspec=freq;
                                tpspec(iwind,:)=tp_power;
                                
                                % observed wavenumber
                                ks(iwind,:)=k;
                                
                                % observed spectra
                                kspec(iwind,:)=spec;
                                % best-fit theoreticl spectra
                                kkspec(iwind,:)=speck;
                                
                                if ~isnan(kk)
                                    % theoretical fit wavenumber
                                    kks(iwind,:)=kk;
                                end
                            end
                            
                        end % if T1Pvar>threshold
                        
                    end % windows
                    
                    
                    % Plot summary figure
                    ax=CTD_chipod_profile_summary(avg,C,TP);
                    axes(ax(1))
                    title(['cast ' castStr],'interpreter','none')
                    axes(ax(2))
                    title([whSN],'interpreter','none')
                    axes(ax(3))
                    title(['Sensor ' whsens])
                    print('-dpng',fullfile(chi_fig_path_specific,[whSN '_' castStr '_Fig' num2str(whfig) '_' C.castdir 'cast_chi_' whsens '_avg_chi_KT_dTdz']))
                    whfig=whfig+1;
                    %~~~
                    
                    if savespec==1
                        %~
                        avg.tpspec=tpspec;
                        avg.kspec=kspec;
                        avg.kkspec=kkspec;
                        avg.ks=ks;
                        avg.kks=kks;
                        avg.fspec=fspec;
                    end
                    
                    castname=castStr;
                    
                    % Add lat/lon to avg structure
                    avg.lat=nanmean(ctd.lat);
                    avg.lon=nanmean(ctd.lon);
                    avg.castname=castname;
                    avg.castdir=C.castdir;
                    avg.Info=C.Info;
                    avg.MakeInfo=['Made ' datestr(now) ' w/ ' this_script_name ];
                    
                    ctd.castname=castname;
                    ctd.MakeInfo=['Made ' datestr(now) ' w/ ' this_script_name ];
                    
                    chi_proc_path_avg=fullfile(chi_proc_path_specific,'avg',...
                        ['zsm' num2str(Params.z_smooth) 'm_fmax' num2str(Params.fmax) 'Hz_respcorr' num2str(Params.resp_corr) '_fc_' num2str(Params.fc) 'hz_gamma' num2str(Params.gamma*100)] )
                    
                    ChkMkDir(chi_proc_path_avg)
                    processed_file=fullfile(chi_proc_path_avg,['avg_' castStr '_' avg.castdir 'cast_' whSN '_' whsens '.mat']);
                    save(processed_file,'avg','ctd')
                    %~~~
                    
                    ngc=find(~isnan(avg.chi1));
                    if numel(ngc)>1
                        %##
                        fprintf(fileID,['\n Chi computed for ' C.castdir 'cast, sensor ' whsens]);
                        fprintf(fileID,['\n ' processed_file '\n']);
                        %##
                    end
                    
                end % up/down, T1/T2
                
            catch
                disp(['Error on ' Flist(icast).name])
                %##
                fprintf(fileID,['\n Error on ' Flist(icast).name]);
                %##
            end % Try
            
        end % icast
        
    end % if we have casts to process
    
end % iSN (different chipods)


telapse=toc(tstart)

%##
fprintf(fileID,['\n \n Done! \n Processing took ' num2str(telapse/60) ' mins to run']);
%##
%%