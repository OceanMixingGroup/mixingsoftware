function [uc,coef]=calibrate_uc(uc,c,mini,maxi,flag)
% function [uc,coef]=calibrate_uc(uc,c,min,max,flag) determines the calibration
% coefficients for the microconductivity sensor based on the N-B 
% conductivity cell over the range of indices from mini to maxi
% Note that C already be calibrated.

if size(uc,2)==2
  uc=ch(uc);
end
step=40;
a=length(uc);
irep_uc=a/length(c);
% first deglitch the series
if nargin==2
  mini=1;
  maxi=length(c);
end
if exist('flag','var')
  if strcmp(lower(flag),'deglitch')
    uc(2:a)=0.5*(uc(1:a-1)+uc(2:a));
  end
end
[b,a]=butter(2,.05./irep_uc);
uc_filt=filtfilt(b,a,uc);
[b,a]=butter(2,.05);
c_filt=filtfilt(b,a,c);
index=mini:step:maxi;
cf=c_filt(index);
ucf=uc_filt(index*irep_uc);
b=regress(cf,[ones(size(ucf)) ucf ucf.^2 ucf.^3]); 
uc=b(1)+uc*b(2)+uc.^2*b(3)+uc.^3*b(4);
coef=[b' 1];
% plot(cf,'r')
% hold on
% plot(b(1)+ucf*b(2)+ucf.^2*b(3)+ucf.^3*b(4));