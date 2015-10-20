
%%

clear ; close all

addpath /Users/Andy/Cruises_Research/mixingsoftware/ARV/

gps=ImportGPSfromSD('/Volumes/scienceparty_share/ROSS/Deploy4/gps/Downloaded 9_8_2015/GPSLOG07.TXT')
%
save('/Volumes/scienceparty_share/ROSS/Deploy4/gps/GPSLOG_Deploy4','gps')

orient landscape
print('-dpng','-r300',['/Volumes/scienceparty_share/ROSS/Deploy4/figures/GPSplot.png'])

%%

figure(1);clf
plot(gps.declon,gps.declat)


%%

kmlwriteline('/Volumes/scienceparty_share/ROSS/Deploy4/gps/GPSLOG_Deploy4',gps.declat,1*gps.declon)
%kmlwrite('/Volumes/scienceparty_share/ROSS/gps/GPSLOG95',gps.declat,1*gps.declon)

%%