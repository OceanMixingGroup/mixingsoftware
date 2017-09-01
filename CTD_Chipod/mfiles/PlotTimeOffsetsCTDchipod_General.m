function PlotTimeOffsetsCTDchipod_General(Project)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotTimeOffsetsCTDchipod_General.m
%
% Plot chipod time offsets for CTD-chipods from a cruise
%
% INPUTS
% ChiInfo       :
% chi_proc_path :
%
%
%
%-----------------
% 02/02/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%clear ;
close all

%saveplot=1
eval(['Load_chipod_paths_' Project])
eval(['Chipod_Deploy_Info_' Project])

load( fullfile(BaseDir,'Data','proc','proc_info.mat'))

% loop through chipods
for iSN=1:length(ChiInfo.SNs)
    
    clear whSN
    whSN=ChiInfo.SNs{iSN}
    
    % make list of files for this sensor
%    clear Flist
%    Flist=dir( fullfile( chi_proc_path,whSN,'cal',['*' whSN '.mat']) )
    cnums = proc_info.icast;
    tms   = nan*ones(1,length(proc_info.icast));
    toffs = nan*ones(1,length(proc_info.icast));
    hb=waitbar(0)
%     for icast=1:length(proc_info.icast)
%         waitbar(icast/length(proc_info.icast),hb,['Working on ' whSN])
%         try
%             clear chidat
%             %load(fullfile(  chi_proc_path,whSN,'cal',Flist(icast).name))
%             toffs(icast)=proc_info.(whSN).toffset ;
%             %tms(icast)=nanmean(chidat.datenum);
%         end
%     end
%     delete(hb)
    
    
    figure;clf
    agutwocolumn(0.6)
    wysiwyg
    plot(proc_info.icast,proc_info.(whSN).toffset,'o')
    datetick('x')
    xlabel('date','fontsize',15)
    ylabel('time offset (sec)','fontsize',15)
    title([ChiInfo.Project ' - ' whSN])
    grid on
    
    %
%     
%     if saveplot==1
%         figdir='/Users/Andy/Cruises_Research/ChiPod/P16N/figures/';
%         print('-dpng','-r300',fullfile(figdir,cruise,['P16N_' cruise '_' whSN '_TimeOffsets' ]))   ;
%     end
    
end % wh SN

%%



%%