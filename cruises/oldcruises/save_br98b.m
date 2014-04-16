for iprof=[187];
q.script.num=iprof;
q.script.prefix='B98b';
q.script.pathname='r:\Brns98b\Marlin_1\';
clear cal data

raw_load

cali_br98b

% compute other stuff

figure(3)
subplot(10,1,1),plot(cal.TIME,-cal.P2);grid
ylabel('Depth [m]')
title(num2str(iprof))
subplot(10,1,2),plot(cal.TIME,cal.AX_TILT(1:head.irep.AX:length(cal.AX_TILT)),cal.TIME,cal.AY_TILT(1:head.irep.AY:length(cal.AY_TILT)));grid
ylabel('Tilt [degrees]')
subplot(10,1,3),plot(cal.TIME,cal.AZ(1:head.irep.AZ:length(cal.AZ)));grid
ylabel('Az [g]')
subplot(10,1,4),plot(cal.TIME,cal.VX(1:head.irep.VX:length(cal.VX)));grid
ylabel('speed [cm s^{-1}]')
subplot(10,1,5),plot(cal.TIME,cal.T1(1:head.irep.T1:length(cal.T1)));grid
ylabel('T [C]')
subplot(10,1,6),plot(cal.TIME,cal.T1P(1:head.irep.T1P:length(cal.T1P)));grid
ylabel('T^\prime')
subplot(10,1,7),plot(cal.TIME,cal.S1(1:head.irep.S1:length(cal.S1)));grid
ylabel('S1 [s^{-1}]')
subplot(10,1,8),plot(cal.TIME,cal.S2(1:head.irep.S2:length(cal.S2)));grid
ylabel('S2 [s^{-1}]')
subplot(10,1,9),plot(cal.TIME,cal.S2(1:head.irep.S2:length(cal.S2)));grid
ylabel('S3 [s^{-1}]')
subplot(10,1,10),plot(cal.TIME,cal.W1(1:head.irep.W1:length(cal.W1)));grid
ylabel('w ')

xlabel('TIME [seconds]')

pause(3)
end
