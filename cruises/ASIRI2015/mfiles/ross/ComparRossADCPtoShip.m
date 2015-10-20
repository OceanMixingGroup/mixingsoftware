%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% CompareRossADCPtoShip.m
%
%
% 09/13/15 - A.Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

name='Deploy1'

% load ROSS ADCP data
load(['/Volumes/scienceparty_share/ROSS/' name '/adcp/mat/' name '_adcp_proc_smoothed.mat'])

% load sidepole data
load('/Volumes/scienceparty_share/data/sentinel_1min.mat')

idV=isin(V.dnum,[nanmin(vel.dnum) nanmax(vel.dnum)]);

%%

figure(1);clf
agutwocolumn(0.65)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.15, 0.06, 0.1, 0.02, 2,1);

axes(ax(1))
plot(vel.dnum,vel.lat)
hold on
plot(V.dnum(idV),V.lat(idV))
grid on
datetick('x')
ylabel('lat')
legend('ross','ship')

axes(ax(2))
plot(vel.dnum,vel.lon)
hold on
plot(V.dnum(idV),V.lon(idV))
grid on
datetick('x')
ylabel('lon')

%%
figure(2);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.02, 1,4);

yl=[0 50]
cl=1*[-1 1]

axes(ax(1))
ezpc(vel.dnum,vel.z,vel.u)
cb=colorbar;
cb.Label.String='ross u [m/s]';
ylabel('depth [m]')
ylim(yl)
caxis(cl)
%datetick('x')
xtloff
%SubplotLetterMW('ross u')
title(['Ross ' vel.name])
%
axes(ax(2))
ezpc(V.dnum(idV),V.z,V.u(:,idV))
ylim(yl)
caxis(cl)
cb=colorbar;
cb.Label.String='ship u [m/s]';
ylabel('depth [m]')
%datetick('x')
xtloff

axes(ax(3))
ezpc(vel.dnum,vel.z,vel.v)
cb=colorbar;
cb.Label.String='ross v [m/s]';
ylabel('depth [m]')
ylim(yl)
caxis(cl)
%datetick('x')
xtloff

axes(ax(4))
ezpc(V.dnum(idV),V.z,V.v(:,idV))
cb=colorbar;
cb.Label.String='ship v [m/s]';
ylabel('depth [m]')
ylim(yl)
caxis(cl)
datetick('x')
xlabel(['Time on ' datestr(floor(vel.dnum(1)))])

addpath('/Volumes/scienceparty_share/mfiles/shared/cbrewer/cbrewer/')
cmap=cbrewer('div','RdBu',20);
colormap(flipud(cmap))
linkaxes(ax)
%%