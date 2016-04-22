function h=PlotBinnedCTDprofiles(datad_1m,datau_1m,castStr)
%%
h=figure;clf
agutwocolumn(1)
wysiwyg
set(gcf,'defaultaxesfontsize',15)
ax = MySubplot(0.15, 0.03, 0.03, 0.06, 0.1, 0.075, 2,2);

axes(ax(1))
plot(datad_1m.t1,datad_1m.p,'.')
hold on
plot(datad_1m.t2,datad_1m.p,'.')
ylim([0 nanmax(datad_1m.p)])
axis ij
grid on
xlabel('Temp [^oC]')
ylabel('Pressure [db]')
set(gcf,'Name',castStr)
%title(ctdlist(icast).name,'interpreter','none')
title('downcast','fontsize',16)
%legend('t1 down','t2 down','t1 up','t2 up','location','Southeast')
legend('t1 down','t2 down','location','east')

axes(ax(2))
plot(datau_1m.t1,datau_1m.p,'.')
hold on
plot(datau_1m.t2,datau_1m.p,'.')
ylim([0 nanmax(datad_1m.p)])
legend('t1 up','t2 up','location','east')
axis ij
grid on
ytloff
xlabel('Temp [^oC]')
title('upcast','fontsize',16)

axes(ax(3))
plot(datad_1m.s1,datad_1m.p,'.')
hold on
plot(datad_1m.s2,datad_1m.p,'.')
ylim([0 nanmax(datad_1m.p)])
axis ij
grid on
xlabel('Sal.')
ylabel('Pressure [db]')
legend('s1 down','s2 down','location','east')

axes(ax(4))
plot(datau_1m.s1,datau_1m.p,'.')
hold on
plot(datau_1m.s2,datau_1m.p,'.')
ylim([0 nanmax(datad_1m.p)])
axis ij
ytloff
grid on
xlabel('Sal.')
%ylabel('Pressure [db]')
legend('s1 up','s2 up','location','east')

linkaxes(ax,'y')

return
%%