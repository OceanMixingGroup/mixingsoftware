%Script to run the checkout file of FCS to check the sensor voltage levels when it ready for shipping or 
%deployment
%Select the RAW FILE when prompted. Do not select the COMP file.
%This runs [data] = raw_load_solo() and plots the sensor data in volts
%heading pitch and roll angles are plotted in degrees.

%Pavan Vutukur 05/14/18
[data] = raw_load_solo();
load('Z:\fcs\sio_test_feb2019\header\header_FCS002.mat');

cal.T1=head.coef.T1(1)+head.coef.T1(2).*data.T1+head.coef.T1(3).*data.T1.^2;
cal.T2=head.coef.T2(1)+head.coef.T2(2).*data.T2+head.coef.T2(3).*data.T2.^2;
cal.P=head.coef.P(1)+head.coef.P(2).*data.P;
% t_1 = t1.Position(1);
% t_2 = t2.Position(1);
figure(1)
ax(1) = subplot(6,1,1);
plot(data.time,cal.T1,data.time,cal.T2);

legend('T1 (^\circC)','T2 (^\circC)')
title('T: Temperature Sensor');
ylabel('Temp in (^\circC)');
% xlim([t_1,t_2]);
datetick('x','KeepLimits');

ax(2) = subplot(6,1,2);
plot(data.time,data.T1P,data.time,data.T2P);
legend('T1P','T2P');
title('TP: Temperature Differentiator Signal');
ylabel('volts');
% xlim([t_1,t_2]);
datetick('x','KeepLimits');

% ax(3) = subplot(6,1,3);
% plot(data.time,data.W,'green');
% title('W: Pitot Sensor');
% ylabel('volts');
% % xlim([t_1,t_2]);
% datetick('x','KeepLimits');

ax(4) = subplot(6,1,4);
plot(data.time,data.S1,data.time,data.S2);
legend('S1','S2');
title('Shear sensor signals');
ylabel('volts');
% xlim([t_1,t_2]);
datetick('x','KeepLimits');
linkaxes(ax,'x');

% figure(2)
ax(5) = subplot(6,1,5);
plot(data.time,data.AX,'red');
hold on;
plot(data.time,data.AY,'blue');
plot(data.time,data.AZ,'green');

title('Accelerometer');
legend('AX','AY','AZ');
ylabel('Volts');
set(gca,'ylim',[1 2.1])

% xlim([t_1,t_2]);
datetick('x','KeepLimits');

ax(6) = subplot(6,1,6);
plot(data.cmptime,data.compass,'red');
hold on
plot(data.cmptime,data.pitch,'blue')
plot(data.cmptime,data.roll,'k')
title('Digital Compass');
ylabel('Degrees');
legend('Heading','Pitch','Roll');
% xlim([t_1,t_2]);
datetick('x','KeepLimits');

ax(3) = subplot(6,1,3);
plot(data.time,cal.P,'k');
title('P: Pressure sensor')
ylabel('PSI');
% xlim([t_1,t_2]);
datetick('x','KeepLimits');
linkaxes(ax,'x');

