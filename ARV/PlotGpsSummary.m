%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotGpsSummary.m
%
%
%----------------------
% 04/29/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

figure(1);clf
agutwocolumn(1)
wysiwyg

ax1=subplot(411);
plot(gps.dnum,gps.lat);datetick('x')
ylabel('Latitude','fontsize',15)
grid on
title(gps.DataSource)

ax2=subplot(412);
plot(gps.dnum,gps.lon);datetick('x')
ylabel('Longitude','fontsize',15)
grid on

ax3=subplot(413);
plot(gps.dnum,gps.Speed);datetick('x')
ylabel('Speed [m/s]','fontsize',15)
grid on

ax4=subplot(414);
plot(gps.dnum,gps.Heading,'.');datetick('x')
ylabel('Heading [^o]','fontsize',15)
xlabel(['Time on ' datestr(floor(nanmean(gps.dnum)))],'fontsize',15)
grid on
%
linkaxes([ax1 ax2 ax3 ax4],'x')

%%