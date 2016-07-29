%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotChipodSpectra_Template.m
%
% Template script to plot spectra from chi-pods. These should be examined
% to check for quality and where roll-off is etc.
%
% There is option in DoChiCalc... to save spectra? Though this makes the
% files size much larger. Probably better to just pick a few profiles and
% check spectra for those.
%
% ** IN PROGRESS **
%
%----------------
% 07/08/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% ***
cruise='Template'
mixpath='/Users/Andy/Cruises_Research/mixingsoftware/';
addpath(fullfile(mixpath,'CTD_Chipod','mfiles')
Load_chipod_paths_Template
Chipod_Deploy_Info_Template
%***

figdir=fullfile(BaseDir,'Figures');
%~~~

load('Xproc.mat')

%%

for iSN=1%:length(ChiInfo.SNs)
    
    whSN=ChiInfo.SNs{iSN}
    
    % Find a good cast (T1cal good, t-offset good)
    
    idg=find( Xproc.(whSN).IsChiData==1 & Xproc.(whSN).T1cal==1)
    ig=idg(1)
    castname=Xproc.Name{ig}
    
    % Load cast data and
    
    castdir=ChiInfo.(whSN).InstDir
    
    whsens='T1';
    if isstruct(castdir)
        castdir=castdir.(whsens)
    end
    Params=SetDefaultChiParams
    pathstr=MakePathStr(Params)
    load(fullfile(chi_proc_path,whSN,'avg',pathstr,['avg_' castname '_' castdir 'cast_' whSN '_' whsens '.mat']))
    
    %% Plot single spectra
    
    saveplots=1
    
    for iz=200:round(length(avg.P)/10):length(avg.P)
        figure(1);clf
        if sum(~isnan(avg.ks(iz,:)))>10
            ax=PlotSavedChiSpectra(avg,iz);
            pause(0.2)
            
            if saveplots==1
                ChkMkDir(fullfile(figdir,'Spectra'))
                print(fullfile(figdir,'Spectra',[whSN '_' whsens '_'  castdir 'cast_' castname '_wind' num2str(iz) '_fmax' num2str(Params.fmax)]),'-dpng')
            end
        end
        
    end
    %%
    
    
    
end % iSN



%%
% %% Compute spectra
%
%     Params.nfft=128;
%     TP=C.T1P;
%
%     % Get windows for chi calculation
%     clear todo_inds Nwindows
%     [todo_inds,Nwindows]=MakeCtdChiWindows(TP,Params.nfft);
%
%     % Make 'avg' structure for the processed data
%     clear avg
%     avg=struct();
%     avg.Params=Params;
%     tfields={'datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
%         'chi1','eps1','KT1','TP1var'};
%     for n=1:length(tfields)
%         avg.(tfields{n})=NaN*ones(Nwindows,1);
%     end
%
%     avg.samplerate=1./nanmedian(diff(C.datenum))/24/3600;
%
%     % Get average time, pressure, and fallspeed in each window
%     for iwind=1:Nwindows
%         clear inds
%         inds=todo_inds(iwind,1) : todo_inds(iwind,2);
%         avg.datenum(iwind)=nanmean(C.datenum(inds));
%         avg.P(iwind)=nanmean(C.P(inds));
%         avg.fspd(iwind)=nanmean(C.fspd(inds));
%     end
%
%     % Loop through each window and do the chi computation
%
%     % make empty array for spectra
%     fspec=nan*ones(Nwindows,Params.nfft/2);
%
%     for iwind=1:Nwindows
%         clear inds
%         inds=todo_inds(iwind,1) : todo_inds(iwind,2);
%
%         clear tp_power freq
%         [fspec(iwind,:),freq]=fast_psd(TP(inds),Params.nfft,avg.samplerate);
%
%         %         figure(1);clf
%         %         loglog(freq,tp_power)
%         %         grid on
%
%     end % iwind
%
%
%     figure(2);clf
%     ezpc(freq,avg.P,log10(fspec))
%     colorbar
%     %       caxis([-8 -1])
%%