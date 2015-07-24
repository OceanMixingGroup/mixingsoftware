function ax=ChiPodTimeseriesPlot(CTD_24hz,chidat)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function h=ChiPodTimeseriesPlot(CTD_24hz,chidat)
%
%
% July 13, 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
xls=[min(CTD_24hz.datenum) max(CTD_24hz.datenum)];
hf=figure(2);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.03, 1,5);

axes(ax(1))
%h(1)=subplot(411);
plot(CTD_24hz.datenum,CTD_24hz.t1)
hold on
plot(chidat.datenum,chidat.cal.T1)
if chidat.Info.isbig
plot(chidat.datenum,chidat.cal.T2-.5)
legend('CTD','chi','chi2-.5','location','best')
else
    legend('CTD','chi','location','best')
end
ylabel('T [\circ C]')
xlim(xls)
datetick('x')
%title(['Cast ' cast_suffix ', ' whSN '  ' datestr(time_range(1),'dd-mmm-yyyy HH:MM') '-' datestr(time_range(2),15) ', ' CTD_list(a).name],'interpreter','none')

grid on

axes(ax(2))
%h(2)=subplot(412);
plot(CTD_24hz.datenum,CTD_24hz.p);
axis ij
ylabel('P [dB]')
xlim(xls)
datetick('x')
grid on

axes(ax(3))
%h(3)=subplot(413);
plot(chidat.datenum,chidat.cal.T1P-.01)
hold on
if chidat.Info.isbig
plot(chidat.datenum,chidat.cal.T2P+.01)
end
ylabel('dT/dt [K/s]')
xlim(xls)
ylim(10*[-1 1])
datetick('x')
grid on

axes(ax(4))
%h(4)=subplot(414);
plot(chidat.datenum,chidat.fspd)
ylabel('fallspeed [m/s]')
xlim(xls)
ylim(3*[-1 1])
datetick('x')
%xlabel(['Time on ' datestr(time_range(1),'dd-mmm-yyyy')])
grid on

axes(ax(5))
plot(chidat.datenum,chidat.AX)
hold on
plot(chidat.datenum,chidat.AZ)
xlim(xls)
datetick('x')
legend('AX','AZ')
grid on

linkaxes(ax,'x');

return
%%