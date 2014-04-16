function adcp=make_one_array_adcp(fname)
% rearrange processed ADCP data into one matrix
% with continuous time stamp and constant time increment
% from the beggining of first deployment through the
% end of the last deployment
% $Revision: 1.2 $ $Date: 2012/10/22 16:24:54 $ $Author: aperlin $	
% Originally A. Perlin

load(fname)
% arrange into one array
temp.depth=[];ilength=0;
for ii=1:length(adcp)
    temp.depth=union(temp.depth,adcp(ii).depth);
    ilength=ilength+length(adcp(ii).time);
end
temp.depth=temp.depth;
temp.time=[];
temp.u=ones(length(temp.depth),ilength)*NaN;
temp.v=ones(length(temp.depth),ilength)*NaN;
for ii=1:length(adcp)
    lt=length(temp.time);
    temp.time=[temp.time adcp(ii).time];
    for jj=1:length(temp.depth)
       ik=find(adcp(ii).depth==temp.depth(jj));
       if ~isempty(ik)
           temp.u(jj,lt+1:length(temp.time))=adcp(ii).u(ik,:);
           temp.v(jj,lt+1:length(temp.time))=adcp(ii).v(ik,:);
       end
    end
end
% delete repeating values
[temp.time ind]=unique(temp.time);
temp.u=temp.u(:,ind);
temp.v=temp.v(:,ind);
% make continious timestamp with uniform dt
timebase=temp.time(1):round((temp.time(2)-temp.time(1))*24*3600)/24/3600:temp.time(end);
tt.time=timebase;
tt.depth=temp.depth;
temp.time=round(temp.time*24*60)/24/60;
tt.time=round(tt.time*24*60)/24/60;
[c,ia,ib]=intersect(tt.time,temp.time);
tt.u=ones(length(temp.depth),length(timebase))*NaN;
tt.v=ones(length(temp.depth),length(timebase))*NaN;
tt.u(:,ia)=temp.u(:,ib);
tt.v(:,ia)=temp.v(:,ib);
tt.readme=adcp(1).readme;
adcp=tt;
idot=strfind(fname,'.');
if~isempty(idot)
    idot=idot(end);
    fname=[fname(1:idot-1) '_array'];
else
    fname=[fname '_array'];
end    
save(fname,'adcp')