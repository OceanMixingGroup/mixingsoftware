%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotRossVelMap.m
%
% Plot a map with ADPC velocity vectors from ROSS deployments on Aug 2015
% Asiri cruise.
%
% 08/28/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% choose which deployment
name='Deploy1'
name='Deploy2'

% load processed mat file
BaseDir=fullfile('/Volumes/scienceparty_share/ROSS/',name)
FigDir=fullfile(BaseDir,'figures')
load(fullfile(BaseDir,'adcp','mat',[name '_adcp_proc_smoothed.mat']))

% get time limits for continous transects
if strcmp(name,'Deploy1')
% Deploy1
xlt1=datenum(2015,8,24,7,53,0);
xlt2=datenum(2015,8,25,3,7,0);
elseif strcmp(name,'Deploy2')
% limits for NE transect Deploy2
%xlt1=datenum(2015,8,25,23,44,24);
xlt1=datenum(2015,8,26,1,34,7);
xlt2=datenum(2015,8,26,7,38,12);
end

% find indices in this time range
idt=isin(vel.dnum,[xlt1 xlt2]);
% or just use all points
%idt=1:length(vel.dnum);

% depth range to average velocity over
zr=[20 40]
idz=isin(vel.z,zr);
um=nanmean(vel.u(idz,idt));
vm=nanmean(vel.v(idz,idt));

lon=vel.lon(idt);
lat=vel.lat(idt);

% only plot every few minutes
dt_min=10
t2=vel.dnum(idt);
tvec=t2(1): dt_min/60/24 : t2(end);
loni=interp1(t2,lon,tvec);
lati=interp1(t2,lat,tvec);
umi=interp1(t2,um,tvec);
vmi=interp1(t2,vm,tvec);

% now plot velocity vectors on map

figure(1);clf
%lon1=[84 84.5];lat1=[13 13.8]
lon1=[nanmin(vel.lon) nanmax(vel.lon)]+0.25*[-1 1]
lat1=[nanmin(vel.lat) nanmax(vel.lat)]+0.25*[-1.5 1]
lon1=[83.9302   85.0041]
lat1=[ 13.0782   14.3472]
m_proj('mercator','longitude',lon1,'latitude',lat1); %initialize map projection
m_plot(vel.lon,vel.lat)
hold on
scale=0.5

%dtt=60*10 

%[HP, HT]=m_vec(scale,lon(1:dtt:end),lat(1:dtt:end),um(1:dtt:end,1:dtt:end),vm(1:dtt:end,1:dtt:end),0.5*[1 1 1],'shaftwidth',3,'headwidth',15,'edgecolor',0.2*[1 1 1]);
[HP, HT]=m_vec(scale,loni,lati,umi,vmi,0.5*[1 1 1],'shaftwidth',3,'headwidth',15,'edgecolor',0.2*[1 1 1]);

% plot a scale arrow
[Hs, Hs]=m_vec(scale,lon1(1)+0.05,lat1(end)-0.05,0.5,0,0.5*[1 1 1],'shaftwidth',2,'headwidth',15);%,'edgecolor',0.2*[1 1 1]) 
m_text(lon1(1)+0.05,lat1(end)-0.1,'0.5m/s')

ht=m_text(nanmean(lon1)-0.2,lat1(1)+0.15,[datestr(tvec(1))],'Color','g','Fontweight','bold')
m_text(nanmean(lon1)-0.2,lat1(1)+0.1,[datestr(tvec(end))],'Color','r','Fontweight','bold')
m_grid('box','fancy')%,
m_plot(loni(1),lati(1),'go','linewidth',5,'markersize',15)
m_plot(loni(end),lati(end),'rx','linewidth',5,'markersize',15)
title(['Ross ' name ' ' num2str(zr(1)) '-' num2str(zr(2)) 'm mean'])
xlabel('Longitude')
ylabel('Latitude')
%
print(fullfile(FigDir,['ross_' name '_VelMap']),'-dpng')
%
print(fullfile('/Volumes/scienceparty_share/figures',['ross_' name '_VelMap']),'-dpng')

%% plot pipestring vectors also

load('/Volumes/scienceparty_share/data/pipestring_1min.mat')

clear id idz lons lats ums vms
id=isin(P.dnum,[xlt1 xlt2]);
idz=isin(P.z,zr);

%subplot(2,2,2)
%
dtt=15
hold on
lons=P.lon(id);
lats=P.lat(id);
ums=nanmean(P.u(idz,id));
vms=nanmean(P.v(idz,id));

m_proj('mercator','longitude',lon1,'latitude',lat1); %initialize map projection

[Hpipe, HT]=m_vec(scale,lons(1:dtt:end),lats(1:dtt:end),ums(1:dtt:end),vms(1:dtt:end),'g','shaftwidth',3,'headwidth',15,'edgecolor',0.2*[1 1 1]) 
m_grid('box','fancy')%,'linestyle','none')%,'xticklabels',[],'yticklabels',[]);
shg

%% try plotting ship ADCP also

load('/Volumes/scienceparty_share/data/os150nb_uv.mat')
id=isin(S.datenum,[xlt1 xlt2]);
%
dtt=2
hold on
lons=S.lon(id);
lats=S.lat(id);
ums=nanmean(S.u(2:5,id));
vms=nanmean(S.v(2:5,id));

m_proj('mercator','longitude',lon1,'latitude',lat1); %initialize map projection
[Hship, HT]=m_vec(scale,lons(1:dtt:end),lats(1:dtt:end),ums(1:dtt:end),vms(1:dtt:end),'g','shaftwidth',3,'headwidth',15,'edgecolor',0.2*[1 1 1]) 
m_grid('box','fancy')%,'linestyle','none')%,'xticklabels',[],'yticklabels',[]);
shg

%%