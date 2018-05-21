%script to view tpod raw data ...Pavan Vutukur 05/18/2018
[data] = raw_load_tpod()
figure(1)
subplot(2,1,1)
plot(data.time,data.T1,'red')
hold on
plot(data.time,data.T2,'green')
legend('T1','T2')
ylabel('Volts')
title('TPOD T1 and T2 signals');
xlim([data.time(1) data.time(end)]);
datetick('x','KeepLimits');

subplot(2,1,2)
plot(data.time,data.T3,'k')
hold on
plot(data.time,data.T4,'blue')
legend('T3','T4')
ylabel('Volts')
title('TPOD T3 and T4 signals');
xlim([data.time(1) data.time(end)]);
datetick('x','KeepLimits');