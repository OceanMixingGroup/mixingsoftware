%~~~~~~~~~~~~~~~~~~~~~~~
%
% Plot_Ross_ADCP_Deploy3.m
%
% 
%
% 09/09/15 - A.P
%~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

load('/Volumes/scienceparty_share/ROSS/Deploy3/adcp/mat/Deploy3_adcp_proc_smoothed.mat')


% plot ship ADCP for same time, should be similar

%load('/Volumes/scienceparty_share/data/hdss_bin_all.mat')

%
%idH=isin(sonar.datenum,[nanmin(vel.dnum) nanmax(vel.dnum)]);
%
% figure(1);clf
% plot(vel.lon,vel.lat) 
% hold on
% plot(sonar.lon(idH),sonar.lat(idH))
%
load('/Volumes/scienceparty_share/data/sentinel_1min.mat')
idV=isin(V.dnum,[nanmin(vel.dnum) nanmax(vel.dnum)])
%%
figure(1);clf

ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,4);
yl=[0 70]
cl=0.5*[-1 1]

axes(ax(1))
ezpc(vel.dnum,vel.z,vel.u)
caxis(cl)
colorbar
datetick('x')
ylim(yl)
SubplotLetterMW('ross u')

axes(ax(3))
ezpc(vel.dnum,vel.z,vel.v)
caxis(cl)
colorbar
datetick('x')
ylim(yl)
SubplotLetterMW('ross v')

axes(ax(2))
ezpc(V.dnum(idV),V.z,V.u(:,idV))
%ezpc(sonar.datenum(idH),sonar.depths,real(sonar.U(:,idH)))
caxis(cl)
colorbar
datetick('x')
ylim(yl)
SubplotLetterMW('rev u')

axes(ax(4))
ezpc(V.dnum(idV),V.z,V.v(:,idV))
%ezpc(sonar.datenum(idH),sonar.depths,imag(sonar.U(:,idH)))
caxis(cl)
colorbar
datetick('x')
ylim(yl)
SubplotLetterMW('rev v')

linkaxes(ax)
colormap(bluered)
%%
