for iprof=[92:92];
q.script.num=iprof;
q.script.prefix='m96b';
q.script.pathname='e:\marlin\marlin\m96b\';
clear cal data

raw_load

cali_marlin

% compute other stuff
cal.VARAZ=(cal.AZ-mean(cal.AZ)).^2; %variance of AZ
head.irep.VARAZ=head.irep.AZ;
make_time_series;
avg=average_data({'FALLSPD','T','P'...
   'epsilon1','epsilon2','varaz'},...
   'depth_or_time','time','min_bin',0,'binsize',2,'nfft',128)
% flag AZ vibrations
idx=find(avg.VARAZ>3.e-05)
avg.EPSILON1(idx)=NaN;
avg.EPSILON2(idx)=NaN;
avg.EPS=(avg.EPSILON1+avg.EPSILON2)./2

%it=1:1:length(data.P);
%cal.TIME=it/slow_samp_rate;

subplot(811),plot(cal.TIME,-cal.P);grid
ylabel('Depth [m]')
title(num2str(iprof))
subplot(812),plot(cal.TIME,cal.AX_TILT(1:head.irep.AX:length(cal.AX_TILT)),cal.TIME,cal.AY_TILT(1:head.irep.AY:length(cal.AY_TILT)));grid
ylabel('Tilt [degrees]')
subplot(813),plot(cal.TIME,cal.AZ(1:head.irep.AZ:length(cal.AZ)));grid
ylabel('Az [g]')
subplot(814),plot(cal.TIME,cal.VX(1:head.irep.VX:length(cal.VX)));grid
ylabel('Speed [cm s^{-1}]')
subplot(815),plot(cal.TIME,cal.T(1:head.irep.T:length(cal.T)));grid
ylabel('T [C]')
subplot(816),plot(cal.TIME,cal.TP(1:head.irep.TP:length(cal.TP)));grid
ylabel('T^\prime')
subplot(817),plot(cal.TIME,cal.S1(1:head.irep.S1:length(cal.S1)));grid
ylabel('S1 [s^{-1}]')
subplot(818),plot(cal.TIME,cal.S2(1:head.irep.S2:length(cal.S2)));grid
ylabel('S2 [s^{-1}]')
xlabel('TIME [seconds]')


end
