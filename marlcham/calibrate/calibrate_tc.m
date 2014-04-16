function [tc,coef]=qv_caltc(t1,T0,cjc,mini,maxi)
% function [tc,coef]=qv_caltc(t1,T0,cjc,index) determines the calibration
% coefficients for the thermocouple based on the thermisot temperature of a
% range of thermistor indices (index).
if size(cjc,2)==2
  cjc=ch(cjc);
end
if size(T0,2)==2
  T0=ch(T0);
end
if nargin==3
  mini=1;
  maxi=length(cjc);
end

step=20;
lt0=length(T0);
irep=lt0/length(t1);

[b,a]=butter(2,.1./irep);
T0_filt=filtfilt(b,a,T0);
[b,a]=butter(2,.1);
t1_filt=filtfilt(b,a,t1);
[b,a]=butter(2,.02);
cjc=filtfilt(b,a,cjc);
index=mini:step:maxi;
b=regress(t1_filt(index),[ones(size(T0_filt(irep*index))) T0_filt(irep*index) cjc(index)]); 
tc=b(1)+T0*b(2)+makelen(cjc,lt0)*b(3);
coef=[b' 0 1];