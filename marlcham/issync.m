function [data,bad]=issync(data,head,thresh)
% function [data,bad]=issync(data,head,thresh)
%
% this function cuts raw data when sync is lost
% should be callaed from calibration routine (i.e. cali_ct01a.m)
% before doing anything else;
% aftewards check should be put into calibration script that
% cancels it if bad=0 (it means there is no sync data), i.e.
% [data,bad]=issync(data,head);
% if bad==1
%     return;
% end
%
% thresh sets the allowable threshold for sync loss in volts.
% Defaults to 8 V which generally works.

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:46 $ $Author: aperlin $	
% Originally A. Perlin 2001
  
  if nargin<3
    thresh=[];
  end;
  if isempty(thresh)
    thresh=8;
  end;
  

if ~isfield(data,'SYNC');
  warning('No ''SYNC'' field found in data')
  return;
end;
if length(data.SYNC)<3
  % there isn't enough here to even bother checking...
  bad=1:length(data.SYNC);
else;
  dsync = abs(diff(data.SYNC,2));
  bad = find(dsync<thresh);
  if isempty(bad)
    bad=0; 
    return;
  end;
  bad = max(bad(1)-10,1):length(data.SYNC);
  % this loses a few extra points.   But thats OK.   No point in
  % using any bad data...
end;
lastgood = bad(1)-1;

names=fieldnames(data);
for iii=1:length(names)
  dat = getfield(data,names{iii});
  irep = getfield(head.irep,names{iii});
  data = setfield(data,names{iii},dat(1:lastgood*irep));
end

if lastgood<1
  bad=1;  % return one if no good data...
else
  bad=0;
end;

