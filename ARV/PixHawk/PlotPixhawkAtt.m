function ax=PlotPixhawkAtt(A)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function ax=PlotPixhawkAtt(A)
%
% Plot pitch,roll,yaw from Pixhawk ATT logs. 
%
% INPUT
%    A : structure made with ReadPixhawkAttLog.m
%
%------------
% 05/05/16 - A.Pickering 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

figure(1);clf
agutwocolumn(1)
wysiwyg

ax1=subplot(311);
plot(A.dnum,A.pitch)
datetick('x')
grid on
ylabel('Pitch')
title(A.source)

ax2=subplot(312);
plot(A.dnum,A.roll)
datetick('x')
grid on
ylabel('Roll')

ax3=subplot(313);
plot(A.dnum,A.yaw)
datetick('x')
grid on
ylabel('Yaw')
xlabel(['Time on ' datestr(floor(nanmin(A.dnum)))])

ax=[ax1 ax2 ax3];

linkaxes(ax,'x')

%%