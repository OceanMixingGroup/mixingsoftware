%%

ship_lat1=13+(19.9/60)
ship_lon1=84+(5.5/60)

ship_lat2=15
ship_lon2=85+(37/60)

%%

[RANGE,ship_heading,AR]=dist([ship_lat1 ship_lat2],[ship_lon1 ship_lon2])

[lon3,lat3,a21] = m_fdist(ship_lon1,ship_lat1,ship_heading,3e3)

figure(1);clf
plot(ship_lon1,ship_lat1,'p','markersize',10)
hold on
plot(ship_lon2,ship_lat2,'p','markersize',10)
plot(lon3,lat3,'go')
plot(lon1,lat1,'d','markersize',10)
hold on
plot(lon2,lat2,'d','markersize',10)

map_aspectratio(gca)

%%

latn=13.3503
lonn=84.09675
plot(lonn,latn,'ro')
shg
%%
dist_from_ship=1000

%[lon1,lat1,a21] = m_fdist(ship_lon1,ship_lat1,ship_heading-90,dist_from_ship)
[lon1,lat1,a21] = m_fdist(lon3,lat3,ship_heading-90,dist_from_ship)
[lon2,lat2,a21] = m_fdist(ship_lon2,ship_lat2,ship_heading-90,dist_from_ship)
%
%%
figure(1);clf
plot(lon1,lat1,'d','markersize',10)
hold on
plot(lon2,lat2,'d','markersize',10)
plot(ship_lon1,ship_lat1,'p','markersize',10)
plot(ship_lon2,ship_lat2,'p','markersize',10)
plot(lon3,lat3,'go')
lonvec=[ lon1 lon2]
latvec=[ lat1 lat2]
fid=WriteROSSwaypoints_APM([lon1 lonvec],[lat1 latvec])

%%
[RANGE,ship_heading,AR]=dist([lat1 lat2],[lon1 lon2])

%%