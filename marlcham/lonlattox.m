function [x,y]=lonlattox(lon,lat,lon0,lat0);
%subroutine for plot_panels.m
mpernm=1.85318e3;
dlon = lon-lon0(1);
dlat = lat-lat0(1);
xx = 60*dlon*mpernm*cos(mean(lat0)*pi/180) + sqrt(-1)*60*dlat* ...
  mpernm;

x = real(xx);
y = imag(xx);
return;
