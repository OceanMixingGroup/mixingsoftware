%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% VisCheck_TP_profiles_EachCast_Template.m
%
% Template for script to plot TP profiles chipods for one
% cast and mark as good/bad. Used to exclude obviously bad profiles from
% being used in further calculations.
%
% Modified from Plot_TP_profiles_EachCast_IO9.m
%
% OUTPUT
% GBinds : A structure containg good(=1)/bad(=0) indices for each chipod
% SN.
%
% %*** Indicates where changes needed for specific cruises
%
% Saves figures to /BaseDir/Figures/TPprofiles
%
% Dependencies:
% Load_chipod_paths_Template.m
% Chipod_Deploy_Info_Template.m
% MakeCasts... needs to be run first
% Plot_TP_profiles_EachCast_IO9.m needs to be run first
%
%-----------------
% 07/27/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Plot T' profiles from each sensor/cast direction for one cast
% trying to assess which sensors are clean/noisy

clear ; close all

% *** Data paths
Load_chipod_paths_Template
% *** load deployment info
Chipod_Deploy_Info_Template

xl=0.5*[-1 1];

% Make list of which CTD casts we have processed
CTDlist=dir([CTD_out_dir_bin '/*.mat'])
Ncasts=length(CTDlist)

% Check if we have any 'big' chipods
bc=[];
for iSN=1:length(ChiInfo.SNs);
    bc=[bc ChiInfo.(ChiInfo.SNs{iSN}).isbig];
end
idg=find(bc==1);
Nbig=length(idg);


% Make empty array of good/bad indices for each sensor
GBinds=struct();
for iSN=1:length(ChiInfo.SNs)
    whSN=ChiInfo.SNs{iSN}
    GBinds.(whSN)=nan*ones(1,Ncasts);
end
GBinds

%%

hb=waitbar(0)

for icast=1:Ncasts
    
    waitbar(icast/Ncasts,hb)
    castname=CTDlist(icast).name(1:end-4)
    
    ymax=[];
    
    whax=1;
    for iSN=1:length(ChiInfo.SNs)
        
        % Set up figure
        figure(1);clf
        agutwocolumn(1)
        wysiwyg
        set(gcf,'Name',[castname]);
        
        clear whSN castdir C
        
        whsens='T1';
        whSN=ChiInfo.SNs{iSN};
        castdir=ChiInfo.(whSN).InstDir.(whsens);
        dir2=fullfile(whSN,'cal');
        
        disp(['/n Working on ' whSN ' ' castdir 'cast, cast ' castname])
        
        try
            load(fullfile(chi_proc_path,dir2,[castname '_' whSN '_' castdir 'cast.mat']))
            disp(['Data loaded for ' whSN ' ' castdir 'cast, cast ' castname])
        catch
            disp(['Error loading data for ' whSN ' ' castdir 'cast, cast ' castname])
        end
        
        if exist('C','var')
            
            try
                ymax=nanmax(C.P);
                
                plot(C.([whsens 'P']),C.P)
                xlim(xl)
                ylim([0 ymax])
                axis ij
                grid on
                xlabel([whsens ' ' castdir])
                title(whSN,'color','g','fontweight','bold')
                
                gridxy
                
                reply=input(' 1=good, 0=bad')
                if isempty(reply)
                    GBinds.(whSN)(icast)=1;
                else
                    GBinds.(whSN)(icast)=reply
                end
                
            catch
                disp(['Error plotting'])
            end
            
        end
        
    end % iSN
    
end % icast

%% save 'GBinds' structure

save(fullfile(BaseDir,'Data','GB.mat'),'GBinds')

%%
