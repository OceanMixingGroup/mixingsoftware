function plot_XC_summaries(the_project)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function version of PlotXCsummaries_Template.m
%
% Make mostly automated summary plots of CTD0-chipod data
%
% Uses structure 'XC' made w/ Make_Combined_Chi_Struct_...
%
%
% OUTPUT
% - Plots all vars for each SN
% - Plots one var for all SN
%
% Dependencies:
% - PlotChipodXC_allVars
% - PlotChipodXC_OneVarAllSN
%
%------------
% 06/14/16 - A.Pickering - apickering@coas.oregonstate.edu
% 09/05/17 - AP - Turn template into a general function
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%clear ; close all

saveplot = 1

% Load paths for CTD and chipod data
eval(['Load_chipod_paths_' the_project])

% Load chipod deployment info
eval(['Chipod_Deploy_Info_' the_project])

% change this if not using default processing Params
Params = SetDefaultChiParams

pathstr = MakeChiPathStr(Params) ;

load(fullfile(BaseDir_data,'Data',[the_project '_XC_' pathstr]),'XC')

ChkMkDir( fullfile(fig_path,'XC'))

xvar='lat'
%xvar='dnum'

for iSN=1:length(ChiInfo.SNs)
    
    try
        
    clear X
    whsens='T1' ;
    whSN = ChiInfo.SNs{iSN} ;
    castdir = ChiInfo.(whSN).InstDir ;
    if isstruct(castdir)
        castdir = castdir.(whsens) ;
    end
    
    close all
    ax=PlotChipodXC_allVars(XC,whSN,castdir,whsens,xvar);
    
    if saveplot==1
        print(fullfile(fig_path,'XC',['XC_' whSN '_Vs_' xvar '_' castdir 'AllVars']),'-dpng')
    end
    
    catch
    end
    
    
end % iSN

%%

close all

for ivar=1:2
    
    switch ivar
        case 1
            whvar = 'chi';
        case 2
            whvar = 'KT';
    end
    
    ax = PlotChipodXC_OneVarAllSN(XC,ChiInfo,whvar) ;
    ylim([0 5000])
    
    axes(ax(1)) ;
    title([ChiInfo.the_project '  -  ' whvar])
    
    linkaxes(ax)
    
    if saveplot==1
        print(fullfile(fig_path,'XC',[ChiInfo.the_project '_' whvar '_AllSNs_Vslat']),'-dpng')
    end
    
end % ivar
%%