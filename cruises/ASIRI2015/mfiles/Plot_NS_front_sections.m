%~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PLot_NS_front_sections_APv2.m
%
% (was PLot_NS_front_sections.m)
%
% Plot parallel NS transects ('nidhi' sections) on one figure to look at
% progression in space/time. Plots velocity from sidepole and isopycnals
% from FCTD.
%
% Uses mat files with adcp data for each section made in MakeADCPmat_FCTDsecs.m
%
%-------------
% 09/19/15 - A.Pickering
% 10/14/15 - AP - Copied from my science share copy to my laptop after
% cruise, now working on this copy.
%~~~~~~~~~~~~~~~~~~~~~~~~~
%%
clear ; close all

% variable to plot
whvar='u'

% option to save plot
saveplots=1

% path to my back-up of science share that has data files on it
SciencePath='/Volumes/Midge/ExtraBackup/scienceshare_092015/'
DataPath=fullfile(SciencePath,'data')

% path to mat files with adcp data for each section
datdir=fullfile(SciencePath,'adcp_secs')

% path to save figures to
figdir=datdir;

MfilePath='/Users/Andy/Cruises_Research/mixingsoftware/cruises/ASIRI2015/mfiles/'
addpath(MfilePath)
addpath(fullfile(MfilePath,'shared'))

% load file with section names and times
load(fullfile(SciencePath,'FCTD','FCTD_scratch','fctd_names.mat'))

% choose a set of density values to contour (make the same in all plots)
%sgm=nanmean(FF.grid.density,2);sgm=sgm(~isnan(sgm));
sgm=1018:.25:1028;

close all

sec_to_plot=[23 25 26 27 28 29 30 32]
%sec_to_plot=[23 25 26 27]
%sec_to_plot=[28 29 30 32]

%sec_to_plot=26
%28 29 30 32]
% 23: nidhi4
% 25: nidhi5
% 26: nidhi6
% 27: nidhi7
% 28: nidhi8
% 29: nidhi9
% 30: nidhhi10
% 32: nidhi 12

% 30,31 doesn't work

figure(1);clf
agutwocolumn(1)
wysiwyg
%set(gcf,'Name','ADCP combined','NumberTitle','off','position',[835   553   841   402])
%ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.01, 1,length(sec_to_plot));
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.01, 2,length(sec_to_plot)/2);

axorder=[1 3 5 7 2 4 6 8]
for isec=1:length(sec_to_plot)
    clear whsec secname F idV
    whsec=sec_to_plot(isec)
    
    secname=fctd_names(whsec).name
    F=fctd_names(whsec)
    
    % load FCTD section to contour density
    load(fullfile(SciencePath,'FCTD','FCTD_scratch',[F.name '.mat']))
    eval(['FF=' F.name ])
    
    % load ADCP data for this section
    clear adcp fname
    %datdir='/Volumes/scienceparty_share/data/adcp_secs'
    %datdir=fullfile(LocalPath,'adcp_secs')
    fname=fullfile(datdir,[F.name '_adcp.mat'])
    load(fname)
    
    cl=0.5*[-1 1]
    yl=[0 50]
    xl=[17.15 17.5]
    dd=1
    
    %figure(1)
    axes(ax(axorder(isec)))
    ezpc(adcp.V.lat,adcp.V.z,adcp.V.(whvar))
    
    ig=find(~isnan(FF.grid.lat(1,:)));
    hold on
    contour(FF.grid.lat(1,ig),FF.grid.depth,FF.grid.density(:,ig),sgm(1:dd:end),'k')
    %colorbar
    caxis(cl)
    ylim(yl)
    xlim(xl)
    
    if isec>4
        ytloff
    else
        ylabel('depth [m]')
    end
    
    if axorder(isec)<7
        xtloff
    else
        xlabel('latitude')
    end
    
    SubplotLetterMW(['"' F.name '"'],0.1,0.9);
end
%
cb=colorbar('location','east');
cb.TickDirection='out';
cb.AxisLocation='out';
cb.Position=cb.Position.*[1.05 1 1 1];
%
linkaxes(ax)

addpath(fullfile(SciencePath,'mfiles','shared','cbrewer','cbrewer'))
cmap=cbrewer('div','RdBu',10);
colormap(flipud(cmap))
shg
%
if saveplots==1
    %   print(['/Volumes/scienceparty_share/figures/NS_FrontSections_8panel_' whvar],'-dpng')
    print(fullfile(figdir,['NS_FrontSections_8panel_' whvar]),'-dpng')
end
%%
