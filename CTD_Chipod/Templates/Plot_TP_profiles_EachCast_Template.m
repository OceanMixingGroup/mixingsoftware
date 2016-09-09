%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Plot_TP_profiles_EachCast_Template.m
%
% Template for script to plot TP profiles from all chipods for one
% cast. Allows comparison of TP from different sensors.
%
% %*** Indicates where changes needed for specific cruises
%
% Saves figures to /BaseDir/Figures/TPprofiles
%
% Dependencies:
% Load_chipod_paths_Template.m
% Chipod_Deploy_Info_Template.m
% MakeCasts... needs to be run first
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
% You should't have to modify anything below this
%~~~~~~~~~~~~~~~~~~~~~~

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
%
hb=waitbar(0)
for icast=1:Ncasts
    waitbar(icast/Ncasts,hb)
    castname=CTDlist(icast).name(1:end-4)
    
    % Set up figure
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    set(gcf,'Name',[castname]);
    rr=2;
    if any(bc)==1
        cc=length(ChiInfo.SNs)+Nbig;
    else
        cc=length(ChiInfo.SNs);
    end
    
    ax=nan*ones(1,2*cc);
    
    ymax=[];
    
    iSNoffset=0
    
    whax=1;
    for iSN=1:length(ChiInfo.SNs)
        
        try
            
            % Plot downcasts
            whSN=ChiInfo.SNs{iSN};
            castdir='down';
            whsens='T1';
            dir2=fullfile(whSN,'cal');
            load(fullfile(chi_proc_path,dir2,[castname '_' whSN '_' castdir 'cast.mat']))
            ymax=[ymax nanmax(C.P)];
            
            ax(whax)=subplot(rr,cc,iSN+iSNoffset);
            plot(C.([whsens 'P']),C.P)
            xlim(xl)
            axis ij
            grid on
            xlabel([whsens ' ' castdir])
            if strcmp(castdir,ChiInfo.(whSN).InstDir.T1)
                title(whSN,'color','g','fontweight','bold')
            else
                title(whSN)
            end
            
            gridxy
            
            if iSN~=1
                ytloff
            end
            
        catch
            ax(whax)=subplot(rr,cc,iSN+iSNoffset);
            xlim(xl)
            if strcmp(castdir,ChiInfo.(whSN).InstDir.T1)
                title(whSN,'color','g','fontweight','bold')
            else
                title(whSN)
            end
        end % try
        
        % Plot upcasts
        whax=whax+1;
        
        try
            
            clear C
            castdir='up';
            load(fullfile(chi_proc_path,dir2,[castname '_' whSN '_' castdir 'cast.mat']))
            ymax=[ymax nanmax(C.P)];
            
            ax(whax)=subplot(rr,cc,iSN+iSNoffset+cc);
            plot(C.([whsens 'P']),C.P)
            xlim(xl)
            axis ij
            grid on
            xlabel([whsens ' ' castdir])
            if strcmp(castdir,ChiInfo.(whSN).InstDir.T1)
                title(whSN,'color','g','fontweight','bold')
            else
                title(whSN)
            end
            
            gridxy
            
            if iSN~=1
                ytloff
            end
            
        catch
            ax(whax)=subplot(rr,cc,iSN+iSNoffset+cc);
            xlim(xl)
            if strcmp(castdir,ChiInfo.(whSN).InstDir.T1)
                title(whSN,'color','g','fontweight','bold')
            else
                title(whSN)
            end
        end % try
        
        whax=whax+1;
        
        if ChiInfo.(whSN).isbig==1
            iSNoffset=iSNoffset+1
            ax(whax)=subplot(rr,cc,iSN+iSNoffset);
            try
                
                castdir='down';
                whsens='T2';
                dir2=fullfile(whSN,'cal');
                load(fullfile(chi_proc_path,dir2,[castname '_' whSN '_' castdir 'cast.mat']))
                ymax=[ymax nanmax(C.P)];
                
                plot(C.([whsens 'P']),C.P)
                xlim(xl)
                %ylim(yl)
                axis ij
                grid on
                xlabel([whsens ' ' castdir])
                
                if strcmp(castdir,ChiInfo.(whSN).InstDir.(whsens))
                    title(whSN,'color','g','fontweight','bold')
                else
                    title(whSN)
                end
                
                
                if iSN~=1
                    ytloff
                end
                
            catch
                
                ax(whax)=subplot(rr,cc,iSN+iSNoffset);
                xlim(xl)
                xlabel([whsens ' ' castdir])
                if strcmp(castdir,ChiInfo.(whSN).InstDir.(whsens))
                    title(whSN,'color','g','fontweight','bold')
                else
                    title(whSN)
                end
                
            end % try
            
            whax=whax+1;
            
            ax(whax)=subplot(rr,cc,iSN+iSNoffset+cc);
            try
                
                clear C
                castdir='up';
                
                load(fullfile(chi_proc_path,dir2,[castname '_' whSN '_' castdir 'cast.mat']))
                ymax=[ymax nanmax(C.P)];
                
                plot(C.([whsens 'P']),C.P)
                xlim(xl)
                axis ij
                grid on
                xlabel([whsens ' ' castdir])
                title(whSN)
                
                if iSN~=1
                    ytloff
                end
                
            catch
                ax(whax)=subplot(rr,cc,iSN+iSNoffset+cc);
                xlabel([whsens ' ' castdir])
                xlim(xl)
                if strcmp(castdir,ChiInfo.(whSN).InstDir.T1)
                    title(whSN,'color','g','fontweight','bold')
                else
                    title(whSN)
                end
            end % try
            
            whax=whax+1;
            
        end % isbig
        
    end % iSN
    
    if  sum(~isnan(ax))>0
        axes(ax(1))
        ylabel('Downcasts','fontsize',16)
        
        axes(ax(2))
        ylabel('Upcasts','fontsize',16)
        
        if length(ymax>1)
            yl=[0 nanmax(ymax)];
            for iax=1:length(ax)
                axes(ax(iax))
                ylim(yl)
                axis ij
            end
        end
        
        
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