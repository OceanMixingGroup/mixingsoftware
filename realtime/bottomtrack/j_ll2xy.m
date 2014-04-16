function [x,y]=j_ll2xy(lon,lat,cenlat);
% function [x,y]=j_xy2ll(lon,lat,cenlat);
% x and y are in meters, and cenlat is in degrees.
  

x = lon*(60*mpernm*cos(cenlat*pi/180));
y = lat*(60*mpernm);
