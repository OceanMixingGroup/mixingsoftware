%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Plot_TP_profiles_EachCast_Template.m
%
% Template for script to plot TP profiles from all
% chipods for one cast, to be used during chi-pod cruise.
%
% MakeCasts... needs to be run first
%
% %*** Indicates where changes needed for specific cruises
%
% Saves figures to /BaseDir/Figures/TPprofiles
%
%-----------------
% 06/15/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Plot T' profiles from each sensor/cast direction for one cast
% trying to assess which sensors are clean/noisy

clear ; close all

saveplot=1

% *** Data paths
Load_chipod_paths_Template
% *** load deployment info
Chipod_Deploy_Info_Template

% directory for processed data
datdir=chi_proc_path

% Make list of which CTD casts we have processed
CTDlist=dir([CTD_out_dir_bin '/*.mat'])
Ncasts=length(CTDlist)
%%
hb=waitbar(0)
for icast=1:Ncasts
    waitbar(icast/Ncasts,hb)
    castname=CTDlist(icast).name(1:end-4)
    
    % Set up figure
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    set(gcf,'Name',[castname]);
    rr=2;cc=length(ChiInfo.SNs);
    ax=nan*ones(1,2*cc);
    whax=1;
    for iSN=1:cc
        
        try
            
            % Plot downcasts
            whSN=ChiInfo.SNs{iSN};
            castdir='down';
            whsens='T1';
            dir2=fullfile(whSN,'cal');
            load(fullfile(datdir,dir2,[castname '_' whSN '_' castdir 'cast.mat']))
            yl=[0 nanmax(C.P)];
            
            ax(whax)=subplot(rr,cc,iSN);
            plot(C.([whsens 'P']),C.P)
            xlim(0.3*[-1 1])
            ylim(yl)
            axis ij
            grid on
            xlabel([whsens ' ' castdir])
            title(whSN)
            gridxy
            
            if iSN~=1
                ytloff
            end
            
            
            % Plot upcasts
            whax=whax+1;
            
            clear C
            castdir='up';
            load(fullfile(datdir,dir2,[castname '_' whSN '_' castdir 'cast.mat']))
            yl=[0 nanmax(C.P)];
            
            ax(whax)=subplot(rr,cc,iSN+cc);
            plot(C.([whsens 'P']),C.P)
            xlim(0.3*[-1 1])
            ylim(yl)
            axis ij
            grid on
            xlabel([whsens ' ' castdir])
            title(whSN)
            gridxy
            
            if iSN~=1
                ytloff
            end
            
            whax=whax+1;
            
        end % try
        
        
    end % iSN
    
    if  sum(~isnan(ax))>0
        axes(ax(1))
        ylabel('Downcasts','fontsize',16)
        
        axes(ax(2))
        ylabel('Upcasts','fontsize',16)
                
        linkaxes(ax)
    end
    
    if saveplot==1
        figdir=fullfile(BaseDir,'Figures','TPprofiles');
        ChkMkDir(figdir)
        print( fullfile( figdir , ['TP_profs_' castname] ) , '-dpng' )
    end
    
    pause(1)
    
end % castnum

delete(hb)
%%