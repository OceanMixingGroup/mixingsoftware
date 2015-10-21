function h=PlotBinnedCTDprofiles(datad_1m,datau_1m,ctdlist,icast)
%%
h=figure;clf
agutwocolumn(1)
wysiwyg

subplot(221)
plot(datad_1m.t1,datad_1m.p,'.')
hold on
plot(datad_1m.t2,datad_1m.p,'.')
axis ij
grid on
xlabel('Temp [^oC]')
ylabel('Pressure [db]')
title(ctdlist(icast).name,'interpreter','none')
%legend('t1 down','t2 down','t1 up','t2 up','location','Southeast')
legend('t1 down','t2 down','location','Southeast')

subplot(222)
plot(datau_1m.t1,datau_1m.p,'.')
hold on
plot(datau_1m.t2,datau_1m.p,'.')
legend('t1 up','t2 up','location','Southeast')
axis ij
grid on
xlabel('Temp [^oC]')

subplot(223)
plot(datad_1m.s1,datad_1m.p,'.')
hold on
plot(datad_1m.s2,datad_1m.p,'.')
axis ij
grid on
xlabel('Sal.')
ylabel('Pressure [db]')
legend('s1 down','s2 down','location','best')

subplot(224)
plot(datau_1m.s1,datau_1m.p,'.')
hold on
plot(datau_1m.s2,datau_1m.p,'.')
axis ij
grid on
xlabel('Sal.')
%ylabel('Pressure [db]')
legend('s1 up','s2 up','location','best')

return
%%