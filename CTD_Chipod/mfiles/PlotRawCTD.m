function ax=PlotRawCTD(CTD_24hz)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function ax=PlotRawCTD(CTD_24hz)
%
% Simple function to plot raw CTD profiles of t,s during CTD-chipod
% processing
%
%--------------
% A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

figure(1);clf
agutwocolumn(0.8)
wysiwyg

ax1=subplot(311);
plot(CTD_24hz.datenum,CTD_24hz.p)
axis ij
datetick('x')
grid on
title(CTD_24hz.ctd_file,'interpreter','none')
ylabel('Pressure','fontsize',16)
ylim([0 nanmax(CTD_24hz.p)])

ax2=subplot(312);
plot(CTD_24hz.datenum,CTD_24hz.t1)
datetick('x')
ylabel('temp','fontsize',16)
grid on

ax3=subplot(313);
plot(CTD_24hz.datenum,CTD_24hz.c1)
datetick('x')
ylabel('Cond.','fontsize',16)
grid on
xlabel(['Time on ' datestr(floor(nanmin(CTD_24hz.datenum)))],'fontsize',16)

ax=[ax1 ax2 ax3];
linkaxes(ax,'x')

%%