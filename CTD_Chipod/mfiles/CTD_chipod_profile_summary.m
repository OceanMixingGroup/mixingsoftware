function ax=CTD_chipod_profile_summary(avg,chi_todo_now,TP)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function ax=CTD_chipod_profile_summary(avg,chi_todo_now,TP)
%
% Make a summary plot of CTD-chipod processing.
%
%--------------------------
% A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

figure;clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.07, 3,2);

axes(ax(1))
plot(log10(abs(avg.dTdz)),avg.P),axis ij
grid on
axis tight
xlabel('log_{10}(avg dTdz)')
ylabel('Depth [m]')
ylim([0 nanmax(avg.P)])

axes(ax(2))
plot(log10(abs(avg.N2)),avg.P),axis ij
grid on
xlabel('log_{10}(avg N^2)')
axis tight
ytloff
ylim([0 nanmax(avg.P)])

axes(ax(3))
plot(TP,chi_todo_now.P),axis ij
grid on
xlabel('dT/dt')
axis tight
xlim(0.75*[-1 1])
ytloff
ylim([0 nanmax(avg.P)])
gridxy

interval=50;
minobs=3;

axes(ax(4))
plot(log10(avg.chi1),avg.P,'.','color',0.5*[1 1 1]),axis ij
hold on
[dataout zout] = binprofile(avg.chi1,avg.P, 0, interval, nanmax(avg.P),minobs);
plot(log10(dataout),zout,'k')
xlabel('log_{10}(avg chi)')
axis tight
xlim([-12 -5])
grid on
ylabel('Depth [m]')
ylim([0 nanmax(avg.P)])

axes(ax(5))
plot(log10(avg.KT1),avg.P,'.','color',0.5*[1 1 1]),axis ij
hold on
[dataout zout] = binprofile(avg.KT1,avg.P, 0, interval, nanmax(avg.P),minobs);
plot(log10(dataout),zout,'k')
axis tight
xlim([-9 0])
xlabel('log_{10}(avg Kt1)')
grid on
ytloff
ylim([0 nanmax(avg.P)])

axes(ax(6))
plot(log10(avg.eps1),avg.P,'.','color',0.5*[1 1 1]),axis ij
hold on
[dataout zout] = binprofile(avg.eps1,avg.P, 0, interval, nanmax(avg.P),minobs);
plot(log10(dataout),zout,'k')
axis tight
xlim([-12 -2])
xlabel('log_{10}(avg eps1)')
grid on
ytloff
ylim([0 nanmax(avg.P)])

linkaxes(ax,'y')

return
%%