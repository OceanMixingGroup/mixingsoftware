%Script to run the checkout file of FCS to check the sensor voltage levels when it ready for shipping or 
%deployment
%Select the RAW FILE when prompted. Do not select the COMP file.
%This runs [data] = raw_load_solo() and plots the sensor data in volts
%heading pitch and roll angles are plotted in degrees.

%Pavan Vutukur 05/14/18
% [data] = raw_load_solo();
% [data] = raw_load_solo('G:\Team Drives\FCS\data\RAW\4003\chi\test\test_RAW_201903061713.002');
paths.in = 'G:\Team Drives\FCS\data\RAW\4003\chi\test2\';
filename = 'test2_RAW_201903141802.002';
filename = 'test2_RAW_201903141844.002';

[data] = raw_load_solo([paths.in, filename]);

if (max(data.time)-min(data.time)) > 365
    dt = .001*round(1000*median(diff(data.time))*3600*24);
    data.time = (-length(data.time):1:-1)*dt/3600/24 + data.time(end);
end

% load('Z:\fcs\sio_test_feb2019\header\header_FCS002.mat');
load('G:\Team Drives\FCS\Systems\Chi\matlab_scripts\header_FCS002.mat');

cal.T1=head.coef.T1(1)+head.coef.T1(2).*data.T1+head.coef.T1(3).*data.T1.^2;
cal.T2=head.coef.T2(1)+head.coef.T2(2).*data.T2+head.coef.T2(3).*data.T2.^2;
cal.P=head.coef.P(1)+head.coef.P(2).*data.P;

%% plot sensor things
figure('position', [2, 42, 766, 740]);
ax(1) = subplot(4,1,1);
plot(data.time,cal.T1, '.', 'markersize', 4); hold on;
plot(data.time,cal.T2, '.', 'markersize', 4);

legend('T1 (^\circC)','T2 (^\circC)')
title('T: Temperature Sensor');
ylabel('Temp in (^\circC)');

ax(2) = subplot(4,1,2);
plot(data.time,data.T1P, '.', 'markersize', 4); hold on;
plot(data.time,data.T2P, '.', 'markersize', 4);
legend('T1P','T2P');
title('TP: Temperature Differentiator Signal');
ylabel('volts');

ax(3) = subplot(4,1,3);
plot(data.time,data.W, '-', 'markersize', 4);
title('W: Pitot Sensor');
ylabel('volts');

ax(4) = subplot(4,1,4);
plot(data.time,data.S1, '.', 'markersize', 4); hold on;
plot(data.time,data.S2, '.', 'markersize', 4);
legend('S1','S2');
title('Shear sensor signals');
ylabel('volts');

linkaxes(ax,'x');
%%
for i=1:4
    h=.9/4;
    axes(ax(i));
    grid on; box on;
    set(ax(i), 'position', [.1, .98-i*h, .8, .89*h]);
    try set(ax(i), 'xlim', xlims); end  % can manually zoom then use xlims = get(gca, 'xlim'); before re-running

    datetick('x', 'keeplimits');
    if i<4, set(ax(i), 'xticklabel', ''); end
end

bdr_savefig2(gcf, paths.in, filename, 'P')
% return

%% plot compass stuff

% figure(2)
figure('position', [740, 42, 766, 740]);
bx(1) = subplot(3,1,1);
plot(data.time,data.AX,'red');
hold on;
plot(data.time,data.AY,'blue');
plot(data.time,data.AZ,'green');
title('Accelerometer');
legend('AX','AY','AZ');
ylabel('Volts')
datetick;

bx(2) = subplot(3,1,2);
plot(data.cmptime,data.compass,'red');
hold on
plot(data.cmptime,data.pitch,'blue')
plot(data.cmptime,data.roll,'k')
title('Digital Compass');
ylabel('Degrees');
legend('Heading','Pitch','Roll');
datetick;

bx(3) = subplot(3,1,3);
plot(data.time,cal.P,'k');
title('P: Pressure sensor')
ylabel('PSI')
datetick;
linkaxes(bx,'x');


for i=1:3
    h=.9/3;
    axes(bx(i));
    grid on;
    set(bx(i), 'position', [.1, .98-i*h, .8, .89*h]);
    try set(bx(i), 'xlim', xlims); end

    datetick('x', 'keeplimits');
    if i<3, set(bx(i), 'xticklabel', ''); end
end

bdr_savefig2(gcf, paths.in, ['2_', filename], 'P')