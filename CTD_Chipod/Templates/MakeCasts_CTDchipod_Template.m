%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% MakeCasts_CTDchipod_Template.m
%
% This is the 1st part of the CTD-chipod processing. Here we find raw chipod
% data for each cast, align the data and calibrate etc.. . A mat file is saved
% for each upcast and downcast.
%
% Before running this you will need the Load_Chipod _paths... and
% Chipod_Deploy_Info.... m-files.
%
% The next step in processing is DoChiCalc_Template.m
%
% '***' indicates where changes need to be made to modify the template for
% specific cruises
%
% Output files are saved under /chi_proc_path/
%
% This script is part of CTD-chipod routines maintained in a github repo at
% https://github.com/OceanMixingGroup/mixingsoftware/tree/master/CTD_Chipod
%
% Dependencies:
% - MakeResultsTextFile.m
% - load_chipod_data.m
% - AlignChipodCTD.m
% - CalibrateChipodCTD.m
% - ChiPodTimeseriesPlot.m
%
%---------------------
% 10/26/15 - A.Pickering - Initial coding
% 06/08/16 - AP - Updating...
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all ; clc

% Should only need to edit info below
%~~~~~~~~~~~~~~~~~~~~~~~~

% ***
this_script_name='ProcessCTDchipod_Template.m'

% *** Local path for /mixingsoftware repo ***
mixpath='/Users/Andy/Cruises_Research/mixingsoftware/';

% *** Load paths for CTD and chipod data
Load_chipod_paths_TestData

% *** Load chipod deployment info
Chipod_Deploy_Info_template

% optional list of bad chi files to ignore
%bad_file_list_

%~~~~~~~~~~~~~~~~~~~~~~~~

% Start a timer
tstart=tic;

% Add paths we will need
addpath(fullfile(mixpath,'CTD_Chipod'));
addpath(fullfile(mixpath,'CTD_Chipod','mfiles'));
addpath(fullfile(mixpath,'chipod'))    ;% raw_load_chipod.m
addpath(fullfile(mixpath,'general'))   ;% makelen.m in /general is needed
addpath(fullfile(mixpath,'marlcham'))  ;% for integrate.m
addpath(fullfile(mixpath,'adcp'))      ;% need for mergefields_jn.m in load_chipod_data

% Make a list of all ctd files we have
CTD_list=dir(fullfile(CTD_out_dir_24hz,['*' ChiInfo.CastString '*.mat*']));
disp(['There are ' num2str(length(CTD_list)) ' CTD casts to process in ' CTD_out_dir_24hz])

% Make a text file to print a summary of results to
MakeResultsTextFile

% Make a structure to save processing summary info

if ~exist(fullfile(BaseDir,'Data','proc_info.mat'),'file')
    
    proc_info=struct;
    proc_info.Project=ChiInfo.Project;
    proc_info.SNs=ChiInfo.SNs;
    proc_info.icast=nan*ones(1,length(CTD_list));
    proc_info.Name=cell(1,length(CTD_list));
    proc_info.duration=nan*ones(1,length(CTD_list));
    proc_info.MaxP=nan*ones(1,length(CTD_list));
    proc_info.Prange=nan*ones(1,length(CTD_list));
    proc_info.drange=nan*ones(length(CTD_list),2);
    proc_info.lon=nan*ones(1,length(CTD_list));
    proc_info.lat=nan*ones(1,length(CTD_list));
    
    empt_struct.toffset=nan*ones(1,length(CTD_list));
    empt_struct.IsChiData=nan*ones(1,length(CTD_list));
    empt_struct.T1cal=nan*ones(1,length(CTD_list));
    empt_struct.T2cal=nan*ones(1,length(CTD_list));
    
    for iSN=1:length(ChiInfo.SNs)
        proc_info.(ChiInfo.SNs{iSN})=empt_struct ;
    end
    
else
    disp('proc_info already exists, will load and add to it')
    load(fullfile(BaseDir,'Data','proc_info.mat'))
end

% Loop through each ctd file
hb=waitbar(0,'Looping through ctd files');

