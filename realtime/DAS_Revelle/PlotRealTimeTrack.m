function PlotRealTimeTrack(track);
% function to display underway Revelle data
% called by realtimetrack.m

%% First - deglitch the data
% deglitch air temperature
bad=find(track.at>20 | track.at<5);
track.at(bad)=NaN;
% deglitch humidity
bad=find(track.rh>100 | track.rh<65);
track.rh(bad)=NaN;
% deglitch air pressure
bad=find(track.bp>1025 | track.bp<980);
track.bp(bad)=NaN;
% deglitch windspeed
bad=find(track.tw1>50);
track.tw1(bad)=NaN;
%% Second - calculate wind speed at 10 m and wind stress
% now calculate windspeed at 10m (it is measured at 19m)
track.windspeed10=sw_u10(track.tw1,19);
track.windu=track.windspeed10.*sin(track.ti1*pi/180+pi);
track.windv=track.windspeed10.*cos(track.ti1*pi/180+pi);
% % Wind stress computation, Gill, p.29.
rho_a=1.225; % air density [kg/m^3], Kundu, p.619
Cd=sw_drag(track.windspeed10);
track.tau_wu=rho_a*Cd.*track.windu.*abs(track.windu);
track.tau_wv=rho_a*Cd.*track.windv.*abs(track.windv);
%% third - average data in 20 m bins
av_time=2*20; % averaging time 20 min.
track.bins=track.time(1:av_time:end); good=find(~isnan(track.tau_wu));
track.tau_wu_bin=bindata1d(track.bins,track.time(good),track.tau_wu(good));
track.tau_wv_bin=bindata1d(track.bins,track.time(good),track.tau_wv(good));
track.midbins=track.time(av_time/2:av_time:floor(length(track.time)/av_time)*av_time-1);
y=zeros(size(track.midbins)); %y=[y,0.2];
track.midbins=[track.midbins];
track.tau_wu_bin=[track.tau_wu_bin];
track.tau_wv_bin=[track.tau_wv_bin];
%% Forth - plot the data
figure(79);clf;
tt=[round(track.time(1)) round(track.time(1))+1];
% windstress
sp(1)=subplot(3,2,[1 2]);
q=quiver(track.midbins,y,track.tau_wu_bin,track.tau_wv_bin,2,'.');
set(sp,'xlim',tt);
kdatetick2
axis image
% ylims=get(gca,'ylim');dy=ylims(2)-ylims(1);
yl=get(sp(1),'ylim');
twmin=round(min(track.tau_wv_bin)*1000)/1000;
twmax=round(max(track.tau_wv_bin)*1000)/1000;
if twmin<0 & twmax>0
    set(sp(1),'ytick',[yl(1) 0 yl(2)])
    set(sp(1),'yticklabel',[twmin 0 twmax])
elseif twmin>=0
    set(sp(1),'ytick',[0 yl(2)])
    set(sp(1),'yticklabel',[0 twmax])
elseif twmax<=0
    set(sp(1),'ytick',[yl(1) 0])
    set(sp(1),'yticklabel',[twmin 0])
end       
title(['Shipboard DAS      ' datestr(track.time(2),1)],'fontsize',16);
ylabel('\tau_w [N/m^2]')
wspos=get(sp(1),'position');
% Air Temperature
% sp(2)=subplot('position',[wspos(1) wspos(2)-wspos(4)/1 ...
%         wspos(1)+wspos(3)-0.57 wspos(4)/1.6]);
sp(2)=subplot(3,2,3);
plot(track.time,track.at,'.')
set(sp,'xlim',tt);
set(gca,'ylim',[5 15]);
kdatetick2
ylabel('T_a [^oC]')
atpos=get(sp(2),'position');
% atmospheric pressure
% sp(3)=subplot('position',[0.57 atpos(2) ...
%         wspos(1)+wspos(3)-0.57 atpos(4)]);
sp(3)=subplot(3,2,4);
plot(track.time,track.bp,'.')
set(sp,'xlim',tt);
set(gca,'ylim',[1000 1020]);
kdatetick2
ylabel('P_a [mb]')
% SST
sp(4)=subplot(3,2,5);
plot(track.time,track.tt1,'.')
set(sp,'xlim',tt);
set(gca,'ylim',[10.5 12.5]);
kdatetick2
ylabel('SST [^oC]')
atpos=get(sp(2),'position');
% SS Salinity
sp(5)=subplot(3,2,6);
plot(track.time,track.sa1,'.')
set(sp,'xlim',tt);
set(gca,'ylim',[30.5 33]);
kdatetick2
ylabel('SSS [PSU]')
set(sp,'xminortick','off','yminortick','off')
return;
 

