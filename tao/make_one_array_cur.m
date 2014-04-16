function cur=make_one_array_cur(fname)
% rearrange processed durrent meter data into one matrix
% with continuous time stamp and constant time increment
% from the beginning of first deployment through the
% end of the last deployment
% $Revision: 1.4 $ $Date: 2012/10/22 16:25:01 $ $Author: aperlin $	
% Originally A. Perlin

load(fname)
% arrange into one array
temp.depth=[];ilength=0;
for ii=1:length(cur)
    temp.depth=union(temp.depth,cur(ii).depth);
    ilength=ilength+length(cur(ii).time);
end
temp.depth=temp.depth';
temp.time=[];
temp.u=ones(length(temp.depth),ilength)*NaN;
temp.v=ones(length(temp.depth),ilength)*NaN;
temp.quality=ones(length(temp.depth),ilength)*NaN;
temp.source=ones(length(temp.depth),ilength)*NaN;
for ii=1:length(cur)
    lt=length(temp.time);
    temp.time=[temp.time cur(ii).time'];
    for jj=1:length(temp.depth)
       ik=find(cur(ii).depth==temp.depth(jj));
       if ~isempty(ik)
           temp.u(jj,lt+1:length(temp.time))=cur(ii).u(:,ik);
           temp.v(jj,lt+1:length(temp.time))=cur(ii).v(:,ik);
           temp.quality(jj,lt+1:length(temp.time))=cur(ii).quality(:,ik);
           temp.source(jj,lt+1:length(temp.time))=cur(ii).source(:,ik);
       end
    end
end
% delete repeating values
[temp.time ind]=unique(temp.time);
temp.u=temp.u(:,ind);
temp.v=temp.v(:,ind);
temp.quality=temp.quality(:,ind);
temp.source=temp.source(:,ind);
% make continious timestamp with uniform dt
timebase=temp.time(1):round((temp.time(2)-temp.time(1))*24*3600)/24/3600:temp.time(end);
tt.time=timebase;
tt.depth=temp.depth;
tt.u=ones(length(temp.depth),length(timebase))*NaN;
tt.v=ones(length(temp.depth),length(timebase))*NaN;
tt.quality=ones(length(temp.depth),length(timebase))*NaN;
tt.source=ones(length(temp.depth),length(timebase))*NaN;
temp.time=round(temp.time*24*60)/24/60;
tt.time=round(tt.time*24*60)/24/60;
[c,ia,ib]=intersect(tt.time,temp.time);
tt.u(:,ia)=temp.u(:,ib);
tt.v(:,ia)=temp.v(:,ib);
tt.quality(:,ia)=temp.quality(:,ib);
tt.source(:,ia)=temp.source(:,ib);
tt.readme=cur(1).readme;
cur=tt;
idot=strfind(fname,'.');
if~isempty(idot)
    idot=idot(end);
    fname=[fname(1:idot-1) '_array'];
else
    fname=[fname '_array'];
end    
save(fname,'cur')