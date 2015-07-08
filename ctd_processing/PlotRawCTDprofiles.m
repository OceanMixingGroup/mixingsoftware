function h=PlotRawCTDprofiles(data2,ctdlist,icast)

%%
h=figure;clf

subplot(121)
plot(data2.t1,data2.p,data2.t2,data2.p)
axis ij
ylabel('p [db]')
grid on
xlabel('temp [^oC]')
title(ctdlist(icast).name,'interpreter','none')
legend('t1','t2','location','Southeast')

subplot(122)
plot(data2.c1,data2.p,data2.c2,data2.p)
axis ij
ylabel('p [db]')
grid on
xlabel('cond.')
legend('c1','c2','location','east')

return
%%