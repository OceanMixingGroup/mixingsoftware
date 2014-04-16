function t=make_one_array_t(fname)
% rearrange processed temperature data into one matrix
% with continuous time stamp and constant time increment
% from the beggining of first deployment through the
% end of the last deployment
% $Revision: 1.3 $ $Date: 2012/10/22 16:25:12 $ $Author: aperlin $	
% Originally A. Perlin

load(fname)
% arrange into one array
temp.depth=[];ilength=0;
for ii=1:length(t)
    temp.depth=union(temp.depth,t(ii).depth);
    ilength=ilength+length(t(ii).time);
end
temp.depth=temp.depth';
temp.time=[];
temp.t=ones(length(temp.depth),ilength)*NaN;
temp.quality=[];
temp.source=[];
for ii=1:length(t)
    lt=length(temp.time);
    temp.time=[temp.time t(ii).time'];
    temp.quality=[temp.quality t(ii).quality'];
    temp.source=[temp.source t(ii).source'];
    for jj=1:length(temp.depth)
       ik=find(t(ii).depth==temp.depth(jj));
       if ~isempty(ik)
           temp.t(jj,lt+1:length(temp.time))=t(ii).t(:,ik);
       end
    end
end
% delete repeating values
[temp.time ind]=unique(temp.time);
temp.t=temp.t(:,ind);
temp.quality=temp.quality(:,ind);
temp.source=temp.source(:,ind);
% make continious timestamp with uniform dt
timebase=temp.time(1):round((temp.time(2)-temp.time(1))*24*3600)/24/3600:temp.time(end);
tt.time=timebase;
tt.depth=temp.depth;
tt.t=ones(length(temp.depth),length(timebase))*NaN;
tt.quality=cellstr(repmat('0',length(tt.time),length(tt.depth)))';
tt.source=cellstr(repmat('0',length(tt.time),length(tt.depth)))';
temp.time=round(temp.time*24*3600)/24/3600;
tt.time=round(tt.time*24*3600)/24/3600;
[c,ia,ib]=intersect(tt.time,temp.time);
tt.t(:,ia)=temp.t(:,ib);
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