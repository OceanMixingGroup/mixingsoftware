% plot data output by save_m98b_avg.m

figure(1)
orient landscape
subplot(5,1,1),plot(time,-press,'c');grid;datetick
xl=get(gca,'xlim');
axis([xl(1) xl(2) -765 -725])
title('MARLIN tow - Oregon continental slope','fontsize',18)
ylabel('Depth [m]')
subplot(5,1,2),plot(time,fallspd,'g');grid;datetick 
axis([xl(1) xl(2) 55 85])
ylabel('Speed [cm s^{-1}]')
subplot(5,1,3),plot(time,temp,'m');grid;datetick
axis([xl(1) xl(2) 4.1 4.18])
ylabel('Temperature [C]')
set(gca,'ytick',[4.12 4.14 4.16])
subplot(5,1,4),semilogy(time,chi,'r');grid;datetick
axis([xl(1) xl(2) 1e-11 1e-7])
set(gca,'ytick',[1e-10,1e-9,1e-8])
ylabel('\chi')
subplot(5,1,5),semilogy(time,eps);grid;datetick
axis([xl(1) xl(2) 1e-11 1e-7])
set(gca,'ytick',[1e-10,1e-9,1e-8])
ylabel('\epsilon')
xlabel('27 August 1998 - PDT','fontsize',16)
print fig1 -dpsc

