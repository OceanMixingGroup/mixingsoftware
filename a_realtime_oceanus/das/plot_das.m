% plot_das.m
%
% 1. load in all of the das data from a cruise
% 2. plot all of the data to see if there are issues


clear

%% load all data

datadir = '~/GDrive/data/eq14/testing_oceanus_met_data_oct2014/processed/das/';

dd = dir([datadir '*.mat']);

for ii = 1:length(dd)    
    load([datadir dd(ii).name])
end


%% plot

lw = 2;

t1 = datenum(2014,9,7);
t2 = datenum(2014,9,9);

figure(1)
clf
set(gcf,'position',[2566         184        1432        1038])

% plot position
ax(1) = subplot(6,2,1);
plot(ashtech.pos_time,ashtech.lat,'linewidth',lw)
ylabel('LAT')
xlim([t1 t2])
kdatetick; xlabel('')


ax(3) = subplot(6,2,3);
plot(ashtech.pos_time,ashtech.lon,'linewidth',lw)
ylabel('LON')
xlim([t1 t2])
kdatetick; xlabel('')

% plot heading
ax(5) = subplot(6,2,5);
plot(ashtech.heading_time,ashtech.heading,'linewidth',lw)
hold on
plot(gyro.time,gyro.heading,'r','linewidth',lw)
ylabel({'HEADING';'ashtech = blue';'gyro = red'})
ylim([0 360])
xlim([t1 t2])
kdatetick; xlabel('')


% plot fluorometer
ax(7) = subplot(6,2,7);
plot(fluorometer.time,fluorometer.Volt,'linewidth',lw)
ylabel({'FLUOROMETER';'[Volts]'})
xlim([t1 t2])
kdatetick; xlabel('')
ylim([0 1])

% plot oxygen
ax(9) = subplot(6,2,9);
plot(oxygen.time,oxygen.oxygen,'linewidth',lw)
ylabel({'OXYGEN';'[ml ml^{-1}]'})
xlim([t1 t2])
kdatetick; xlabel('')


% plot par
ax(11) = subplot(6,2,11);
plot(par.time,par.parVolts,'linewidth',lw)
ylabel({'PAR';'[volts]'})
xlim([t1 t2])
kdatetick; xlabel('')
ylim([0 2])

% plot met
ax(2) = subplot(6,2,2);
plot(met.time,met.T_air,'linewidth',lw)
hold on
plot(met2.time,met2.T_air,'r','linewidth',lw)
ylabel({'AIR TEMP.';'[^OC]'})
xlim([t1 t2])
kdatetick; xlabel('')

ax(4) = subplot(6,2,4);
plot(met.time,met.T_wetbulb,'linewidth',lw)
hold on
plot(met2.time,met2.T_wetbulb,'r','linewidth',lw)
ylabel({'WETBULB TEMP.';'[^OC]'})
% ylim([10 16])
xlim([t1 t2])
kdatetick; xlabel('')

ax(6) = subplot(6,2,6);
plot(met.time,met.T_dewpoint,'linewidth',lw)
hold on
plot(met2.time,met2.T_dewpoint,'r','linewidth',lw)
ylabel({'DEWPOINT TEMP.';'[^OC]'})
% ylim([10 16])
xlim([t1 t2])
kdatetick; xlabel('')

ax(8) = subplot(6,2,8);
plot(met.time,met.RH,'linewidth',lw)
hold on
plot(met2.time,met2.RH,'r','linewidth',lw)
ylabel({'REL. HUMIDITY';'[%]'})
xlim([t1 t2])
kdatetick; xlabel('')

ax(10) = subplot(6,2,10);
plot(met.time,met.AH,'linewidth',lw)
hold on
plot(met2.time,met2.AH,'r','linewidth',lw)
ylabel({'ABS. HUMIDITY';'[g m^{-3}]'})
xlim([t1 t2])
kdatetick; xlabel('')

ax(12) = subplot(6,2,12);
plot(met2.time,met2.P,'linewidth',lw)
ylabel({'PRESSURE';'[hPa]'})
xlim([t1 t2])
kdatetick; xlabel('')

export_fig('~/GDrive/data/eq14/testing_oceanus_met_data_oct2014/das_variables1.pdf')





figure(2)
clf
set(gcf,'position',[2566         184        1432        1038])

% plot radiation
ax2(1) = subplot(6,2,1);
plot(rad.time,rad.LW,'linewidth',lw)
ylabel({'longwave';'downwelling';'irradiance';'[W m^{-2}]'})
xlim([t1 t2])
kdatetick; xlabel('')


ax2(3) = subplot(6,2,3);
plot(rad.time,rad.SW,'linewidth',lw)
ylabel({'shortwave';'downwelling';'irradiance';'[W m^{-2}]'})
xlim([t1 t2])
kdatetick; xlabel('')


% plot rain
ax2(5) = subplot(6,2,5);
plot(rain.time,rain.Volt,'linewidth',lw)
ylabel({'rain';'[volts]'})
xlim([t1 t2])
kdatetick; xlabel('')
ylim([1.6 1.7])


% plot bow temp
ax2(7) = subplot(6,2,7);
plot(temp_bow.time,temp_bow.T,'linewidth',lw)
ylabel({'BOW TEMP.';'[^oC]'})
xlim([t1 t2])
kdatetick; xlabel('')


% plot forward intake temp
ax2(9) = subplot(6,2,9);
plot(temp_int.time,temp_int.T,'linewidth',lw)
ylabel({'FORWARD INTAKE';'TEMP.';'[^oC]'})
xlim([t1 t2])
kdatetick; xlabel('')
ylim([10 20])

% plot forward transmissometer
ax2(11) = subplot(6,2,11);
plot(trans.time,trans.Volt,'linewidth',lw)
ylabel({'TRANSMISOMOTER';'[Volts]'})
xlim([t1 t2])
kdatetick; xlabel('')
ylim([2 5])


% plot tsg
ax2(2) = subplot(6,2,2);
plot(tsg.time,tsg.T,'linewidth',lw)
ylabel({'TSG T';'[^oC]'})
xlim([t1 t2])
kdatetick; xlabel('')

ax2(4) = subplot(6,2,4);
plot(tsg.time,tsg.C,'linewidth',lw)
ylabel({'TSG COND.';'[siemens m^{-1}]'})
ylim([3.5 4.5])
xlim([t1 t2])
kdatetick; xlabel('')

ax2(6) = subplot(6,2,6);
plot(tsg.time,tsg.S,'linewidth',lw)
ylabel({'TSG SALINITY';'[PSU]'})
ylim([30 34])
set(gca,'ytick',30:35)
xlim([t1 t2])
kdatetick; xlabel('')



% plot wind
ax2(8) = subplot(6,2,8);
plot(wind.time,wind.u_t,'linewidth',lw)
ylabel({'EASTWARD WIND';'[m s^{-1}]'})
ylim([-1 1]*15)
xlim([t1 t2])
kdatetick; xlabel('')


ax2(10) = subplot(6,2,10);
plot(wind.time,wind.v_t,'linewidth',lw)
ylabel({'NORTHWARD WIND';'[m s^{-1}]'})
ylim([-1 1]*15)
xlim([t1 t2])
kdatetick; xlabel('')


export_fig('~/GDrive/data/eq14/testing_oceanus_met_data_oct2014/das_variables2.pdf')






