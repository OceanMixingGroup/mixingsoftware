for i=[91:95];
q.script.num=i;
q.script.prefix='bc9';
q.script.pathname='e:\raw_data\';
clear cal data

raw_load

cali_bc90

%do other stuff
figure(1)
clf
subplot(181),plot(cal.FALLSPD,-cal.P,'r.','MarkerSize',.1);grid on
xlabel('fall speed [cm/s]')
ylabel('Depth [m]')
subplot(182),plot(cal.T(1:head.irep.T:length(data.T)),-cal.P,'c.','MarkerSize',.1);grid on
xlabel('temperature [C]')
subplot(183),plot(cal.AZ(1:head.irep.AZ:length(cal.AZ)),-cal.P,'m.','MarkerSize',.1);grid on
xlabel('AZ')
subplot(184),plot(cal.AY_TILT(1:head.irep.AY:length(cal.AY_TILT)),-cal.P,'g.',cal.AX_TILT(1:head.irep.AX:length(data.AX)),-cal.P,'b.','MarkerSize',.1);grid on
xlabel('Tilts [deg]')
subplot(185),plot(data.W(1:head.irep.W:length(data.W)),-cal.P,'b.','MarkerSize',.1);grid on
xlabel('w [volts]')
subplot(186),plot(cal1.W(1:head.irep.W:length(data.W)),-cal.P,'b.','MarkerSize',.1);grid on
xlabel('w [cm s^{-1}]')
subplot(187),plot(cal2.W(1:head.irep.W:length(data.W)),-cal.P,'b.','MarkerSize',.1);grid on
xlabel('w [cm s^{-1}]')
subplot(188),plot(cal.S1(1:head.irep.S1:length(data.S1)),-cal.P,'b.','MarkerSize',.1);grid on
xlabel('S1 [s^{-1}]')

figure(2)
plot(cal.FALLSPD,-cal.P,'k.',cal1.W(1:head.irep.W:length(data.W))+q.fspd,-cal.P,'r.','MarkerSize',.1);grid
hold on

figure(3)
plot((cal.FALLSPD).^2,data.W(1:head.irep.W:length(data.W)),'c.','MarkerSize',.1);grid on
xlabel('fallspeed^2 [(cm/s)^2]')
ylabel('w [volts]')
hold on
%figure(3)
%plot(cal.T1,data.W,'m.','MarkerSize',.1);grid on
%xlabel('temperature [C]')
%ylabel('w [volts]')
%hold on
pause
end
