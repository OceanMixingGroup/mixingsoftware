function d=make_one_array_d(fname)
% rearrange processed density data into one matrix
% with continuous time stamp and constant time increment
% from the beggining of first deployment through the
% end of the last deployment
% $Revision: 1.2 $ $Date: 2012/10/22 16:25:07 $ $Author: aperlin $	
% Originally A. Perlin

% fname = '~/work/chipod_processing/TAO11_140/NOAA_TAO_data/processed/d0n140w_hr';
% fname = '~/ganges/data/tao_array/toNovember2011/hi_res/d0n140w_hr.mat';
load(fname)
% arrange into one array
temp.depth=[];ilength=0;
for ii=1:length(sigma)
    temp.depth=union(temp.depth,sigma(ii).depth);
    ilength=ilength+length(sigma(ii).time);
end
temp.depth=temp.depth';
temp.time=[];
temp.sigma_theta=ones(length(temp.depth),ilength)*NaN;
temp.instrument=[];
temp.quality=[];
temp.source=[];
for ii=1:length(sigma)
    lt=length(temp.time);
    temp.time=[temp.time sigma(ii).time'];
    temp.instrument=[temp.instrument sigma(ii).instrument'];
    temp.quality=[temp.quality sigma(ii).quality'];
    temp.source=[temp.source sigma(ii).source'];
    for jj=1:length(temp.depth)
       ik=find(sigma(ii).depth==temp.depth(jj));
       if ~isempty(ik)
           temp.sigma_theta(jj,lt+1:length(temp.time))=sigma(ii).sigma_theta(:,ik);
       end
    end
end
% delete repeating values
[temp.time ind]=unique(temp.time);
temp.sigma_theta=temp.sigma_theta(:,ind);
temp.instrument=temp.instrument(:,ind);
temp.quality=temp.quality(:,ind);
temp.source=temp.source(:,ind);
% make continious timestamp with uniform dt
timebase=temp.time(1):round((temp.time(2)-temp.time(1))*24*3600)/24/3600:temp.time(end);
tt.time=timebase;
tt.depth=temp.depth;
tt.sigma=ones(length(temp.depth),length(timebase))*NaN;
tt.instrument=cellstr(repmat('0',length(tt.time),length(tt.depth)))';
tt.quality=cellstr(repmat('0',length(tt.time),length(tt.depth)))';
tt.source=cellstr(repmat('0',length(tt.time),length(tt.depth)))';
temp.time=round(temp.time*24*3600)/24/3600;
tt.time=round(tt.time*24*3600)/24/3600;
[c,ia,ib]=intersect(tt.time,temp.time);
tt.sigma_theta(:,ia)=temp.sigma_theta(:,ib);
tt.instrument(:,ia)=temp.instrument(:,ib);
tt.quality(:,ia)=temp.quality(:,ib);
tt.source(:,ia)=temp.source(:,ib);
tt.readme=sigma(1).readme;
d=tt;
idot=strfind(fname,'.');
if~isempty(idot)
    idot=idot(end);
    fname=[fname(1:idot-1) '_array'];
else
    fname=[fname '_array'];
end    
save(fname,'sigma')