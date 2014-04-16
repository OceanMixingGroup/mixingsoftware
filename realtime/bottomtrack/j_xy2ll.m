function [lon,lat]=j_xy2ll(x,y,cenlat);
% function [lon,lat]=j_xy2ll(x,y,cenlat);
% x and y are in meters, and cenlat is in degrees.
  

lon = x/(60*mpernm*cos(cenlat*pi/180));
lat = y/(60*mpernm);
