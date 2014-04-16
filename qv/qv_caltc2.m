function [tc,coef]=qv_caltc(t1,T0,cjc,mini,maxi,cjc_cal,tc_cal)
% function [tc,coef]=qv_caltc(t1,T0,cjc,mini,maxi,cjc_cal,tc_cal)
% determines the calibration
% coefficients for the thermocouple based on the thermisot temperature of a
% range of thermistor indices (index).
if size(cjc,2)==2
  cjc=ch(cjc);
end
if size(T0,2)==2
  T0=ch(T0);
end


step=20;
lt0=length(T0);
irep=lt0/length(t1);

[b,a]=butter(2,.1./irep);
T0_filt=filtfilt(b,a,T0);
[b,a]=butter(2,.1);
t1_filt=filtfilt(b,a,t1);
[b,a]=butter(2,.005);
cjc=filtfilt(b,a,cjc);
index=mini:step:maxi;
cjc_temp=cjc_cal*cjc;
tc_cali=(1-7.8e-4*(interp8(t1_filt,2)))*tc_cal;
tc_temp=tc_cali.*(T0_filt);
offset=mean(t1_filt(index)-cjc_temp(index)-tc_temp(index*2))
err=std(t1_filt(index)-cjc_temp(index)-tc_temp(index*2))
%b=regress(t1_filt(index),[ones(size(T0_filt(irep*index))) ...
%      T0_filt(irep*index) cjc(index)]); 

% offset=7.97
% figure(1)
% clf
tc=offset+tc_cali.*(T0)+makelen(cjc_temp,lt0);
% plot(tc(index*2),t1(index))
% figure(3)
% plot(tc_cali)
% figure(2)
b=[offset ; tc_cal ; cjc_cal]
coef=[b' 0 1];
