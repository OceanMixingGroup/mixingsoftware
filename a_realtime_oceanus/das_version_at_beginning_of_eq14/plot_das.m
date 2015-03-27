% plot_das.m
%
% 1. load in all of the das data from a cruise
% 2. plot all of the data to see if there are issues


clear

%% load all data

% datadir = '~/GDrive/data/eq14/testing_oceanus_met_data_oct2014/processed/das/';
datadir = '~/GDrive/data/eq14/das/processed/';

dd = dir([datadir '*.mat']);

for ii = 1:length(dd)    
    load([datadir dd(ii).name])
end




%% plot



lw = 2;
bb = [0 0.4470 0.7410];
rr = [0.6350 0.0780 0.1840];
yy = [0.9290 0.6940 0.1250];

% t1 = datenum(2014,9,7);
% t2 = datenum(2014,9,9);
t1 = ashtech.pos_time(1);
t2 = ashtech.pos_time(end);

hf1 = figure(1);
clf
% set(gcf,'position',[2566         184        1432        1038])
set(gcf,'position',[154         114        1493         949])

% plot position
ax(1,1) = subplot(6,2,1);
plot(ashtech.pos_time,ashtech.lat,'linewidth',lw,'color',bb)
ylabel('LAT')
xlim([t1 t2])
datetick('keeplimits'); xlabel('')


ax(1,3) = subplot(6,2,3);
plot(ashtech.pos_time,ashtech.lon,'linewidth',lw,'color',bb)
ylabel('LON')
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
ylim([-110 -109.85])

% plot heading
ax(1,5) = subplot(6,2,5);
plot(ashtech.heading_time,ashtech.heading,'linewidth',lw,'color',bb)
hold on
plot(gyro.time,gyro.heading,'linewidth',lw,'color',rr)
ylabel({'HEADING'})
ylim([0 360])
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
legend('ashtech','gyro/gps','location','southeast')
legend boxoff


% plot wind
% % find hourly means
len = 60*60; % winds are saved every second, so to get hourly means it's 3600 pts
ie = floor(length(wind_adu.time)/len)*len;
wind_adu.timehr = nanmean(reshape(wind_adu.time(1:ie),len,length(wind_adu.time(1:ie))/len));
wind_adu.uhr    = nanmean(reshape(wind_adu.u_t(1:ie),len,length(wind_adu.u_t(1:ie))/len));
wind_adu.vhr    = nanmean(reshape(wind_adu.v_t(1:ie),len,length(wind_adu.v_t(1:ie))/len));
wind_adu.tauhr  = nanmean(reshape(wind_adu.tau(1:ie),len,length(wind_adu.tau(1:ie))/len));
ie = floor(length(wind_gyro.time)/len)*len;
wind_gyro.timehr = nanmean(reshape(wind_gyro.time(1:ie),len,length(wind_gyro.time(1:ie))/len));
wind_gyro.uhr    = nanmean(reshape(wind_gyro.u_t(1:ie),len,length(wind_gyro.u_t(1:ie))/len));
wind_gyro.vhr    = nanmean(reshape(wind_gyro.v_t(1:ie),len,length(wind_gyro.v_t(1:ie))/len));
wind_gyro.tauhr  = nanmean(reshape(wind_gyro.tau(1:ie),len,length(wind_gyro.tau(1:ie))/len));


ax(1,7) = subplot(6,2,7);
plot(wind_adu.timehr,wind_adu.uhr,'linewidth',lw,'color',bb)
hold on
plot(wind_gyro.timehr,wind_gyro.uhr,'linewidth',lw,'color',rr)
plot(wind_adu.time,wind_adu.u_t,'linewidth',1,'color',0.33*(bb+2))
hold on
plot(wind_gyro.time,wind_gyro.u_t,'linewidth',1,'color',0.33*(rr+2))
plot(wind_adu.timehr,wind_adu.uhr,'linewidth',lw,'color',bb)
plot(wind_gyro.timehr,wind_gyro.uhr,'linewidth',lw,'color',rr)
plot(wind_gyro.timehr,wind_gyro.timehr*0,'k','linewidth',1)
ylabel({'EASTWARD';'WIND';'[m s^{-1}]'})
ylim([-1 1]*40)
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
legend('ashtech','gyro/gps','location','northwest')
legend boxoff

