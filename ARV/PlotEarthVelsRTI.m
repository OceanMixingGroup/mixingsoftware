function ax=PlotEarthVelsRTI(Vel,whfreq)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ax=PlotEarthVelsRTI(Vel,whfreq)
%
% 08/11/15 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
%yl=[0 nanmax(Vel.(['F' whfreq 'kHz']).bt_range0)]
yl=[0 nanmax(Vel.(['F' whfreq 'kHz']).z)]
figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.05, 0.02, 0.06, 0.1, 0.02, 1,5);

idn=find(Vel.(['F' whfreq 'kHz']).roll<0);
Vel.(['F' whfreq 'kHz']).roll(idn)=Vel.(['F' whfreq 'kHz']).roll(idn)+360;

axes(ax(1))
ezpc(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).z,Vel.(['F' whfreq 'kHz']).u)
hold on
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).bt_range0,'k.')
ylim(yl)
cb=colorbar
cb.Label.String=('ms^{-1}')
ylabel('Depth [m]','fontsize',16)
caxis(1*[-1 1])
datetick('x')
SubplotLetterMW('u')
title([whfreq 'kHz'])
xtloff
grid on

axes(ax(2))
ezpc(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).z,Vel.(['F' whfreq 'kHz']).v)
hold on
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).bt_range0,'k.')
ylim(yl)
cb=colorbar
cb.Label.String=('ms^{-1}')
ylabel('Depth [m]','fontsize',16)
caxis(1*[-1 1])
datetick('x')
SubplotLetterMW('v')
xtloff
grid on

axes(ax(3))
ezpc(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).z,Vel.(['F' whfreq 'kHz']).w)
hold on
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).bt_range0,'k.')
ylim(yl)
cb=colorbar
cb.Label.String=('ms^{-1}')
ylabel('Depth [m]','fontsize',16)
caxis(1*[-1 1])
datetick('x')
SubplotLetterMW('w')
xtloff
grid on

axes(ax(4))
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).pitch)
hold on
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).roll-180)
ylabel('Deg.','fontsize',16)
cb=colorbar;killcolorbar(cb)
%plot(Vel.dnum,Vel.heading)
legend('pitch','roll','location','best')
grid on
datetick('x')
xtloff

axes(ax(5))
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).heading)
hold on
%if isfield(
%plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).btheading,'o')
grid on
ylabel('Deg','fontsize',16)
cb=colorbar;killcolorbar(cb)
datetick('x')
SubplotLetterMW('heading')
legend('mag.','BT','location','best')
xlabel(['Time on ' datestr(floor(nanmin(Vel.(['F' whfreq 'kHz']).dnum)))],'fontsize',16)


linkaxes(ax,'x')

%%