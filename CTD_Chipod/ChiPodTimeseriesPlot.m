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

if chidat.Info.isbig
    ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.005, 1,6);
else
    ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.005, 1,5);
end
%
axes(ax(1))
plot(CTD_24hz.datenum,CTD_24hz.p,'k');
axis ij
ylabel('P [dB]')
xlim(xls)
datetick('x')
grid on
xtloff

%
axes(ax(2))
plot(chidat.datenum,chidat.fspd)
ylabel('fallspeed [m/s]')
xlim(xls)
ylim(2*[-1 1])
datetick('x')
grid on
gridxy
xtloff

%
axes(ax(3))
plot(chidat.datenum,chidat.AX)
hold on
plot(chidat.datenum,chidat.AZ)
xlim(xls)
datetick('x')
legend('AX','AZ')
grid on
xtloff

%
axes(ax(4))
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
grid on
xtloff

%
axes(ax(5))
plot(chidat.datenum,chidat.cal.T1P)
% hold on
% if chidat.Info.isbig
%     plot(chidat.datenum,chidat.cal.T2P+.01)
% end
ylabel('dT/dt [K/s]')
xlim(xls)
ylim(1*[-1 1])
datetick('x')
grid on
gridxy
SubplotLetterMW('T1P')
%
if chidat.Info.isbig

axes(ax(6))
plot(chidat.datenum,chidat.cal.T2P)
ylabel('dT/dt [K/s]')
xlim(xls)
ylim(1*[-1 1])
datetick('x')
grid on
gridxy
SubplotLetterMW('T2P')

%linkaxes([ax(5) ax(6)])
end

%xlabel(['Time on ' datestr(time_range(1),'dd-mmm-yyyy')])

%


linkaxes(ax,'x');

return
%%