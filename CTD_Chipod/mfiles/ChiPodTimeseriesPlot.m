function ax = ChiPodTimeseriesPlot(CTD_24hz,chidat)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function ax = ChiPodTimeseriesPlot(CTD_24hz,chidat)
%
% Function to make a summary plot of chipod data.
%
% Part of CTD-chipod processing routines.
%
%----------------------------
% 07/13/15 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

xls = [min(CTD_24hz.datenum) max(CTD_24hz.datenum)];

hf=figure;clf
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
ylim([0 nanmax(CTD_24hz.p)])
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
    legend('CTD','T1','T2-.5','location','best');
else
    legend('CTD','chi','location','best');
end

% Fix axis lims if data is off scale
y1=nanmax([-3 nanmin(CTD_24hz.t1)]);
y2=nanmin([40 nanmax(CTD_24hz.t1)]);
ylim([y1 y2])    

ylabel('T [\circ C]')
xlim(xls)
datetick('x')
grid on
xtloff

%
axes(ax(5))
plot(chidat.datenum,chidat.cal.T1P)
ylabel('dT/dt [K/s]')
xlim(xls)
ylim(0.3*[-1 1])
datetick('x')
grid on
gridxy;
SubplotLetterMW('T1P');
%
if chidat.Info.isbig
    
    axes(ax(6))
    plot(chidat.datenum,chidat.cal.T2P)
    ylabel('dT/dt [K/s]')
    xlim(xls)
    ylim(0.3*[-1 1])
    datetick('x')
    grid on
    gridxy;
    SubplotLetterMW('T2P');
    
end


linkaxes(ax,'x');

return
%%