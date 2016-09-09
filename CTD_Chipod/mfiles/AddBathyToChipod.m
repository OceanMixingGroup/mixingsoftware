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

% Load structure w/ processed data
load('/Users/Andy/Cruises_Research/ChiPod/IO8S/Data/IO8_XC.mat')

% Get lat/lons
X=XC.SN1013_down_T1

% Plot lat/lons
figure(1);clf
plot(X.lon,X.lat,'o')

%
lonrange=[nanmin(X.lon)-1 nanmax(X.lon)+1]
latrange=[nanmin(X.lat)-1 nanmax(X.lat)+1]
SS=GetSSbathy(lonrange,latrange)


%%

figure(2);clf
ezpc(SS.lon,SS.lat,SS.depth)
xlabel('Longitude')
ylabel('Latitude')
axis xy
hold on
plot(X.lon,X.lat,'ko')
cb=colorbar;
cb.Label.String='Depth [m]';
title('Cruise Track and Bathymetry')

%% Now get vector of points for each station

Dsta=nan*ones(1,length(X.lon));
for i=1:length(X.lon)
   
    [val,Ilon]=nanmin(abs(SS.lon-X.lon(i)));
    [val,Ilat]=nanmin(abs(SS.lat-X.lat(i)));
    Dsta(i)=SS.depth(Ilat,Ilon);
end

%%
figure(3);clf
%plot(1:length(Dsta),Dsta,'ko-')
plot(X.lat,Dsta,'ko-')
%plot(X.dnum,Dsta,'ko-');datetick('x')
ylabel('Depth [m]')

%%

figure(4);clf
ezpc(X.lat,X.P,log10(X.chi))
hold on
plot(X.lat,-Dsta,'kd-','linewidth',2,'markersize',10)
colorbar
xlabel('Lat')
ylabel('Depth')
ylim([0 nanmax(-Dsta)])
ig=find(~isnan(X.lat));
hf=fill([X.lat(ig) fliplr(X.lat(ig))],-[Dsta(ig) -nanmax(-Dsta(ig))*ones(1,length(Dsta(ig)))],0.75*[1 1 1]);

%%