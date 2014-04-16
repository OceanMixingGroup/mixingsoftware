function dat = read_levitus_binary(fname);
% function dat = read_levitus_binary(fname);
% reads a Levitus *.r4 file.  
% 
% returns dat.z,dat.lon, dat.lat, and dat.data.   dat.data is
% 180x360x33, i.e., Lat, Lon, Z order.
%
% imagesc(dat.lon,dat.lat,dat.data(:,:,10)) will make an image of
% all the data at 200 m depth.
%
% imagesc(dat.lon,dat.z,squeeze(dat.data(90,:,:))') will plot the
% data at the equator.
%
% imagesc(dat.lat,dat.z,squeeze(dat.data(:,90,:))') is the data
% along 90.5 W.
% For data see: http://ingrid.ldeo.columbia.edu/SOURCES/.LEVITUS/
  
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
% Originally J. Klymak, July 2002

fid=fopen(fname,'r','b');
data=fread(fid,Inf,'real*4');

zgrid = [0 10 20 30 50 75 100 125 150 200 250 300 400:100:1500 1750 ...
	 2000:500:5500];
xgrid = 0.5:359.5;
ygrid = -89.5:89.5;

data=reshape(data,[length(xgrid) length(ygrid) length(zgrid)]);

% OK, this is correct.  However, squeeze(data(:,:,1)) will put the
% longitude data on the x axis...
dat.z=zgrid;
dat.lon=xgrid;
dat.lat=ygrid;
dat.data = NaN*ones(length(ygrid),length(xgrid),length(zgrid));
new = [181:360 1:180];
for i=1:size(data,3)
  dat.data(:,:,i) = data(:,:,i)';
  % OK, and the xorder is kind of bad.
  dat.data(:,:,i) = dat.data(:,new,i);
end;
dat.lon
dat.lon = dat.lon(new);
in= find(dat.lon>180);
dat.lon(in)=dat.lon(in)-360;


