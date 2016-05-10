function ax=PlotPixhawkMag(M)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function ax=PlotPixhawkMag(M)
%
% Plot pitch,roll,yaw from Pixhawk Mag logs. 
%
% INPUT
%    M : structure made with ReadPixhawkMagLog.m
%
%------------
% 05/05/16 - A.Pickering 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

figure(1);clf
agutwocolumn(1)
wysiwyg

figure(1);clf
agutwocolumn(1)
wysiwyg

ax1=subplot(311);
plot(M.dnum,M.magX)
datetick('x')
grid on
ylabel('Magx')
title(M.source)

ax2=subplot(312);
plot(M.dnum,M.magY)
datetick('x')
grid on
ylabel('MagY')

ax3=subplot(313);
plot(M.dnum,atan2d(M.magY,M.magX))
datetick('x')
grid on
ylabel('atan2d(magY,magX)')
xlabel(['Time on ' datestr(floor(nanmin(M.dnum)))])

ax=[ax1 ax2 ax3];

linkaxes(ax,'x')

%%