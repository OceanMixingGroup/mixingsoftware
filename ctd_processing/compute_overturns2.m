function [Epsout,Lmin,Lot,runlmax,Lttot]=compute_overturns2(p,t,s,lat,usetemp,minotsize,sigma,runlmin);

%compute_overturns.m
%
% calculate overturns from a variety of instruments
% p,t,s are vectors of pressure, temperature and salinity typically from downcast only
% usetemp set to 1 to use temperature to compute overturns, otherwise uses density
% minotsize is the minimum overturn size to consider (too small and may be noise)
% sigma is noise level for density. 
% runlmin is run length minimum. 
%
% same as compute_overturns.m but input is salinity instead of conductivity
% becuase sometimes salinity has been separately despiked already
% 
warning off
%% set defaults
if ~exist('usetemp')|isempty(usetemp); usetemp=0; end
if ~exist('lat')|isempty(lat); lat=30; end
if ~exist('minotsize')|isempty(minotsize); minotsize=2; end
if ~exist('sigma')|isempty(sigma); sigma=5e-4; end
if ~exist('runlmin')|isempty(runlmin); runlmin=0; end

%% make potential density and temp at reference depths
% Use one depth if total depth range <1200 m (e.g. fast ctd), but use
% several depth reference levels for a broader range (e.g. shipboard ctd)

if (max(p)-min(p))>1500
    dref=1000; refd=(min(p)+dref/2):dref:max(p);
else
    refd=(min(p)+max(p))/2; dref=(max(p)-min(p))+1;
end

%% 
Epsout=NaN*p(:);
Lmin=NaN*t; Lot=NaN*t; Lttot=Lot;


for iref=1:length(refd)
    
%s = sw_salt(c(:)*10/sw_c3515,t(:),p(:));    
pden = sw_pden(s(:),t(:),p(:),refd(iref));
ptmp = sw_ptmp(s(:),t(:),p(:),refd(iref));

if usetemp
    V=ptmp;
else
    V=pden;
end

[xx,isort]=sort(pden);
% smoothed nsq profile
%if length(t)>600
%    a=1; b=ones(200,1)/200;
%    [n2,q,p_ave] = sw_bfrq(nanfilt(b,a,s),nanfilt(b,a,t),p,lat);
%elseif length(t)>300
%    a=1; b=ones(100,1)/100;
%    [n2,q,p_ave] = sw_bfrq(nanfilt(b,a,s),nanfilt(b,a,t),p,lat);
%else
    a=1; b=ones(10,1)/10;
    [n2,q,p_ave] = sw_bfrq(nanfilt(b,a,s(isort)),nanfilt(b,a,t(isort)),p,lat);
%end
ig=find(~isnan(pden));

p0=p(:);  % full depth
pg=p(ig); ptmp=ptmp(ig); pden=pden(ig); V=V(ig);

%
pg=pg(:);


sig = sign(nanmedian(diff(V)));

[tsort,ind]=sort(sig*V); 
tsort=sig*V;
psort = pg(ind);
dz = pg-psort;
  
csdz = cumsum(-dz);
thresh = 0.0000001;
  
  start = find(csdz(1:end-1)<thresh & csdz(2:end)>=thresh)+1;
  if dz(1)<0
    start = [1;start];
  end;
  stops = find(csdz(1:end-1)>=thresh & csdz(2:end)<thresh)+1;
  Otnsq = NaN*dz; Lt=NaN*dz;
  Lmin0=NaN*pg; Lot0=NaN*pg; runlmax0=Lmin0;R0tot=Lmin0;
  for j = 1:length(start);
    ind=clip([(start(j)-1):(stops(j)+1)],1,prod(size(dz)));
    indp=find(p_ave>min(pg(ind))&p_ave<max(pg(ind))); 
    n2avg=nanmean(n2(indp)); 
    warning off
    delz=abs(max(pg(ind))-min(pg(ind)));
    drhodz=(max(pden(ind))-min(pden(ind)))/delz;
    % run length
    stopnow=0; runl=1;  
    ig=find(diff(sign(dz(ind)))==0);
    if ~isempty(ig)
        runl=runl+1;
        ig2=find(diff(ig)==1); 
        while stopnow==0
            if isempty(ig2)
                stopnow=1;
            else
                ig2=find(diff(ig2)==1);
                runl=runl+1;
            end
        end
    end
    runlmax0(ind)=runl;     
    Lmin0(ind)=2*9.8/n2avg*sigma/1027;
    Lot0(ind)=(max(pg(ind))-min(pg(ind)));
    drho=(max(pden(ind))-min(pden(ind)));
%    if (delz>minotsize)&  (length(ind)>(10*(sigma/drho)^2))  % jody's suggestion
    % additional test from Gargett and Garner 08 
    Lpos=length(find((V(ind)-sort(V(ind)))>0)); Lneg=length(find((V(ind)-sort(V(ind)))<0));
    R0=min(Lpos/length(ind),Lneg/length(ind));
     
    if (delz>minotsize)&(delz>(2*9.8/n2avg*sigma/1027))&((max(pden(ind))-min(pden(ind)))>(2*sigma))...
            &runl>runlmin&(max(abs(V(ind)-sort(V(ind))))>2*sigma)&R0>0.2
        Otnsq(ind) = 9.8./mean(pden(ind)).*drhodz; temptemp(j)=(max(pg(ind))-min(pg(ind))); Lt(ind)=sqrt(mean(dz(ind).^2));
        R0tot(ind)=R0;
    else
        Otnsq(ind)=NaN; Lmin0(ind)=NaN; Lot0(ind)=NaN; Lt(ind)=NaN; R0tot(ind)=NaN;
    end
  end;
  iz=find(p0>(refd(iref)-dref/2)&p0<=(refd(iref)+dref/2)); 

  [xxx,iun]=unique(pg); Lt=Lt(:);
  Lttot(iz)=interp1(pg(iun),Lt(iun),p0(iz));
  Epsout(iz) = interp1(pg(iun),0.64*Lt(iun).^2.*sqrt(Otnsq(iun)).^3,p0(iz));;
  Lmin(iz)=interp1(pg(iun),Lmin0(iun),p0(iz)); Lot(iz)=interp1(pg(iun),Lot0(iun),p0(iz));
  runlmax(iz)=interp1(pg(iun),runlmax0(iun),p0(iz));
  
  Epsout(isnan(Epsout))=1e-11;
  
  
  
end

