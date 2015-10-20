%~~~~~~~~~~~~~~~~~~~~~~
%
% Compare_IMU_to_adcp.m
%
% Compare accelerations etc. from pixhawk IMU to ADCP compass
%
% Maybe use this to determine if there is a time offset btw ADCP and GPS?
%
% * looks like IMU data doesnt go back far enough?
%
% 08/28/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

load('/Volumes/scienceparty_share/ROSS/ROSSIMUinfo.mat')
%
name='Deploy3'
%load('/Volumes/scienceparty_share/ROSS/Deploy1/adcp/Deploy1_beam.mat')
load(['/Volumes/scienceparty_share/ROSS/' name '/adcp/mat/' name '_beam.mat'])
%
load(['/Volumes/scienceparty_share/ROSS/' name '/gps/GPSLOG_' name '.mat'])
%%

figure(1);clf
plot(imu.dnum,imu.xacc/7)
hold on
plot(adcp.mtime,adcp.roll)
datetick('x')

%%

figure(1);clf
plot(imu.dnum,imu.)
hold on
plot(adcp.mtime,adcp.roll)
datetick('x')

%%

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,3);

axes(ax(1))
plot(gps.dnum,gps.Speed*0.5144)
ylim([0 5])
datetick('x')
title('gps speed')

axes(ax(2))
plot(gps.dnum,gps.declat)
datetick('x')
ylabel('lat')
grid on

axes(ax(3))
plot(imu.dnum,atan2d(imu.ymag,imu.xmag))
hold on
plot(adcp.mtime,adcp.heading+135)
plot(gps.dnum,gps.Heading)
legend('imu','adcp','gps','location','best')
grid on
datetick('x')

linkaxes(ax,'x')

%%