function h=PlotBinnedCTDprofiles(datad_1m,datau_1m,ctdlist,icast)
%%
h=figure;clf
subplot(121)
plot(datad_1m.t1,datad_1m.p,'-')
hold on
plot(datad_1m.t2,datad_1m.p,'--')
plot(datau_1m.t1,datau_1m.p,'-')
hold on
plot(datau_1m.t2,datau_1m.p,'--')

axis ij
grid on
xlabel('Temp [^oC]')
ylabel('Pressure [db]')
title(ctdlist(icast).name,'interpreter','none')
legend('t1 down','t2 down','t1 up','t2 up','location','Southeast')

subplot(122)
plot(datad_1m.s1,datad_1m.p,'-')
hold on
plot(datad_1m.s2,datad_1m.p,'--')
plot(datau_1m.s1,datau_1m.p,'-')
hold on
plot(datau_1m.s2,datau_1m.p,'--')
axis ij
grid on
xlabel('Sal.')
ylabel('Pressure [db]')
legend('s1 down','s2 down','s1 up','s2 up','location','west')

return
%%