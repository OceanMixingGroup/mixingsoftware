%%
%
% Plot_navtot.m
%
% Plot ship nav data from nav_tot.mat (made in asiri_read_running_nav.m) to
% check that it makes sense
%
%%
clear ; close all
load('/Volumes/scienceparty_share/data/nav_tot.mat')

%%

N.lat(N.lat<13)=nan;
N.lon(N.lon<70)=nan;

m=2
n=1
figure(1);clf
subplot(m,n,1)
plot(N.dnum_ll,N.lon)
datetick('x')
ylabel('lon')
title(['navtot - Plot made ' datestr(now)])

subplot(m,n,2)
plot(N.dnum_ll,N.lat)
datetick('x')
ylabel('lat')

% subplot(m,n,3)
% plot(N.dnum_ll,N.lon)
% datetick('x')

%%