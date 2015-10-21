
%%

clear ; close all

load('/Volumes/scienceparty_share/data/nav_tot.mat')

%%
%load('/Volumes/scienceparty_share/pipestring/mat/ADCP_ASIRI2015Aug006_000003_beam.mat')
load('/Volumes/scienceparty_share/pipestring/mat/ADCP_ASIRI2015Aug006_000004_beam.mat')
load('/Volumes/scienceparty_share/pipestring/mat/ADCP_ASIRI2015Aug006_000005_beam.mat')
%%

figure(1);clf
plot(adcp.mtime,adcp.pitch)
hold on
plot(N.dnum_hpr,N.pitch)
datetick('x')

%%

figure(1);clf
plot(N.dnum_hpr,N.roll)
hold on
plot(adcp.mtime,adcp.roll)

datetick('x')

%%

figure(1);clf
plot(N.dnum_hpr,N.head)
hold on
%plot(adcp.mtime-550/86400,adcp.heading+85.5)
plot(adcp.mtime,xadcp.heading+85.5)
datetick('x')
%xlim(aa)
%%