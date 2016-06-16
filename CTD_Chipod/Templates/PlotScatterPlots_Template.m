%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotScatterPlots_Template.m
%
% Make scatter plots of variables vs dTdz,N2 etc. for CTD-chipod data.
%
% Uses XC structure made in Make_Combined_Chi_Struct_Template.m
%
%-----------------
% 06/16/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

saveplot=1

% ***
Load_chipod_paths_I09
Chipod_Deploy_Info_I09

load(fullfile(BaseDir,'Data',[ChiInfo.Project '_XC.mat']))

%% Scatter plot chi vs dTdz for each chipod

figure(1);clf
agutwocolumn(1)
wysiwyg

whsens='T1';
xl=[1e-8 1e0];
yl=[1e-12 1e-2];

for iSN=1:length(ChiInfo.SNs)
    
    clear whSN idg
    
    whSN=ChiInfo.SNs{iSN}
    castdir=ChiInfo.(whSN).InstDir
    X=XC.([whSN '_' castdir '_' whsens])
    ax1=subplot(ceil(length(ChiInfo.SNs)/2),2,iSN);
    loglog(X.dTdz(:),X.chi(:),'.')
    xlim(xl)
    ylim(yl)
    hold on
    grid on
    title([whSN ' ' castdir])
    gridxy
    xlabel('dTdz','fontsize',16)
    ylabel('\chi','fontsize',16)
    
end % iSN

%%

%% same as above, but use 2D histogram instead

figure(1);clf
agutwocolumn(1)
wysiwyg

whsens='T1';
xl=[-7 0];
yl=[-12 -5];
cl=[0 80]
%

for iSN=1:length(ChiInfo.SNs)
    
    clear whSN idg
    
    whSN=ChiInfo.SNs{iSN}
    castdir=ChiInfo.(whSN).InstDir
    X=XC.([whSN '_' castdir '_' whsens])
    
    xbins=-8:0.05:0;
    ybins=-12:0.05:-4;
    
    addpath /Users/Andy/Cruises_Research/mixingsoftware/general/
    clear hist mn mdn md
    [hist,mn,mdn,md]=hist2d(xbins,ybins,log10(X.dTdz(:)),0,log10(X.chi(:)),0,0);
    
    %    ax1=subplot(ceil(length(ChiInfo.SNs)/2),2,iSN);
    ax1=subplot(length(ChiInfo.SNs),1,iSN);
    h=pcolor(xbins,ybins,hist)
    hold on
    %    plot(xl(1):0,(xl(1):0)-4,'k--')
    plot(xl(1):0,-(xl(1):0)-14,'k--')
    shading flat
    colorbar
    cmap=flipud(hot);
    cmap=[0.75*[1 1 1] ; cmap];
    colormap(cmap)
    caxis(cl)
    grid on
    
    xlim(xl)
    ylim(yl)
    hold on
    grid on
    title([whSN ' ' castdir])
    gridxy
   
    
    if iSN~=length(ChiInfo.SNs)
        xtloff
    else
    xlabel('dT/dz','fontsize',16)
    end
    ylabel('\chi','fontsize',16)
    
    
    
end % iSN

%%

% %%
% figure(1);clf
% agutwocolumn(1)
% wysiwyg
% 
% ax1=subplot(311);
% loglog(XC.dTdz(:),XC.chi(:),'.')
% xlabel('dTdz','fontsize',16)
% ylabel('chi','fontsize',16)
% grid on
% title(['P16N ' cruise])
% 
% ax2=subplot(312);
% loglog(XC.dTdz(:),XC.eps(:),'.')
% xlabel('dTdz','fontsize',16)
% ylabel('eps','fontsize',16)
% grid on
% 
% ax3=subplot(313);
% loglog(XC.dTdz(:),XC.KT(:),'.')
% xlabel('dTdz','fontsize',16)
% ylabel('KT','fontsize',16)
% grid on
% 
% linkaxes([ax1 ax2 ax3],'x')
% 
% % if saveplot==1
% %     figdir='/Users/Andy/Cruises_Research/ChiPod/P16N/figures/';
% %     print('-dpng','-r300',fullfile(figdir,cruise,['P16N_' cruise '_ChiEpsKtVsdTdz' ]))   ;
% % end
% %%