for icast=1:length(CTD_list)
    
    close all
    clear castname tlim time_range cast_suffix_tmp cast_suffix CTD_24hz
    
    % Update waitbar
    waitbar(icast/length(CTD_list),hb)
    
    % CTD castname we are working with
    castname=CTD_list(icast).name
    
    %##
    fprintf(fileID,[ '\n\n\n ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' ]);
    fprintf(fileID,[' \n \n CTD-file: ' castname ' (icast=' num2str(icast) ')' ]);
    %##
    
    %load 24hz CTD profile
    load(fullfile(CTD_out_dir_24hz, castname))
    CTD_24hz=data2;clear data2
    CTD_24hz.ctd_file=castname;
    
    % Sometimes the 24hz ctd time needs to be fixed
    tlim=now+5*365;
    if CTD_24hz.time > tlim
        tmp=linspace(CTD_24hz.time(1),CTD_24hz.time(end),length(CTD_24hz.time));
        CTD_24hz.datenum=tmp'/24/3600+datenum([1970 1 1 0 0 0]);
    end
    
    % Time range of CTD cast
    clear tlim tmp
    time_range=[min(CTD_24hz.datenum) max(CTD_24hz.datenum)];
    d.time_range=datestr(time_range);
    
    % Name of CTD cast to use (assumes 24Hz CTD cast files end in '_24hz.mat'
    castStr=castname(1:end-9)
    
    proc_info.icast(icast)=icast;
    proc_info.Name(icast)={castStr};
    proc_info.MaxP(icast)=nanmax(CTD_24hz.p);
    proc_info.duration(icast)=nanmax(CTD_24hz.datenum)-nanmin(CTD_24hz.datenum);
    proc_info.Prange(icast)=range(CTD_24hz.p);
    proc_info.drange(icast,:)=time_range;
    
    proc_info.lon(icast)=nanmean(CTD_24hz.lon);
    proc_info.lat(icast)=nanmean(CTD_24hz.lat);
    
    
    %-- Loop through each chipod SN --
    for iSN=1:length(ChiInfo.SNs)
        
        close all
        clear whSN this_chi_info chi_path az_correction suffix isbig cal is_downcast
        
        whSN=ChiInfo.SNs{iSN};
        this_chi_info=ChiInfo.(whSN);
        
        % Full path to raw data for this chipod
        chi_path=fullfile(chi_data_path,['SN' this_chi_info.loggerSN]);
        suffix=this_chi_info.suffix;
        
        isbig=this_chi_info.isbig;
        cal=this_chi_info.cal;
        
        %##
        fprintf(fileID,[ ' \n\n ---------' ]);
        fprintf(fileID,[ ' \n ' whSN ]);
        fprintf(fileID,[ ' \n ---------\n' ]);
        %##
        
        % Get specific paths for this chipod
        
        chi_proc_path_specific=fullfile(chi_proc_path,[whSN]);
        ChkMkDir(chi_proc_path_specific)
        
        chi_fig_path_specific=fullfile(chi_proc_path_specific,'figures')
        ChkMkDir(chi_fig_path_specific)
        
        % Plot the raw CTD data
        ax=PlotRawCTD(CTD_24hz)
        print('-dpng',fullfile(chi_fig_path_specific,[whSN '_' castStr '_Fig0_RawCTD']))
        
        try
            
            %~~ Load chipod data
            if  1 %~exist(processed_file,'file')
                %load(processed_file)
                % else
                disp('loading chipod data')
                
                % Find and load chipod data for this time range
                chidat=load_chipod_data(chi_path,time_range,suffix,isbig,1);
                
                % If we have enough good chipod data, continue
                if length(chidat.datenum)>1000
                    
                    ab=get(gcf,'Children');
                    axes(ab(end));
                    title([whSN ' - ' castname ' - Raw Data '],'interpreter','none')
                    
                    % Save plot
                    print('-dpng',fullfile(chi_fig_path_specific,[whSN '_' castStr '_Fig1_RawChipodTS']))
                    
                    chidat.time_range=time_range;
                    chidat.castname=castname;
                    
                    savedir_cast=fullfile(chi_proc_path_specific,'cast')
                    ChkMkDir(savedir_cast)
                    save(fullfile(savedir_cast,[castStr '_' whSN '.mat']),'chidat')
                    
                    % Carry over chipod info
                    chidat.Info=this_chi_info;
                    chidat.cal=this_chi_info.cal;
                    az_correction=this_chi_info.az_correction;
                    
                    % *** Might need something like this here
                    %                     if strcmp(whSN,'SN2020')
                    %                         A1=chidat.AX;
                    %                         A2=chidat.AZ;
                    %                         rmfield(chidat,{'AX','AZ'})
                    %                         chidat.AX=A2;
                    %                         chidat.AZ=A1;
                    %                     end
                    
                    proc_info.(whSN).IsChiData(icast)=1;
                    
                    % Align w/ CTD timeseries
                    [CTD_24hz chidat]=AlignChipodCTD(CTD_24hz,chidat,az_correction,1);
                    print('-dpng',fullfile(chi_fig_path_specific,[whSN '_' castStr '_Fig2_w_TimeOffset']))
                    
                    % Zoom in and plot again to check alignment
                    xlim([nanmin(chidat.datenum)+range(chidat.datenum)/5 (nanmin(chidat.datenum)+range(chidat.datenum)/5 +300/86400)])
                    print('-dpng',fullfile(chi_fig_path_specific,[whSN '_' castStr '_Fig3_w_TimeOffset_Zoom']))
                    
                    % Calibrate T and dT/dt
                    [CTD_24hz chidat]=CalibrateChipodCTD(CTD_24hz,chidat,az_correction,1);
                    print('-dpng',fullfile(chi_fig_path_specific,[whSN '_' castStr '_Fig4_dTdtSpectraCheck']))
                    
                    % Save again, with time-offset and calibration added
                    savedir_cal=fullfile(chi_proc_path_specific,'cal')
                    ChkMkDir(savedir_cal)
                    % processed_file=fullfile(chi_proc_path_specific,['cast_' cast_suffix '_' whSN '.mat'])
                    %save(fullfile(savedir_cal,[castStr '_' whSN '.mat']),'chidat')
                    
                    % Check if T1 calibration is ok
                    clear out2 err pvar cal_good_T1 cal_good_T2
                    out2=interp1(chidat.datenum,chidat.cal.T1,CTD_24hz.datenum);
                    err=out2-CTD_24hz.t1;
                    pvar=100* (1-(nanvar(err)/nanvar(CTD_24hz.t1)) );
                    if pvar<90
                        cal_good_T1=0;
                        disp('Warning T calibration not good')
                        %##
                        fprintf(fileID,' *T1 calibration not good* ');
                        %##
                    else
                        cal_good_T1=1;
                    end
                    
                    % Check if T2 calibration is ok
                    if this_chi_info.isbig==1
                        % check if T2 calibration is ok
                        clear out2 err pvar
                        out2=interp1(chidat.datenum,chidat.cal.T2,CTD_24hz.datenum);
                        err=out2-CTD_24hz.t1;
                        pvar=100* (1-(nanvar(err)/nanvar(CTD_24hz.t1)) );
                        if pvar<90
                            cal_good_T2=0;
                            disp('Warning T2 calibration not good')
                            %##
                            fprintf(fileID,' *T2 calibration not good* ');
                            %##
                        else
                            cal_good_T2=1;
                        end
                        proc_info.(whSN).T2cal(icast)=cal_good_T2;
                    else
                        cal_good_T2=nan;
                    end % isbig
                    
                    proc_info.(whSN).T1cal(icast)=cal_good_T1;
                    proc_info.(whSN).toffset(icast)=chidat.time_offset_correction_used*86400; % in sec
                    
                    %~~~~
                    do_timeseries_plot=1;
                    if do_timeseries_plot
                        h=ChiPodTimeseriesPlot(CTD_24hz,chidat);
                        axes(h(1))
                        title([castStr ', ' whSN '  ' datestr(time_range(1),'dd-mmm-yyyy HH:MM') '-' datestr(time_range(2),15) ', ' CTD_list(icast).name],'interpreter','none')
                        axes(h(end))
                        xlabel(['Time on ' datestr(time_range(1),'dd-mmm-yyyy')])
                        print('-dpng','-r300',fullfile(chi_fig_path_specific,[whSN '_' castStr '_Fig5_T_P_dTdz_fspd.png']));
                    end
                    %~~~~
                    
                    clear datad_1m datau_1m chi_inds p_max ind_max ctd
                    
                    if cal_good_T1==1 || cal_good_T2==1
                        
                        if exist(fullfile(CTD_out_dir_bin,[ castStr '.mat']),'file')
                            load(fullfile(CTD_out_dir_bin,[ castStr '.mat']));
                            % find max p from chi (which is really just P from CTD)
                            [p_max,ind_max]=max(chidat.cal.P);
                            
                            %~ break up chi into down and up casts
                            
                            % upcast
                            chi_up=struct();
                            chi_up.datenum=chidat.cal.datenum(ind_max:length(chidat.cal.P));
                            chi_up.P=chidat.cal.P(ind_max:length(chidat.cal.P));
                            chi_up.T1P=chidat.cal.T1P(ind_max:length(chidat.cal.P));
                            chi_up.fspd=chidat.cal.fspd(ind_max:length(chidat.cal.P));
                            chi_up.castdir='up';
                            chi_up.Info=this_chi_info;
                            if this_chi_info.isbig
                                % 2nd sensor on 'big' chipods
                                chi_up.T2P=chidat.cal.T2P(ind_max:length(chidat.cal.P));
                            end
                            chi_up.ctd.bin=datau_1m;
                            chi_up.ctd.raw=CTD_24hz;
                            chi_uo.time_offset_correction_used=chidat.time_offset_correction_used;
                            
                            % downcast
                            chi_dn=struct();
                            chi_dn.datenum=chidat.cal.datenum(1:ind_max);
                            chi_dn.P=chidat.cal.P(1:ind_max);
                            chi_dn.T1P=chidat.cal.T1P(1:ind_max);
                            chi_dn.fspd=chidat.cal.fspd(1:ind_max);
                            chi_dn.castdir='down';
                            chi_dn.Info=this_chi_info;
                            if this_chi_info.isbig
                                % 2nd sensor on 'big' chipods
                                chi_dn.T2P=chidat.cal.T2P(1:ind_max);
                            end
                            chi_dn.ctd.bin=datad_1m;
                            chi_dn.ctd.raw=CTD_24hz;
                            chi_dn.time_offset_correction_used=chidat.time_offset_correction_used;
                            %~
                            
                            %~~~
                            % save these data here now
                            clear fname_dn fname_up
                            fname_dn=fullfile(savedir_cal,[castStr '_' whSN '_downcast.mat']);
                            clear C;C=chi_dn;
                            save(fname_dn,'C')
                            
                            fname_up=fullfile(savedir_cal,[castStr '_' whSN '_upcast.mat']);
                            clear C;C=chi_up;
                            save(fname_up,'C')
                            %~~~
                            
                            %##
                            fprintf(fileID,'\n success ');
                            %##
                            
                        else
                            %##
                            fprintf(fileID,' No binned CTD data for this cast ');
                            %##
                            disp('No binned CTD data for this cast')
                            
                            %
                        end % if we have binned ctd data
                        
                    end % T cal is good
                    
                else
                    disp('no good chi data for this profile');
                    %##
                    fprintf(fileID,' No chi file found ');
                    %##
                    proc_info.(whSN).IsChiData(icast)=0;
                end % if we have good chipod data for this profile
                
            else
                disp('this file already processed')
                %##
                fprintf(fileID,' file already exists, skipping ');
                %##
            end % already processed
            
        catch
            %##
            fprintf(fileID,['\n error on icast=' num2str(icast) ', ' whSN ]);
            %##
        end % try
        
    end % each chipod on rosette (up_down_big)
    
    % save processing info (save after each cast in case it crashes)
    proc_info.MakeInfo=['Made ' datestr(now) ' w/ ' this_script_name]
    proc_info.last_iSN=iSN;
    proc_info.last_icast=icast;
    save(fullfile(BaseDir,'Data','proc_info.mat'),'proc_info')
 
end % icast (each CTD file)

delete(hb)

% throw out any bad ranges in proc_info
proc_info.Prange(find(proc_info.Prange>8000))=nan;

proc_info.Readme={'Prange : max pressure of each CTD cast' ; ...
    'drange : time range of each cast (datenum)' ;...
    'Name : CTD filename for each cast';...
    'duration : length of cast in days'}

save(fullfile(BaseDir,'Data','proc_info.mat'),'proc_info')


telapse=toc(tstart)

%##
fprintf(fileID,['\n \n Done! \n Processing took ' num2str(telapse/60) ' mins to run']);
%##

%%
