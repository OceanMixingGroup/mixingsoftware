% plot data output by save_m98b_avg.m

figure(1)
orient landscape
subplot(5,1,1),plot(time,-press1,time,-press2);grid;datetick
xl=get(gca,'xlim');
axis([xl(1) xl(2) -785 -765])
title('MARLIN')
ylabel('Depth [m]')
subplot(5,1,2),plot(time,fallspd);grid;datetick 
axis([xl(1) xl(2) 55 85])
ylabel('Speed [cm s^{-1}]')
subplot(5,1,3),plot(time,t1);grid;datetick
axis([xl(1) xl(2) 4.0 4.1])
ylabel('Temperature [C]')
subplot(5,1,4),plot(time,axt);grid;datetick
ylabel('mean Pitch')
axis([xl(1) xl(2) -3 3])
subplot(5,1,5),plot(time,ayt);grid;datetick
ylabel('mean Roll')
axis([xl(1) xl(2) -7 -1])
xlabel('13 April 1999 - gmt')
print fig1 -dpsc

figure(2)
orient landscape
subplot(6,1,1),semilogy(time,varaxlo);grid;datetick
ylabel('Low-f Pitch variance')
title('MARLIN')
axis([xl(1) xl(2) 1e-8 1e-3])
subplot(6,1,2),semilogy(time,varaxhi);grid;datetick
ylabel('High-f Pitch variance')
axis([xl(1) xl(2) 1e-7 8e-6])
subplot(6,1,3),semilogy(time,varaylo);grid;datetick
ylabel('Low-f Roll variance')
axis([xl(1) xl(2) 1e-8 1e-3])
subplot(6,1,4),semilogy(time,varayhi);grid;datetick
ylabel('High-f Roll variance')
axis([xl(1) xl(2) 1e-7 8e-6])
subplot(6,1,5),semilogy(time,varazlo);grid;datetick
ylabel('Low-f Heave variance')
axis([xl(1) xl(2) 1e-8 1e-3])
subplot(6,1,6),semilogy(time,varazhi);grid;datetick
ylabel('High-f Heave variance')
axis([xl(1) xl(2) 1e-7 8e-6])
xlabel('13 April 1999 - gmt')
print fig2 -dpsc

figure(3)
orient landscape
subplot(4,1,1),semilogy(time,chi1);grid;datetick
axis([xl(1) xl(2) 1e-11 1e-7])
title('MARLIN')
set(gca,'ytick',[1e-12,1e-11,1e-10])
ylabel('\chi_1')
subplot(4,1,2),semilogy(time,eps1);grid;datetick
axis([xl(1) xl(2) 1e-11 1e-7])
title('MARLIN')
set(gca,'ytick',[1e-10,1e-9,1e-8])
ylabel('\epsilon_1')
subplot(4,1,3),semilogy(time,eps2);grid;datetick
axis([xl(1) xl(2) 1e-11 1e-7])
set(gca,'ytick',[1e-10,1e-9,1e-8])
ylabel('\epsilon_2')
subplot(4,1,4),semilogy(time,eps3);grid;datetick
axis([xl(1) xl(2) 1e-11 1e-7])
set(gca,'ytick',[1e-10,1e-9,1e-8])
ylabel('\epsilon_3')
xlabel('13 April 1999 - gmt')
print fig3 -dpsc