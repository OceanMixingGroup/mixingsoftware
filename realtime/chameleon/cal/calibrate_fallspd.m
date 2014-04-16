function [fspd head]=calibrate_fallspd(in,coeff,ireps,a,b,head)

% This allows for both the "mg" and "global" variations of the
% calibration software:
if nargin==5 | nargin==4 % This is not the functional form of this
                         % function and we need to get the global head.
  global head
end


% first calibrate p based on the raw, unfiltered data.Pressure
temp=calibrate_p(in,coeff);

% flipback the ends to a miximum of 200 pts.
flipsize=min(length(in),200);
len=length(temp);
% the following flips back the ends of a series symmetrically

temp=[2*temp(1)-temp(flipsize:-1:1) ; ...
  temp ; ...
  2*temp(len)-temp(len:-1:(len-flipsize+1))] ;

fspd=100*[0 ; diff(temp)]*head.slow_samp_rate*ireps;
fspd(1)=fspd(2);
  
if nargin>=5
  % filter the series if we have been given filter coefficients
  fspd=filtfilt(b,a,fspd);
end
fspd=fspd((flipsize+1):(flipsize+len));
%if mean(fspd)<0
%  fspd=-fspd;
%end
head.irep.FALLSPD=ireps;