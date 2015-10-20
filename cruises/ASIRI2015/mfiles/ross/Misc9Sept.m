
%%
clear ; close all

load('/Volumes/scienceparty_share/ROSS/Deploy4/gps/GPSLOG_Deploy4.mat')
%%

figure(100);clf

ax1=subplot(311)
plot(gps.dnum,gps.declat)

ax2=subplot(312)
plot(gps.dnum,gps.Speed)

ax3=subplot(313)
plot(adcp.mtime,uross)
hold on
plot(adcp.mtime,vross)

linkaxes([ax1 ax2 ax3],'x')
%%