function [yd,t0]=dn2yd(dn);
% function [yd,t0]=dn2yd(dn);
% Converts MatLab datenum to a yearday...
%
V = datevec(dn);
t0 = datenum(V(:,1),0,0);
t0 = min(t0);
yd=dn-t0;
