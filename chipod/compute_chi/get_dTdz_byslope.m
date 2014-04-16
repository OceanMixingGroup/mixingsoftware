function [dtdz]=get_dTdz_byslope(depth,tmpr,time,ts,tf)
% function [dtdz]=get_dTdz_byslope(depth,tmpr,time,ts,tf)
%   depth=cal.DEPTH
%   tmpr=cal.T1
%   time=cal.TIME
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $
%   
id=find(time>=ts & time<=tf);
[p]=polyfit(depth(id),tmpr(id),1);
dtdz=-p(1);