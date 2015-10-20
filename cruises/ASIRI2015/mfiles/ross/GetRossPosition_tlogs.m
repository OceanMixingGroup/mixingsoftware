%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% GetRossPosition_tlogs.m
%
% **NOTE I think the time might be in local (or whatever time APM planner
% is using)...
%
% Read Ross positions sent over radio in tlogs (so only when we have radio
% comms). Nick reads these into a text file called ROSSGPSinfo.txt (every
% 5mins?) and puts it on science share in the ROSS folder. This script
% reads that into matlab, parses, and plots the recent positions.
%
%
% 08/25/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% clear ; close all

cd /Volumes/scienceparty_share/ROSS

[VarName1,fix_type3,Lat,Lon,alt10030,eph153,epv65535,vel153,cog2579,satellites_visible11] = ReadROSSgpstxt('ROSSGPSinfo.txt',266000,'inf');

%% fix lat/lon (missing dec. point)

lat_ross=nan*ones(size(Lat));
lon_ross=nan*ones(size(Lon));

for a=1:length(Lat)
    
    tmp=num2str(Lat(a));
    lat_ross(a)=str2num([tmp(1:2) '.' tmp(3:end)]) ;
    
    tmp=num2str(Lon(a));
    lon_ross(a)=str2num([tmp(1:2) '.' tmp(3:end)]) ;
    
end

%% parse time-stamp
dnum=nan*ones(1,length(Lat));
for a=1:length(Lat)
    clear yyy mm dd m h s
    
    if length(VarName1{a})==60
        yyyy=str2num(VarName1{a}(1:4));
        mm=str2num(VarName1{a}(6:7));
        dd=str2num(VarName1{a}(9:11));
        h=str2num(VarName1{a}(11:13));
        m=str2num(VarName1{a}(15:16));
        s=str2num(VarName1{a}(18:19));
        
        dnum(a)=datenum(yyyy,mm,dd,h,m,s);
    end
end

disp(['Last position at ' datestr(dnum(end))])

%%
figure(1);clf
subplot(211)
plot(dnum,lon)
datetick('x')
ylabel('Longitude')
title(['Fig made ' datestr(now)])

subplot(212)
plot(dnum,lat_ross)
datetick('x')
ylabel('Latitude')
%%

figure
plot(ross.lon,ross.lat,'o')
%hold on
%plot(lon_ross(end),lat_ross(end),'rx','linewidth',3)
map_aspectratio(gca)
xlabel('Longitude')
ylabel('Latitude')
grid on

%%