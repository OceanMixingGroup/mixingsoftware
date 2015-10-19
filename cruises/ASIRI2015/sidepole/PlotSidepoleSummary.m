%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotSidepoleSummary.m
%
% Plot summary of sidepole ADCP data processed so far.
%
% 08/29/15 - A.Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

load('/Volumes/scienceparty_share/data/sentinel_1min.mat')

load('/Volumes/scienceparty_share/data/nav_tot.mat')

ib=find(N.lon<80);N.lon(ib)=nan;clear ib

yl=[0 50];
cl=0.65*[-1 1]

figure(1);clf
set(gcf,'NumberTitle','off','position',[835   553   841   402])
wysiwyg
m=6;
n=1;

ax1=subplot(m,n,1);
plot(N.dnum_ll,N.lat,'linewidth',2)
cb=colorbar;killcolorbar(cb)
datetick('x',2)
xlim([nanmin(V.dnum) nanmax(V.dnum)])
ylabel('Latitude')
grid on
title(['sidepole 500kHz - made ' datestr(now) ' (local)'])

ax2=subplot(m,n,2);
plot(N.dnum_ll,N.lon,'linewidth',2)
cb=colorbar;killcolorbar(cb)
datetick('x',2)
xlim([nanmin(V.dnum) nanmax(V.dnum)])
ylabel('longitude')
grid on

ax3=subplot(m,n,[3 4]);
ezpc(V.dnum,V.z,V.u); axis ij;
shading interp
hold on
caxis(cl);
colormap(bluered)
cb=colorbar;
cb.Label.String='u[m/s]';
ylabel('Depth (m) ','fontsize',16);
ylim(yl)
datetick('x',2)
xlim([nanmin(V.dnum) nanmax(V.dnum)])
SubplotLetterMW('u');

ax4=subplot(m,n,[5 6]);
ezpc(V.dnum,V.z,V.v); axis ij;
shading interp
hold on
caxis(cl);
colormap(bluered)
cb=colorbar;
cb.Label.String='v[m/s]';
ylabel('Depth (m) ','fontsize',16);
ylim(yl)
datetick('x',2)
xlim([nanmin(V.dnum) nanmax(V.dnum)])
SubplotLetterMW('v')

linkaxes([ax1 ax2 ax3 ax4],'x')

addpath('/Volumes/scienceparty_share/mfiles/shared/cbrewer/cbrewer/')
cmap=cbrewer('div','RdBu',11);
colormap(flipud(cmap))

%%

print('/Volumes/scienceparty_share/figures/ADCP/sidepole_summary','-dpng')

%%