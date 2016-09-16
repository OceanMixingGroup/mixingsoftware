function h=PlotBinnedCTDprofiles_vstime(datad_1m,datau_1m,castStr)
%%
h=figure;clf
agutwocolumn(1)
wysiwyg
set(gcf,'defaultaxesfontsize',15)
ax = MySubplot(0.15, 0.03, 0.03, 0.06, 0.1, 0.075, 1,3);

axes(ax(1))
plot(datad_1m.datenum,datad_1m.p,'.')
hold on
plot(datau_1m.datenum,datau_1m.p,'.')
%plot(datad_1m.t2,datad_1m.p,'.')
%ylim([0 nanmax(datad_1m.p)])
axis ij
grid on
datetick('x')
%xlabel('Temp [^oC]')
ylabel('Pressure [db]')
set(gcf,'Name',castStr)
%title(ctdlist(icast).name,'interpreter','none')
title(castStr,'fontsize',16,'interpreter','none')
%legend('t1 down','t2 down','t1 up','t2 up','location','Southeast')
%legend('t1 down','t2 down','location','east')
grid on

axes(ax(2))
plot(datad_1m.datenum,datad_1m.t1,'.')
hold on
plot(datau_1m.datenum,datau_1m.t1,'.')
%ylim([0 nanmax(datad_1m.p)])
%legend('t1 up','t2 up','location','east')
%axis ij
grid on
%ytloff
ylabel('Temp [^oC]')
datetick('x')
%xlabel('Temp [^oC]')
%title('upcast','fontsize',16)
grid on

axes(ax(3))
plot(datad_1m.datenum,datad_1m.s1,'.')
hold on
plot(datau_1m.datenum,datau_1m.s1,'.')
%ylim([0 nanmax(datad_1m.p)])
%axis ij
grid on
ylabel('Sal.')
datetick('x')
xlabel([datestr(floor(nanmin(datad_1m.datenum)))])

%ylabel('Pressure [db]')
%legend('s1 down','s2 down','location','east')

% axes(ax(4))
% plot(datau_1m.s1,datau_1m.p,'.')
% hold on
% plot(datau_1m.s2,datau_1m.p,'.')
% ylim([0 nanmax(datad_1m.p)])
% axis ij
% ytloff
% grid on
% xlabel('Sal.')
% %ylabel('Pressure [db]')
% legend('s1 up','s2 up','location','east')
% 
linkaxes(ax,'x')

return
%%