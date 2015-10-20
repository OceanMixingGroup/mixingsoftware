%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% MakeTransectPoints.m
%
% Script to generate a transects for ROSS parallel to ship 
%
% First corner is set at 45 deg to aft/starboard of ship (so it will go
% away from ship when launched). 'Home' is set to 45deg aft/port of ship.
%
%
% 08/24/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% Parameters
dist_from_ship=1000; % distance from ship to corner of box in m
ship_lat=13 + (20.838/60)% ship position
ship_lon=84 + (6.275/60)
ship_heading=50 % heading (want Ross to go away from ship initially)
%Nrepeats=5 % # times to repeat box

cd /Volumes/scienceparty_share/ROSS

%
%[RANGE,AF,AR]=dist(LAT,LONG)

%[lon2,lat2,a21] = m_fdist(lon1,lat1,a12,s,spheroid)

[lon1,lat1,a21] = m_fdist(ship_lon,ship_lat,ship_heading-90,dist_from_ship)

[lon2,lat2,a21] = m_fdist(lon1,lat1,50,80e3)

%[lon2,lat2,a21] = m_fdist(ship_lon,ship_lat,ship_heading+135,dist_from_ship)

% [lon3,lat3,a21] = m_fdist(ship_lon,ship_lat,ship_heading+45,dist_from_ship)
% 
% [lon4,lat4,a21] = m_fdist(ship_lon,ship_lat,ship_heading-45,dist_from_ship)

[lona,lata,a21] = m_fdist(ship_lon,ship_lat,ship_heading,100)

figure(1);clf
plot(ship_lon,ship_lat,'p','linewidth',3,'markersize',15)
hold on
plot(lon1,lat1,'s','linewidth',3,'markersize',15)
plot(lon2,lat2,'s','linewidth',3,'markersize',15)
% plot(lon3,lat3,'s','linewidth',3,'markersize',15)
% plot(lon4,lat4,'s','linewidth',3,'markersize',15)
legend('ship','wp1','wp2','wp3','wp4','location','best')
xlabel('longitude')
ylabel('latitude')
grid on
line([ship_lon lona],[ship_lat lata])
title(['Made ' datestr(now)])
map_aspectratio(gca)
%%
lonvec=[lon1 ;lon2;];
latvec=[lat1 ;lat2;];
%
Nrepeats=1
% write a text file with waypoints that can be loaded into mission planner
fid=WriteROSSwaypoints_APM([lon1; repmat(lonvec,Nrepeats,1)],[lat1; repmat(latvec,Nrepeats,1)])

%%