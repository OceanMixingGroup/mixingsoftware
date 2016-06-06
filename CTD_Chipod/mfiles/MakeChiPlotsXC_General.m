function MakeChiPlotsXC_General(XC,ChiInfo,saveplots,figdir)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% MakeChiPlotsXC_General.m
%
% General script to make some standard plots of processed chipod data that
% has been combined into standard 'XC' structure.
%
% INPUTS
% XC        : Structure with processed chipod data for a cruise
% ChiInfo   : Standard structure with deployment info for cruise.
% saveplots
% fig_path  : Folder to save figures to.
%
%
%------------------------
% 02/01/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Pcolor all vars for one chipod
% only plot 'clean' sensors (mounted in direction of cast)

%clear ;
close all

xvar='lat';
xvar='castnumber'

%xl=[nanmin(XC.([whSN '_' castdir '_' whsens]).(xvar)) nanmax(XC.([whSN '_' castdir '_' whsens]).(xvar))];

% loop through each SN
for iSN=1:length(XC.allSNs)
    
    try
        clear whSN castdir
        whSN=XC.allSNs{iSN}
        castdir=ChiInfo.(whSN).InstDir.T1;
        whsens='T1'
        
        figure;clf
        agutwocolumn(1)
        wysiwyg
        ax = MySubplot(0.1, 0.05, 0.02, 0.06, 0.1, 0.02, 1,5);
        
        axes(ax(1))
        ezpc(XC.([whSN '_' castdir '_' whsens]).(xvar),XC.([whSN '_' castdir '_' whsens]).P,log10(XC.([whSN '_' castdir '_' whsens]).N2) )
        hold on
        plot(XC.([whSN '_' castdir '_' whsens]).(xvar),0,'kp')
        cb=colorbar;
        cb.Label.String='log_{10}N^2 [s^{-2}]';
        cb.Label.FontSize=14;
        %    xlim(xl)
        %    ylim(yl)
        xtloff
        title([XC.Name ' -  \chi -pod ' whSN ' ' castdir 'casts'])
        SubplotLetterMW('N^2')
        
        %
        axes(ax(2))
        ezpc(XC.([whSN '_' castdir '_' whsens]).(xvar),XC.([whSN '_' castdir '_' whsens]).P,log10(XC.([whSN '_' castdir '_' whsens]).dTdz))
        hold on
        %    xlim(xl)
        %    ylim(yl)
        xtloff
        SubplotLetterMW('dT/dz');
        cb=colorbar;
        cb.Label.String='log_{10}dT/dz [Cm^{-1}]';
        cb.Label.FontSize=14;
        
        %
        axes(ax(3))
        ezpc(XC.([whSN '_' castdir '_' whsens]).(xvar),XC.([whSN '_' castdir '_' whsens]).P,log10(XC.([whSN '_' castdir '_' whsens]).chi))
        caxis([-11 -7])
        %    xlim(xl)
        %    ylim(yl)
        xtloff
        ylabel('Pressure [db]')
        SubplotLetterMW('chi');
        cb=colorbar;
        cb.Label.String='log_{10}\chi';
        cb.Label.FontSize=14;
        
        %
        axes(ax(4))
        ezpc(XC.([whSN '_' castdir '_' whsens]).(xvar),XC.([whSN '_' castdir '_' whsens]).P,log10(XC.([whSN '_' castdir '_' whsens]).eps))
        cb=colorbar;
        cb.Label.String='log_{10}\epsilon [Wkg^{-1}]';
        cb.Label.FontSize=14;
        caxis([-11 -6])
        %    xlim(xl)
        %    ylim(yl)
        xtloff
        SubplotLetterMW('eps');
        
        %
        axes(ax(5))
        ezpc(XC.([whSN '_' castdir '_' whsens]).(xvar),XC.([whSN '_' castdir '_' whsens]).P,log10(XC.([whSN '_' castdir '_' whsens]).KT))
        cb=colorbar;
        cb.Label.String='log_{10}K_T';
        cb.Label.FontSize=14;
        caxis([-8 -1])
        hold on
        %    xlim(xl)
        %    ylim(yl)
        xlabel(xvar,'fontsize',16)
        SubplotLetterMW('K_T');
        
        linkaxes(ax)
        %
        if saveplots==1
            figname=[whSN '_' whsens '_' castdir '_Summary']
            print('-dpng','-r300',fullfile(figdir,figname))
        end
        
    end % try
    
end % iSN

%% Make scatterplot of chi,eps,Kt versus dTdz

xl=[1e-6 1e0]

% loop through each SN
for iSN=1:length(XC.allSNs)
    
    try
        
        clear whSN castdir X
        whSN=XC.allSNs{iSN}
        castdir=ChiInfo.(whSN).InstDir.T1;
        
        X=XC.([whSN '_' castdir '_' whsens]);
        
        figure;clf
        agutwocolumn(1)
        wysiwyg
        ax = MySubplot(0.1, 0.05, 0.02, 0.06, 0.1, 0.05, 1,3);
        
        axes(ax(1))
        loglog(X.dTdz(:),X.chi(:),'.')
        grid on
        xlim(xl)
        ylabel('\chi','fontsize',16)
        ylim([1e-13 1e-3])
        title([whSN ' - ' castdir 'cast - ' whsens])
        
        %
        axes(ax(2))
        loglog(X.dTdz(:),X.eps(:),'.')
        grid on
        xlim(xl)
        ylim([1e-13 1e-2])
        ylabel('\epsilon','fontsize',16)
        
        axes(ax(3))
        loglog(X.dTdz(:),X.KT(:),'.')
        grid on
        xlim(xl)
        ylim([1e-10 1e4])
        ylabel('K_T','fontsize',16)
        xlabel('dT/dz','fontsize',16)
        %
        linkaxes(ax,'x')
        
        
        if saveplots==1
            figname=[whSN '_' whsens '_' castdir '_ChiEpsKtVsdTdz']
            print('-dpng','-r300',fullfile(figdir,figname))  ;
        end
        
        
    end % try
    
end % iSN


%

%% Plot histograms from each sensor


vars={'chi','eps','KT'}

for ivar=1:3
    
    clear whvar
    whvar=vars{ivar}
    figure;clf
    agutwocolumn(0.6)
    wysiwyg
    
    hh=[];
    
    for iSN=1:length(XC.allSNs)
        
        for iSens=1:2
            switch iSens
                case 1
                    whsens='T1'
                case 2
                    whsens='T2'
            end
            
            try
                
                clear whSN castdir X
                whSN=XC.allSNs{iSN}
                castdir=ChiInfo.(whSN).InstDir.(whsens);
                
                X=XC.([whSN '_' castdir '_' whsens]);
                
                h=histogram(log10(X.(whvar)(:)),[-13:0.25:-2],'DisplayStyle','stair','Normalization','count')
                h.DisplayName=[whSN '-' whsens '-' castdir]
                hh=[hh h];
                clear h
                hold on
                
            end % try
        end % iSens
        
    end % iSN
    
    grid on
    xlabel(['log_{10} ' whvar],'fontsize',16)
    ylabel('count','fontsize',16)
    legend(hh)
    
    if saveplots==1
        figname=[whSN '_' whsens '_' castdir '_' whvar 'Hists']
        print('-dpng','-r300',fullfile(figdir,figname))  ;
    end
    
end % ivar
%%