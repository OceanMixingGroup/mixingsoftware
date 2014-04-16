function out=qv_cals1(s1,coeff_s1,fspd)
% function out=qv_cals1(s1,coeff_s1,fspd)
%  Adapted from banal's cal.f
%  This  calibrates raw voltages from shear module
%  to du/dz [1/sec].
%
%  The formula used is:
%
%   du/dz=Ed/(2*sqrt(2)*Gs*Ts*Ss*Rho*FS^2)
%
%  Ed ----------  the A/D AC module voltage output. 
%  Gs ----------  the AC module gain.
%  Ts ----------  the AC module time constant.
%  Ss ----------  the probe sensitivity in volts/dyne/cm^2.
%  Rho ---------  the average seawater density in gr/cm^3.
%  FS -----------  the average fall speed in cm/s.

% set up the parameters:
fsmin=5.0;
rho=1.024;
gs=1.0;
ts=.25;
gdc=coeff_s1(5);
if ~gdc
  gdc=1;
end
ss=coeff_s1(1);
const=gdc*2.*sqrt(2.0)*gs*ts*ss*rho;
fspd=makelen(fspd,length(s1));
warning off
out=s1./(const*fspd.^2);
warning on
out(find(fspd<fsmin))=NaN;
