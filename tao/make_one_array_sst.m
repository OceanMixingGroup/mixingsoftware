function t=make_one_array_sst(fname)
% rearrange processed temperature data into one matrix
% with continuous time stamp and constant time increment
% from the beginning of first deployment through the
% end of the last deployment
% $Revision: 1.2 $ $Date: 2012/10/22 16:25:24 $ $Author: aperlin $	
% Originally A. Perlin

load(fname)
% arrange into one array
temp.time=[];
temp.SST=[];
temp.quality=[];
temp.source=[];
for ii=1:length(t)
    lt=length(temp.time);
    temp.time=[temp.time t(ii).time'];
    temp.quality=[temp.quality t(ii).quality'];
    temp.source=[temp.source t(ii).source'];
    temp.SST=[temp.SST t(ii).SST'];
end
% delete repeating values
[temp.time ind]=unique(temp.time);
temp.SST=temp.SST(:,ind);
temp.quality=temp.quality(:,ind);
temp.source=temp.source(:,ind);
% make continious timestamp with uniform dt
timebase=temp.time(1):round((temp.time(2)-temp.time(1))*24*3600)/24/3600:temp.time(end);
tt.time=timebase;
tt.SST=ones(1,length(timebase))*NaN;
tt.quality=cellstr(repmat('0',length(tt.time),1))';
tt.source=cellstr(repmat('0',length(tt.time),1))';
temp.time=round(temp.time*24*3600)/24/3600;
tt.time=round(tt.time*24*3600)/24/3600;
[c,ia,ib]=intersect(tt.time,temp.time);
tt.SST(:,ia)=temp.SST(:,ib);
tt.quality(:,ia)=temp.quality(:,ib);
tt.source(:,ia)=temp.source(:,ib);
tt.readme=t(1).readme;
t=tt;
idot=strfind(fname,'.');
if~isempty(idot)
    idot=idot(end);
    fname=[fname(1:idot-1) '_array'];
else
    fname=[fname '_array'];
end    
save(fname,'t')