% chipod_checkout
%Plots calibrated sensor data 
%Pavan Vutukur Ocean Mixing Group Oregon State University 12/31/2020
[data,head] = raw_load_chipod(); %load the raw chipod file

%Generate sensor data using calibration coefficients
cal.T1=head.coef.T1(1)+head.coef.T1(2).*data.T1+head.coef.T1(3).*data.T1.^2;
cal.T2=head.coef.T2(1)+head.coef.T2(2).*data.T2+head.coef.T2(3).*data.T2.^2;
cal.P = (head.coef.P(1) + head.coef.P(2).*data.P)./1.47; %dbar

%Plot temperature T1 and T2 
figure(61);clf;clear hax;
hax(1)=subplot(311);
plot(data.datenum(1:2:end),cal.T1);hold on
plot(data.datenum(1:2:end),cal.T2,'r');
legend('T1','T2');
ylabel('T in Celsius');
ylim([0 35]);
datetick;

%Plot temperature differential T1P and T2P
hax(2)=subplot(312);
plot(data.datenum,data.T1P);hold on
plot(data.datenum,data.T2P,'r');
ylabel('TP');
legend('T1P','T2P');
ylim([0 5]);
datetick;

%plot Pressure sensor in dbar
hax(3)=subplot(313);
plot(data.datenum(1:2:end),cal.P);hold on
ylabel('P in dBar');
ylim([0 20]);
datetick;

%Plot Pitot data 
figure(62);clf
hax(4) = subplot(311);
plot(data.datenum(1:2:end),data.W);hold on
% plot(data.datenum(1:2:end),data.WP,'r');
% plot(data.datenum(1:2:end),data.DP3,'b');
ylabel('Pitot');
ylim([0 5]);
% legend('W','WP');
legend('Pitot');
datetick;

%plot accelerometer data in volts
hax(5) = subplot(312);
plot(data.datenum(1:2:end),data.AX);hold on
plot(data.datenum(1:2:end),data.AY,'r');
plot(data.datenum(1:2:end),data.AZ,'k');
legend('ax','ay','az');
ylabel('Acc');
ylim([0 4]);
datetick;

%Plot compass heading data in degrees
hax(6) = subplot(313);
plot(data.datenum(1:20:end),data.CMP./10)
ylabel('CMP');
ylim([0 359]);
datetick;
linkaxes(hax,'x');