ax(1,9) = subplot(6,2,9);
plot(wind_adu.timehr,wind_adu.vhr,'linewidth',lw,'color',bb)
hold on
plot(wind_gyro.timehr,wind_gyro.vhr,'linewidth',lw,'color',rr)
plot(wind_adu.time,wind_adu.v_t,'linewidth',1,'color',0.33*(bb+2))
hold on
plot(wind_gyro.time,wind_gyro.v_t,'linewidth',1,'color',0.33*(rr+2))
plot(wind_adu.timehr,wind_adu.vhr,'linewidth',lw,'color',bb)
plot(wind_gyro.timehr,wind_gyro.vhr,'linewidth',lw,'color',rr)
plot(wind_gyro.timehr,wind_gyro.timehr*0,'k','linewidth',1)
ylabel({'NORTHWARD';'WIND';'[m s^{-1}]'})
ylim([-1 1]*40)
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
legend('ashtech','gyro/gps','location','northwest')
legend boxoff

% wind stress
ax(1,11) = subplot(6,2,11);
plot(wind_adu.timehr,wind_adu.tauhr,'linewidth',lw,'color',bb)
hold on
plot(wind_gyro.timehr,wind_gyro.tauhr,'linewidth',lw,'color',rr)
plot(wind_adu.time,wind_adu.tau,'linewidth',1,'color',0.33*(bb+2))
hold on
plot(wind_gyro.time,wind_gyro.tau,'linewidth',1,'color',0.33*(rr+2))
plot(wind_adu.timehr,wind_adu.tauhr,'linewidth',lw,'color',bb)
plot(wind_gyro.timehr,wind_gyro.tauhr,'linewidth',lw,'color',rr)
ylabel({'WIND STRESS';'\tau';'[N m^{-2}]'})
ylim([0 0.25])
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
xlabel('UTC')
legend('ashtech','gyro/gps','location','northwest')
legend boxoff




