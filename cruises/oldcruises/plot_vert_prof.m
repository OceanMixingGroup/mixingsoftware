% plot vertical profiles of marlin data

istrt=1; %starting point
iend=length(press); % ending point

orient tall
subplot(131),plot(temp(istrt:iend),-press(istrt:iend));grid
ylabel('Depth [m]')
xlabel('Temperature {C}')
axis([3.6 4.2 -940 -720])
subplot(132),semilogx(eps_filt(istrt:iend),-press(istrt:iend));grid
xlabel('\epsilon [m^2 s^{-3}]')
title('27 August 1998  16:10-17:40')
axis([5.e-11 5.e-8 -940 -720])
set(gca,'xtick',[1e-10,1e-9,1e-8])
subplot(133),semilogx(chi(istrt:iend),-press(istrt:iend));grid
xlabel('\chi [K^2 s^{-1}]')
axis([5.e-11 5.e-8 -940 -720])
set(gca,'xtick',[1e-10,1e-9,1e-8])