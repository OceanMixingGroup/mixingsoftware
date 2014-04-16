% funtcion to plot hm00 data
function plot_hm00(num);
for iprof=[num];
q.script.num=iprof;
q.script.prefix='hm00';
%q.script.pathname='f:\home\marlchamdaq\marlin\';% flipper 
%q.script.pathname='f:\home\raw\marlin\';% althea
q.script.pathname='e:\home\raw\marlin\';% buckshot

global cal data

raw_load

cali_hm00

% assign surface pressure offsets
p1_offset=15;
p2_offset=62;
% assign pitch level offsets
ax1_level=-7.4;
ax2_level=-6.5;
azlevel=-5.4;
% compute other stuff

figure(3);clf
orient tall
subplot(911),plot(cal.TIME,-(p1_offset+cal.P1),cal.TIME,-(p2_offset+cal.P2));grid
set(gca,'xticklabel','')
ylabel('Depth [m]')
title(num2str(iprof))
subplot(912),plot(cal.TIME,-ax1_level+cal.AX1_TILT(1:head.irep.AX1:end), ...
	cal.TIME,-ax2_level+cal.AX2_TILT(1:head.irep.AX2:end), ...
	cal.TIME,-azlevel+cal.AZ_TILT(1:head.irep.AZ:end));grid
set(gca,'xticklabel','')
ylabel('Tilt [degrees]')
legend('pitch1','pitch2','roll')
subplot(913),plot(cal.TIME,cal.AY(1:head.irep.AY:end));grid
set(gca,'xticklabel','')
ylabel('vert.acc. [g]')
subplot(914),plot(cal.TIME,cal.FALLSPD(1:head.irep.FALLSPD:end));grid
set(gca,'xticklabel','')
ylabel('Speed [cm s^{-1}]')
%subplot(915),plot(cal.TIME,cal.W1(1:head.irep.W1:length(cal.W1)));grid
%ylabel('W1 [volts]')
subplot(915),plot(cal.TIME,cal.T1(1:head.irep.T1:end));grid
set(gca,'xticklabel','')
ylabel('T1 [C]')
subplot(916),plot(cal.TIME,cal.T2P(1:head.irep.T2P:end));grid
set(gca,'xticklabel','')
ylabel('T2^\prime')
yslim=[-2 2];
subplot(917),plot(cal.TIME,cal.W1(1:head.irep.W1:end));grid
set(gca,'xticklabel','')
%set(gca,'ylim',yslim)
ylabel('W1 [volts]')
subplot(918),plot(cal.TIME,cal.S2(1:head.irep.S2:end));grid
set(gca,'xticklabel','')
%set(gca,'ylim',yslim)
ylabel('S2 [s^{-1}]')
subplot(919),plot(cal.TIME,cal.S3(1:head.irep.S3:end));grid
%set(gca,'ylim',yslim)
ylabel('S3 [s^{-1}]')
xlabel('TIME [seconds]')

end
