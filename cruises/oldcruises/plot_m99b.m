% function to plot m99b data
% usage:  plot_m99b(iprof)
function plot_m99b(num);
for iprof=[num];
q.script.num=iprof;
q.script.prefix='m99b';
q.script.pathname='c:\work\data\raw_data\m99b\marlin\';
global cal data

raw_load

cali_m99b

% compute other stuff

figure(1)
orient tall
subplot(811),plot(cal.TIME,-cal.P2);grid
set(gca,'xticklabel','')
ylabel('Depth [m]')
title(num2str(iprof))
subplot(812),plot(cal.TIME,3.5+cal.AX2_TILT(1:head.irep.AX2:length(cal.AX2_TILT)),cal.TIME,9.5+cal.AY_TILT(1:head.irep.AY:length(cal.AY_TILT)));grid
set(gca,'xticklabel','')
ylabel('Tilt [degrees]')
legend('pitch','roll')
subplot(813),plot(cal.TIME,cal.AZ(1:head.irep.AZ:length(cal.AZ)));grid
set(gca,'xticklabel','')
ylabel('Az [g]')
subplot(814),plot(cal.TIME,cal.VX(1:head.irep.VX:length(cal.VX)));grid
set(gca,'xticklabel','')
ylabel('Speed [cm s^{-1}]')
%subplot(915),plot(cal.TIME,cal.W1(1:head.irep.W1:length(cal.W1)));grid
%ylabel('W1 [volts]')
subplot(815),plot(cal.TIME,cal.T4(1:head.irep.T4:length(cal.T4)));grid
set(gca,'xticklabel','')
ylabel('T [C]')
subplot(816),plot(cal.TIME,cal.T2P(1:head.irep.T2P:length(cal.T2P)));grid
set(gca,'xticklabel','')
ylabel('T^\prime')
subplot(817),plot(cal.TIME,cal.S1(1:head.irep.S1:length(cal.S1)));grid
set(gca,'xticklabel','')
ylabel('S1 [s^{-1}]')
subplot(818),plot(cal.TIME,cal.S3(1:head.irep.S3:length(cal.S3)));grid
ylabel('S3 [s^{-1}]')
xlabel('TIME [seconds]')

end
