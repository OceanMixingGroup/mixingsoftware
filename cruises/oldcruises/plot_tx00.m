ip=input('enter profile number  ');
for i=[ip];
q.script.num=i;
q.script.prefix='tx00';
q.script.pathname='r:\';
clear cal data

raw_load

cali_tx00

%do other stuff
figure(1);orient tall
clf
ylabel('Depth [m]')
subplot(151),plot(cal.T(1:head.irep.T:length(data.T)),-cal.P,'c','MarkerSize',.1);grid on
xmx=max(cal.T);
xmn=min(cal.T);
dx=xmx-xmn;
yl=ylim;
dy=yl(2)-yl(1);
axis([xmn-0.035*dx xmx+0.035*dx yl])
xlabel('temperature [C]')
ylabel('Depth [m]')
subplot(152),plot(cal.SAL(1:head.irep.SAL:length(cal.SAL)),-cal.P,'m','MarkerSize',.1);grid on
xlabel('salinity [psu]')
xmx=max(cal.SAL);
xmn=min(cal.SAL);
dx=xmx-xmn;
yl=ylim;
dy=yl(2)-yl(1);
axis([xmn-0.035*dx xmx+0.035*dx yl])
title([q.script.prefix,num2str(q.script.num)],'fontsize',14)
subplot(153),plot(cal.SIGTH(1:head.irep.SIGTH:end),-cal.P,'b','MarkerSize',.1);grid on
xlabel('\sigma_\theta')
xmx=max(cal.SIGTH);
xmn=min(cal.SIGTH);
dx=xmx-xmn;
yl=ylim;
dy=yl(2)-yl(1);
axis([xmn-0.035*dx xmx+0.035*dx yl])
subplot(154),plot(cal.S1(1:head.irep.S1:length(data.S1)),-cal.P,'r','MarkerSize',.1);grid on
xlabel('S1 [s^{-1}]')
axis([-.5 .5 yl])
subplot(155),plot(data.SCAT(1:head.irep.SCAT:end),-cal.P,'r','MarkerSize',.1);grid on
xlabel('SCAT [V]')
axis tight
set(gca,'ylim',yl)
%figure(2)
%plot(cal.FALLSPD,-cal.P,'k.',cal1.W(1:head.irep.W:length(data.W))+q.fspd,-cal.P,'r.','MarkerSize',.1);grid
%hold on

%figure(3)
%plot((cal.FALLSPD).^2,data.W(1:head.irep.W:length(data.W)),'c.','MarkerSize',.1);grid on
%xlabel('fallspeed^2 [(cm/s)^2]')
%ylabel('w [volts]')
%hold on
%figure(3)
%plot(cal.T1,data.W,'m.','MarkerSize',.1);grid on
%xlabel('temperature [C]')
%ylabel('w [volts]')
%hold on
%pause
end
