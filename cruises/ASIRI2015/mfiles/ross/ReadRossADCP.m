%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ReadRossADCP.m
%
% Read ROSS ADCP data on ASIRI
% 2015 cruise into into matlab format (still in beam coordinates)
%
% 09/15/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

addpath('/Volumes/scienceparty_share/mfiles/pipestring/')

saveplots=1

for whdep=2:5
    close all
    clear name fname namefull adcp BaseDir FigDir
    if whdep==1
        name='Deploy1';fname='_RDI_005.000'
    elseif whdep==2
        name='Deploy2';fname='_RDI_000.000'
    elseif whdep==3
        name='Deploy3';fname='ROSS3003.000'
    elseif whdep==4
        name='Deploy4';fname='ROSS4001.000'
    elseif whdep==5
        name='Deploy5';fname='ROSS5000.000'
    elseif whdep==6
        name='Deploy6';fname='ROSS5002.000'
    end
    BaseDir=fullfile('/Volumes/scienceparty_share/ROSS/',name)
    FigDir=fullfile(BaseDir,'figures')
    
    % read into matlab
    namefull=fullfile('/Volumes/scienceparty_share/ROSS/',name,'adcp','raw',fname)
    [adcp,cfg,ens,hdr]=rdradcp(namefull,1);
    adcp.mtime(end)=nan;
    
    %% plot some of the raw data
    
    %~~~ beam velocities
    cl=0.75*[-1 1]
    yl=[0 60]
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05,1,4);
    
    axes(ax(1))
    ezpc(adcp.mtime,cfg.ranges,adcp.east_vel)
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    title(['ROSS ' name '  Beam velocities'])
    SubplotLetterMW('Bm1')
    
    axes(ax(2))
    ezpc(adcp.mtime,cfg.ranges,adcp.north_vel)
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    SubplotLetterMW('Bm2')
    
    axes(ax(3))
    ezpc(adcp.mtime,cfg.ranges,adcp.vert_vel)
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    SubplotLetterMW('Bm3')
    
    axes(ax(4))
    ezpc(adcp.mtime,cfg.ranges,adcp.error_vel)
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    SubplotLetterMW('Bm4')
    
    addpath('/Volumes/scienceparty_share/mfiles/shared/cbrewer/cbrewer/')
    cmap=cbrewer('div','RdBu',10);
    colormap(flipud(cmap))
    
    linkaxes(ax)
    
    if saveplots==1
        print(fullfile(FigDir,['adcp_' name '_BmVels']),'-dpng','-r75')
    end
    %~~~
    %
    %~~~ beam correlations
    cl=[0 143]
    yl=[0 60]
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05,1,4);
    
    axes(ax(1))
    ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,1,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    title(['ROSS ' name '  Beam correlations'])
    
    axes(ax(2))
    ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,2,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    
    axes(ax(3))
    %ezpc(adcp.mtime,cfg.ranges,adcp.vert_vel)
    ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,3,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    
    axes(ax(4))
    ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,4,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    
    %addpath('/Volumes/scienceparty_share/mfiles/shared/cbrewer/cbrewer/')
    %cmap=cbrewer('seq','YlOrRd',10);
    %colormap((cmap))
    colormap(parula)
    
    linkaxes(ax)
    if saveplots==1
        print(fullfile(FigDir,['adcp_' name '_BmCorrs']),'-dpng','-r75')
    end
    %~~~
    %
    
    %~~~ % good
    cl=[80 100]
    yl=[0 60]
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05,1,4);
    
    axes(ax(1))
    ezpc(adcp.mtime(1:end-1),cfg.ranges,squeeze(adcp.perc_good(:,1,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    title(['ROSS ' name '  percent good'])
    
    axes(ax(2))
    ezpc(adcp.mtime(1:end-1),cfg.ranges,squeeze(adcp.perc_good(:,2,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    
    axes(ax(3))
    %ezpc(adcp.mtime,cfg.ranges,adcp.vert_vel)
    ezpc(adcp.mtime(1:end-1),cfg.ranges,squeeze(adcp.perc_good(:,3,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    
    axes(ax(4))
    ezpc(adcp.mtime(1:end-1),cfg.ranges,squeeze(adcp.perc_good(:,4,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    
    %addpath('/Volumes/scienceparty_share/mfiles/shared/cbrewer/cbrewer/')
    %cmap=cbrewer('seq','YlOrRd',10);
    %colormap((cmap))
    colormap(jet)
    
    linkaxes(ax)
    
    %
    %~~~ beam intensities
    cl=[50 150]
    yl=[0 60]
    figure(2);clf
    agutwocolumn(1)
    wysiwyg
    ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05,1,4);
    
    axes(ax(1))
    ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.intens(:,1,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    title(['ROSS ' name '  Beam Intensities'])
    
    axes(ax(2))
    ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.intens(:,2,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    
    axes(ax(3))
    %ezpc(adcp.mtime,cfg.ranges,adcp.vert_vel)
    ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.intens(:,3,:)))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    
    axes(ax(4))
    ezpc(adcp.mtime,cfg.ranges,(squeeze(adcp.intens(:,4,:))))
    caxis(cl)
    ylim(yl)
    datetick('x')
    colorbar
    ylabel('range [m]')
    
    %addpath('/Volumes/scienceparty_share/mfiles/shared/cbrewer/cbrewer/')
    %cmap=cbrewer('seq','YlOrRd',10);
    %colormap((cmap))
    colormap(parula)
    
    linkaxes(ax)
    if saveplots==1
        print(fullfile(FigDir,['adcp_' name '_BmIntens']),'-dpng','-r75')
    end
    
    %% save mat file for analysis
    adcp.source=namefull
    adcp.MakeInfo=['Made ' datestr(now) ' w/ ReadRossADCP.m']
    save(['/Volumes/scienceparty_share/ROSS/' name '/adcp/mat/' name '_beam.mat'],'adcp','cfg','ens','hdr')
    
    %%
    
end