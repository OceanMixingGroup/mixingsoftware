num=input('Enter profile number: ')

for iprof=[num];
q.script.num=iprof;
q.script.prefix='m99a';
q.script.pathname='g:\marlin\'

raw_load

cali_m99a

figure(2)
subplot(911),plot(cal.TIME,-cal.P2);grid
ylabel('Depth [m]')
title(num2str(iprof))
subplot(912),plot(cal.TIME,cal.AX_TILT(1:head.irep.AX:length(cal.AX_TILT)),cal.TIME,cal.AY_TILT(1:head.irep.AY:length(cal.AY_TILT)));grid
ylabel('Tilt [degrees]')
subplot(913),plot(cal.TIME,cal.AZ(1:head.irep.AZ:length(cal.AZ)));grid
ylabel('Az [g]')
subplot(914),plot(cal.TIME,cal.VX(1:head.irep.VX:length(cal.VX)));grid
ylabel('Speed [cm s^{-1}]')
subplot(915),plot(cal.TIME,cal.W1(1:head.irep.W1:length(cal.W1)));grid
ylabel('W1 [volts]')
subplot(916),plot(cal.TIME,cal.T1(1:head.irep.T1:length(cal.T1)));grid
ylabel('T [C]')
subplot(917),plot(cal.TIME,cal.T1P(1:head.irep.T1P:length(cal.T1P)));grid
ylabel('T^\prime')
subplot(918),plot(cal.TIME,cal.S2(1:head.irep.S2:length(cal.S2)));grid
ylabel('S2 [s^{-1}]')
subplot(919),plot(cal.TIME,cal.S3(1:head.irep.S3:length(cal.S3)));grid
ylabel('S3 [s^{-1}]')
xlabel('TIME [seconds]')

end
