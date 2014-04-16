function [along,across]=getalongacross(lon,lat,lon0,lat0,angle,cenlat)
% [along,across]=getalongacross(lon,lat,lon0,lat0,angle,cenlat)

[x,y]=j_ll2xy(lon,lat,cenlat);
[x0,y0]=j_ll2xy(lon0,lat0,cenlat);
x=x-x0;
y=y-y0;
plot(x,y,'.');

r = (x+i*y).*exp(-i*angle);
along = real(r);
across= imag(r);


