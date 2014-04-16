function pings=fastreadbio(fname,transducerdepth,dx,dz);
% function pings=fastreadbio(fname,transducerdepth,dx,dz);
%
% fname is the biosonics file,
% transducerdepth is the transducer depth in m.
% dx is a decimation factor in pings...
% dz is a vertical decimation factor 

% $Author: aperlin $ $Date: 2008/01/31 20:22:42 $ $Revision: 1.1.1.1 $
  
  
if nargin<2
  transducerdepth=[];
end;
if isempty(transducerdepth)
  transducerdepth=0;
end;

if nargin<3
  dz=1;
end;
if nargin<3
  dx=1;
end;

[pingsin,time,pos,head]=readbiodrv(fname,dx,dz);

pings.head.soundvel = double(head.soundvel)*0.0025+1400;
pings.head.sampleperiod = double(head.sampleperiod)*1e-9;
pings.head.pulselength = double(head.pulselength)*1e-6;
pings.head.pingrate = double(head.pingrate)*1e-3;
pings.head.initialblanking = double(head.initialblanking)/100;
pings.depth = transducerdepth+0.5*pings.head.soundvel*...
    pings.head.sampleperiod*[pings.head.initialblanking+(1:size(pingsin.out,1))]';

% filter & decimate
% x direction first...
pings.sample = double(pingsin.out);
pings.systime = double(pingsin.systime);
pings.depth = pings.depth;

% calculate datenum...
time.datenum = double(time.time)/(24*3600);
time.datenum = time.datenum+datenum(1970,1,1,0,0,0);
time.subseconds=double(time.subseconds);
in = find(time.subseconds>128);
if ~isempty(in)
  time.subsecond(in)= time.subseconds(in)-128;
end;
time.datenum = time.datenum+time.subseconds/(24*3600*100);

if 0
  meandatenum = nanmean(time.datenum');
  meansystime = (nanmean(double(time.systime)')/(1000*24*3600));
  pings.datenum = meandatenum+double(pings.systime)/(1000*24*3600)-meansystime;
end;

pings.datenum = time.datenum(1)+...
    double(pings.systime)/(1000*24*3600)-...
    double(time.systime(1))/(1000*24*3600);

% positon 
if length(pos.systime)>0 % if there is a GPS stream...
    
        %figure out GPS time
    pos.navtime=double(pos.navtime);

    test=diff(pos.navtime);
    ind=find(test<0);
    pos.navtime(ind+1:end)=pos.navtime(ind+1:end)+24.*3600;
    
    [Y,M,D]=datevec(time.datenum(1));
    startdatenum=datenum(Y,M,D);
    
    pos.navtime=pos.navtime./3600./24+startdatenum;
    
    [pos.systime,i] =unique(double(pos.systime));
    pos.lon=double(pos.lon(i))*1e-5/60;
    pos.lat=double(pos.lat(i))*1e-5/60;
    pos.navtime=pos.navtime(i);

    pings.lon = interp1(pos.systime,pos.lon,pings.systime);
    pings.lat = interp1(pos.systime,pos.lat,pings.systime);
    pings.navtime = interp1(pos.systime,pos.navtime,pings.systime);
else % GPS is not connected
    pings.lon=NaN*pings.systime;
    pings.lat=NaN*pings.systime;
    pings.navtime=NaN*pings.systime;
end
    

