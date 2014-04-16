for iprof=[155];
q.script.num=iprof;
q.script.prefix='B98b';
q.script.pathname='r:\Brns98b\Marlin_1\';
clear cal data

raw_load

cali_br98b


avg=average_data({'VX','T1','T2','T3','T4','T5','P2','C1'},...
   'depth_or_time','time','min_bin',0,'binsize',1,'nfft',256)


% compute other stuff

figure(3)
subplot(411),plot(avg.TIME,-avg.P2);grid
ylabel('Depth [m]')
title(num2str(iprof))
subplot(412),plot(avg.TIME,avg.VX);grid
ylabel('Speed [cm s^{-1}]')
subplot(413),plot(avg.TIME,avg.T1-mean(avg.T1),...,
   avg.TIME,avg.T2-mean(avg.T2),...,
   avg.TIME,avg.T3-mean(avg.T3),...,
   avg.TIME,avg.T4-mean(avg.T4),...,
   avg.TIME,avg.T5-mean(avg.T5));grid
ylabel('T [C]')
subplot(414),plot(avg.TIME,avg.C1-mean(avg.C1));grid
ylabel('C [mmho/cm]')

xlabel('TIME [seconds]')

end
