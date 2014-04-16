function rad=make_one_array_rad(fname)
% rearrange processed short wave radiation data into one matrix
% with continuous time stamp and constant time increment
% from the beggining of first deployment through the
% end of the last deployment
% $Revision: 1.1 $ $Date: 2009/04/28 00:03:23 $ $Author: aperlin $	
% Originally A. Perlin

load(fname)
% arrange into one array
ilength=0;
for ii=1:length(rad)
    ilength=ilength+length(rad(ii).time);
end
temp.time=[];
temp.swrad=ones(1,ilength)*NaN;
if isfield(rad,'stdev')
    temp.stdev=ones(1,ilength)*NaN;
end
temp.quality=ones(1,ilength)*NaN;
if isfield(rad,'source')
    temp.source=ones(1,ilength)*NaN;
end
lt=0;
for ii=1:length(rad)
    lr=length(rad(ii).time);
    temp.time(lt+1:lt+lr)=rad(ii).time(:);
    temp.swrad(lt+1:lt+lr)=rad(ii).swrad(:);
    if isfield(rad,'stdev')
        temp.stdev(lt+1:lt+lr)=rad(ii).stdev(:);
    end
    temp.quality(lt+1:lt+lr)=cell2mat(rad(ii).quality(:)); 
    if isfield(rad,'source')
        temp.source(lt+1:lt+lr)=cell2mat(rad(ii).source(:));
    end
    lt=lt+lr;
end
% delete repeating values
[temp.time ind]=unique(temp.time);
temp.swrad=temp.swrad(ind);
if isfield(rad,'stdev')
    temp.stdev=temp.stdev(ind);
end
temp.quality=temp.quality(ind);
if isfield(rad,'source')
    temp.source=temp.source(ind);
end
% make continious timestamp with uniform dt
timebase=temp.time(1):round((temp.time(2)-temp.time(1))*24*3600)/24/3600:temp.time(end);
tt.time=timebase;
tt.swrad=ones(1,length(timebase))*NaN;
if isfield(rad,'stdev')
    tt.stdev=ones(1,length(timebase))*NaN;
end
tt.quality=ones(1,length(timebase))*NaN;
if isfield(rad,'source')
    tt.source=ones(1,length(timebase))*NaN;
end
temp.time=round(temp.time*24*60)/24/60;
tt.time=round(tt.time*24*60)/24/60;
[c,ia,ib]=intersect(tt.time,temp.time);
tt.swrad(ia)=temp.swrad(ib);
if isfield(rad,'stdev')
    tt.stdev(ia)=temp.stdev(ib);
end
tt.quality(ia)=temp.quality(ib);
if isfield(rad,'source')
    tt.source(ia)=temp.source(ib);
end
tt.readme=rad(1).readme;
rad=tt;
idot=strfind(fname,'.');
if~isempty(idot)
    idot=idot(end);
    fname=[fname(1:idot-1) '_array'];
else
    fname=[fname '_array'];
end    
save(fname,'rad')