% plot met
ax(1,2) = subplot(6,2,2);
plot(met.time,met.T_air,'linewidth',lw,'color',bb)
hold on
plot(met2.time,met2.T_air,'linewidth',lw,'color',rr)
ylabel({'AIR TEMP.';'[^OC]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
legend('metbow','met03stb','location','southeast')
legend boxoff

ax(1,4) = subplot(6,2,4);
plot(met.time,met.T_wetbulb,'linewidth',lw,'color',bb)
hold on
plot(met2.time,met2.T_wetbulb,'linewidth',lw,'color',rr)
ylabel({'WETBULB';'TEMP.';'[^OC]'})
% ylim([10 16])
xlim([t1 t2])
datetick('keeplimits'); xlabel('')

ax(1,6) = subplot(6,2,6);
plot(met.time,met.T_dewpoint,'linewidth',lw,'color',bb)
hold on
plot(met2.time,met2.T_dewpoint,'linewidth',lw,'color',rr)
ylabel({'DEWPOINT';'TEMP.';'[^OC]'})
% ylim([10 16])
xlim([t1 t2])
datetick('keeplimits'); xlabel('')

ax(1,8) = subplot(6,2,8);
plot(met.time,met.RH,'linewidth',lw,'color',bb)
hold on
plot(met2.time,met2.RH,'linewidth',lw,'color',rr)
ylabel({'REL.';'HUMIDITY';'[%]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
ylim([0 100])

ax(1,10) = subplot(6,2,10);
plot(met.time,met.AH,'linewidth',lw,'color',bb)
hold on
plot(met2.time,met2.AH,'linewidth',lw,'color',rr)
ylabel({'ABS.';'HUMIDITY';'[g m^{-3}]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')

ax(1,12) = subplot(6,2,12);
plot(met2.time,met2.P,'linewidth',lw,'color',bb)
ylabel({'PRESSURE';'[hPa]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
xlabel('UTC')





export_fig(['~/GDrive/data/eq14/das/figures/das_' datestr(now+7/24,1) '_nav_wind_met.png'],'-r200')

saveas(hf1,'~/GDrive/data/eq14/das/figures/das_nav_wind_met.fig')

%%

hf2 = figure(2);
clf
% set(gcf,'position',[2566         184        1432        1038])
set(gcf,'position',[154         114        1493         949])


% plot radiation
ax(2,1) = subplot(6,2,1);
plot(rad.time,rad.LW,'linewidth',lw,'color',bb)
ylabel({'longwave';'downwelling';'irradiance';'[W m^{-2}]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')


ax(2,3) = subplot(6,2,3);
plot(rad.time,rad.SW,'linewidth',lw,'color',bb)
ylabel({'shortwave';'downwelling';'irradiance';'[W m^{-2}]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')

% plot par
ax(2,5) = subplot(6,2,5);
plot(par.time,par.parVolts,'linewidth',lw,'color',bb)
ylabel({'PAR';'[volts]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
ylim([0 2])


% plot rain
ax(2,7) = subplot(6,2,7);
plot(rain.time,rain.Volt,'linewidth',lw,'color',bb)
ylabel({'rain';'[volts]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
% ylim([1.6 1.7])


% % plot bow temp
% ax2(7) = subplot(6,2,7);
% plot(temp_bow.time,temp_bow.T,'linewidth',lw)
% ylabel({'BOW TEMP.';'[^oC]'})
% xlim([t1 t2])
% datetick('keeplimits'); xlabel('')


% % plot forward intake temp
% ax2(9) = subplot(6,2,9);
% plot(temp_int.time,temp_int.T,'linewidth',lw,'color',bb)
% ylabel({'FORWARD';'INTAKE';'TEMP.';'[^oC]'})
% xlim([t1 t2])
% datetick('keeplimits'); xlabel('')
% ylim([25 30])




% plot tsg
ax(2,2) = subplot(6,2,2);
plot(temp_int.time,temp_int.T,'linewidth',lw,'color',rr)
hold on
plot(temp_hull.time,temp_hull.T,'linewidth',lw,'color',yy)
plot(tsg.time,tsg.T,'linewidth',lw,'color',bb)
ylabel({'TSG T';'FLOWTHROUGH';'[^oC]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
ylim([26 30])
legend('fwd. intake T','T hull','TSG T','location','southeast')
legend boxoff

ax(2,4) = subplot(6,2,4);
plot(tsg.time,tsg.C,'linewidth',lw,'color',bb)
ylabel({'TSG COND.';'FLOWTHROUGH';'[siemens m^{-1}]'})
ylim([5.3 5.6])
xlim([t1 t2])
datetick('keeplimits'); xlabel('')

ax(2,6) = subplot(6,2,6);
plot(tsg.time,tsg.S,'linewidth',lw,'color',bb)
ylabel({'TSG SALINITY';'FLOWTHROUGH';'[PSU]'})
ylim([32 35])
set(gca,'ytick',30:35)
xlim([t1 t2])
datetick('keeplimits'); xlabel('')


% plot fluorometer
ax(2,8) = subplot(6,2,8);
plot(fluorometer.time,fluorometer.Volt,'linewidth',lw,'color',bb)
ylabel({'FLUOROMETER';'FLOWTHROUGH';'[Volts]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
ylim([0 0.3])

% plot oxygen
ax(2,10) = subplot(6,2,10);
plot(oxygen.time,oxygen.oxygen,'linewidth',lw,'color',bb)
ylabel({'OXYGEN';'FLOWTHROUGH';'[ml l^{-1}]'})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
ylim([4.4 4.6])

% plot forward transmissometer
ax(2,12) = subplot(6,2,12);
plot(trans.time,trans.Volt,'linewidth',lw,'color',bb)
ylabel({'TRANSMISOMOTER';'FLOWTHROUGH';'[Volts]';''})
xlim([t1 t2])
datetick('keeplimits'); xlabel('')
ylim([2 5])
xlabel('UTC')


linkaxes(ax,'x')

export_fig(['~/GDrive/data/eq14/das/figures/das_' datestr(now+7/24,1) '_rad_rain_flowthr.png'],'-r200')

saveas(hf2,'~/GDrive/data/eq14/das/figures/das_rad_rain_flowthr.fig')





