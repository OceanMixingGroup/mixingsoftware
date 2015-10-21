%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotPipestringSummary.m
%
% Plot summary of pipestring data processed so far.
%
% 08/26/15 - A.Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

load('/Volumes/scienceparty_share/data/pipestring_1min.mat')

yl=[0 60]
xl=[nanmin(P.dnum) nanmax(P.dnum)]

figure(1);clf
% agutwocolumn(1)
% wysiwyg
set(gcf,'NumberTitle','off','position',[835   553   841   402])
m=6;
n=1;

ax1=subplot(m,n,1);
plot(P.dnum,P.lat)
cb=colorbar;killcolorbar(cb);
datetick('x')
xlim(xl)
ylabel('Latitude')
grid on
title(['pipestring - made ' datestr(now) ' (local)'])

ax2=subplot(m,n,2);
plot(P.dnum,P.lon)
cb=colorbar;killcolorbar(cb);
datetick('x')
xlim(xl)
ylabel('longitude')
grid on

ax3=subplot(m,n,[3 4]);
ezpc(P.dnum,P.z,P.u); axis ij;
shading interp
hold on
caxis(1*[-1 1]);
colormap(bluered)
cb=colorbar;
cb.Label.String='u[m/s]';
ylabel('Depth (m) ','fontsize',16);
ylim(yl)
datetick('x')
xlim(xl)
SubplotLetterMW('u');

ax4=subplot(m,n,[5 6]);
ezpc(P.dnum,P.z,P.v); axis ij;
shading interp
hold on
caxis(1*[-1 1]);
colormap(bluered)
cb=colorbar;
cb.Label.String='v[m/s]';
ylabel('Depth (m) ','fontsize',16);
ylim(yl)
datetick('x')
xlim(xl)
SubplotLetterMW('v');

linkaxes([ax1 ax2 ax3 ax4],'x')
%%
print('/Volumes/scienceparty_share/figures/ADCP/pipestring_summary','-dpng')

%%