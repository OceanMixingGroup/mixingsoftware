%num=input('Enter profile number: ')

for iprof=[161:309];
q.script.num=iprof;
q.script.prefix='m99a';
q.script.pathname='e:\marlin\'

raw_load

cali_m99a

% set yr/month/1st day of month for current data set
yr=1999;
month=4;
day_offset=90;
% convert header time to datenum time and add to cal.TIME
hr=str2num(head.starttime(6:7));
mn=str2num(head.starttime(9:10));
sc=str2num(head.starttime(12:13))+cal.TIME;
dy=str2num(head.starttime(15:17))-day_offset;
marlin_time=datenum(yr,month,dy,hr,mn,sc);

% find coincident location of eps/chi data 
% note averaged data file needs to be loaded
idt=find(time>marlin_time(1) & time<marlin_time(length(marlin_time)));

orient tall
figure(2)
subplot(911),plot(marlin_time,-cal.P2);grid;datetick('x',13)
ylabel('Depth [m]')
title(num2str(iprof))
xl=xlim;
subplot(912),plot(marlin_time,cal.VX(1:head.irep.VX:length(cal.VX)));grid;datetick('x',13)
ylabel('Speed [cm s^{-1}]')
subplot(913),plot(marlin_time,3+cal.AX_TILT(1:head.irep.AX:length(cal.AX_TILT)));grid;datetick('x',13)
ylabel('Pitch [^\circ]')
subplot(914),plot(marlin_time,cal.W1(1:head.irep.W1:length(cal.W1)));grid;datetick('x',13)
ylabel('W1 [volts]')
subplot(915),plot(marlin_time,cal.T1(1:head.irep.T1:length(cal.T1)));grid;datetick('x',13)
ylabel('T [C]')
subplot(916),plot(marlin_time,cal.T1P(1:head.irep.T1P:length(cal.T1P)));grid;datetick('x',13)
ylabel('T^\prime')
subplot(917),semilogy(time(idt),chi1(idt));grid;datetick('x',13);
ylabel('\chi_1')
axis([xl(1) xl(2) 1e-12 1e-8])
subplot(918),plot(marlin_time,cal.S3(1:head.irep.S3:length(cal.S3)));grid;datetick('x',13)
ylabel('S3 [s^{-1}]')
subplot(919),semilogy(time(idt),eps3(idt));grid;datetick('x',13);
ylabel('\epsilon_3')
axis([xl(1) xl(2) 1e-10 1e-7])

xlabel('13 April 1999')

exp=['print fig',num2str(iprof),' -dps'];
eval(exp)

end
