%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% AddBathyToChipod.m
%
% Working on a function to get ocean depth for CTD-chipod cruise tracks and
% add to the chipod structure.
%
%----------------- 
% 08/29/16 - A.Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

project='P15S'

eval(['Load_chipod_paths_' project])
load(fullfile(BaseDir_data,'Data','proc_info.mat'))

% Get lat/lons
lat=proc_info.lat;
lon=proc_info.lon;

% check distribution of lat/lon to see if any outliers (might need to wrap)
figure(1);clf

subplot(121)
%histogram(lon(:),30)
boxplot(lon)

subplot(122)
%histogram(lon(:),30)
boxplot(lat)

% for P15S, one lon is +150, rest are ~-160
ib=find(lon<0)
lon(ib)=lon(ib)+360;
%%
% Plot lat/lons
figure(1);clf
plot(lon,lat,'o')
grid on
%% get a 2D lat/lon grid of depths covering the transect

% should add a line to make lons all negative or positive (example w/ P15S,
% almost all -160, but one or two are + 150, which makes the depth matrix
% HUGE

lonrange=[nanmin(lon)-1 nanmax(lon)+1]
latrange=[nanmin(lat)-1 nanmax(lat)+1]

addpath /Users/Andy/Cruises_Research/mixingsoftware/smith_sandwell/

SS=GetSSbathy(lonrange,latrange)


%%

figure(2);clf
ezpc(SS.lon,SS.lat,SS.depth);
xlabel('Longitude','fontsize',16)
ylabel('Latitude','fontsize',16)
axis xy
hold on
plot(lon,lat,'ko')
cb=colorbar;
cb.Label.String='Depth [m]';
colormap(ocean3);
caxis([nanmin(SS.depth(:)) 0])
title(['Cruise Track and Bathymetry for ' project ])

%% Now get vector of points for each station

Dsta=nan*ones(1,length(lon));
for i=1:length(lon)
   
    [val,Ilon]=nanmin(abs(SS.lon-lon(i)));
    [val,Ilat]=nanmin(abs(SS.lat-lat(i)));
    Dsta(i)=SS.depth(Ilat,Ilon);
end

%%
figure(3);clf
%plot(1:length(Dsta),Dsta,'ko-')
plot(lat,Dsta,'mo','LineWidth',2)
%plot(lon,Dsta,'mo','LineWidth',2)
%plot(X.dnum,Dsta,'ko-');datetick('x')
ylabel('Depth [m]')
xlabel('Latitude')
grid on

%% add SS to proc_info ?


%%

figure(4);clf
ezpc(lat,X.P,log10(X.chi))
hold on
plot(X.lat,-Dsta,'kd-','linewidth',2,'markersize',10)
colorbar
xlabel('Lat')
ylabel('Depth')
ylim([0 nanmax(-Dsta)])
ig=find(~isnan(X.lat));
hf=fill([X.lat(ig) fliplr(X.lat(ig))],-[Dsta(ig) -nanmax(-Dsta(ig))*ones(1,length(Dsta(ig)))],0.75*[1 1 1]);

%%