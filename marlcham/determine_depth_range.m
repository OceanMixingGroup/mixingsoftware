function [qmini,qmaxi,got_bottom]=determine_depth_range(qtop)
% determine_depth_range(TOP) is a script to determine the slow-sampled
% indices which correspond to the begining and the end of the range over
% which most quantities will be calibrated.  TOP is the upper limit of the
% range; the bottom is determined using find_bottom


if nargin==0
  qtop=9;
end

global cal data

[qmaxi, got_bottom]=find_bot(cal.P,cal.AZ);
if qmaxi==length(cal.P)
  qmaxi=qmaxi-1;
end
qmaxi=qmaxi-1;

qmini=max(find(cal.P(1:qmaxi)<qtop));
if(isempty(qmini))
  qmini=201;
end
if qmini<201
  qmini=201;
end
if qmaxi<(qmini+256)
  qmaxi=length(data.P)-1;
  qmini=201;
end

