%~~~~~~~~~~~~~~~~~~~~~~~~~
%
% FindTimeOffsetPole.m
% File1 - ending in 3756 : offset=0
% File2 - ending in 3335: 10sec
% File 3 - ending in 3832: offset=0
% File 4 - ending in 3350 : 10sec
% File 5 - ending in 555.pd0 : 30sec
% File6 - ending n 3729.pd0 : time offset=30sec
% File 7 - ending in 5213 : 30 sec
% File 8 - ending in 1838: 
%
% 09/15/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~
%%


clear ; close all

cd('/Volumes/scienceparty_share/mfiles/sidepole/')

% load in navigation data from ship (more reliable than the internal
% sensors in the instrument itself). this is a file created by
% 'asiri_read_running_nav.m' and it outputs a structure "N".
disp('loading nav data')
load('/Volumes/scienceparty_share/data/nav_tot.mat')
ttemp_nav=N.dnum_hpr; ig=find(diff(ttemp_nav)>0); ig=ig(1:end-1)+1;
%%
clear adcp
%load('/Volumes/scienceparty_share/sidepole/mat/ASIRI_2Hz_deployment_20150824T043756_split_000.011_beam.mat')
%load('/Volumes/scienceparty_share/sidepole/mat/ASIRI 2Hz deployment 20150828T043335_split_000.004_beam.mat')
%load('/Volumes/scienceparty_share/sidepole/mat/ASIRI 2Hz deployment 20150829T123832_split000.000_beam.mat')
%load('/Volumes/scienceparty_share/sidepole/mat/ASIRI 2Hz deployment 20150904T053350_Split_000.001_beam.mat')
%load('/Volumes/scienceparty_share/sidepole/mat/ASIRI 2Hz deployment 20150911T223729_split_000.005_beam.mat')
%load('/Volumes/scienceparty_share/sidepole/mat/ASIRI 2Hz deployment 20150908T141555_split_000.014_beam.mat')
%load('/Volumes/scienceparty_share/sidepole/mat/ASIRI 2Hz deployment 20150915T165213_split_000.000_beam.mat');l
load('/Volumes/scienceparty_share/sidepole/mat/ASIRI 2Hz deployment 20150917T091838_split_000.000_beam.mat')


%%

ig=isin(N.dnum_hpr,[nanmin(adcp.dnum) nanmax(adcp.dnum)]);
t_offset=30
D1=datetime(N.dnum_hpr(ig),'convertfrom','datenum');
D2=datetime(adcp.dnum+t_offset/86400,'convertfrom','datenum');
%
h2=adcp.heading+85.5;
ip=find(h2>360);
h2(ip)=h2(ip)-360;

figure(1);clf
plot(D1,N.head(ig))
hold on
plot(D2,h2)
%datetick('x')


%%

figure(2);clf
plot(D1,N.pitch(ig))
hold on
plot(D2,adcp.pitch+655.36)
%%