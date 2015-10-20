%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ReadGPS_RossAsiri.m
%
% Read gps from ROSS deployments into matlab
%
% 09/15/15 - A.Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

addpath /Users/Andy/Cruises_Research/mixingsoftware/ARV/

name='Deploy4';fname='Downloaded 9_8_2015/GPSLOG07.TXT'
%name='Deploy6';fname='Downloaded 9_15_2015/GPSLOG01.TXT'

namefull=fullfile('/Volumes/scienceparty_share/ROSS',name,'gps',fname)
gps=ImportGPSfromSD(namefull)
%
save(['/Volumes/scienceparty_share/ROSS/' name '/gps/GPSLOG_' name],'gps')

orient landscape
print('-dpng','-r300',['/Volumes/scienceparty_share/ROSS/' name '/figures/GPSplot.png'])

%%

figure(1);clf
plot(gps.declon,gps.declat)


%%

kmlwriteline(['/Volumes/scienceparty_share/ROSS/' name '/gps/GPSLOG_' name ],gps.declat,1*gps.declon)
%kmlwrite('/Volumes/scienceparty_share/ROSS/gps/GPSLOG95',gps.declat,1*gps.declon)

%%