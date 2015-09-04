hax(1)=subplot(811)
plot(data.P(1:head.irep.P:end))
ylabel('P')

hax(2)=subplot(812)
plot(data.AX(1:head.irep.AX:end),'k');hold on
plot(data.AY(1:head.irep.AY:end),'b')
plot(data.AZ(1:head.irep.AZ:end),'r')
ylabel('A')

hax(3)=subplot(813)
plot(data.TJ(1:head.irep.TJ:end),'k');hold on
plot(data.T2(1:head.irep.T2:end),'b')
ylabel('T')

hax(4)=subplot(814)
plot(data.TP(1:head.irep.TP:end),'k');hold on
ylabel('TP')

hax(5)=subplot(815)
plot(data.W(1:head.irep.W:end));hold on
plot(data.WP(1:head.irep.WP:end),'b')
ylabel('W  WP')

hax(6)=subplot(816)
plot(data.SJ(1:head.irep.SJ:end),'g');hold on
plot(data.S2(1:head.irep.S2:end),'c')
ylabel('S')

hax(7)=subplot(817)
plot(data.COND(1:head.irep.COND:end))
ylabel('C')

hax(8)=subplot(818)
plot(data.SCAT(1:head.irep.SCAT:end))
ylabel('SCAT')

linkaxes(hax,'x')