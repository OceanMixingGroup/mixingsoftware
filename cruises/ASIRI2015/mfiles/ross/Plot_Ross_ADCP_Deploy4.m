%~~~~~~~~~~~~~~~~~~~~~~~
%
% Plot_Ross_ADCP_Deploy4.m
%
% Still not quite right, but getting closer...
%
%
% 09/09/15 - A.P
%~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

load('/Volumes/scienceparty_share/ROSS/Deploy4/adcp/mat/Deploy4_adcp_proc.mat')

% start/end times for the 3 separate legs
t1=datenum(2015,9,7,14,09,42)%
t2=datenum(2015,9,7,21,30,19)
t3=datenum(2015,9,8,5,34,05)
t4=datenum(2015,9,8,9,0,32)

%
id1=isin(vel.dnum,[t1 t2]);
id2=isin(vel.dnum,[t2 t3]);
id3=isin(vel.dnum,[t3 t4]);

%

load('/Volumes/scienceparty_share/data/hdss_bin_all.mat')

%
id1H=isin(sonar.datenum,[t1 t2]);
id2H=isin(sonar.datenum,[t2 t3]);
id3H=isin(sonar.datenum,[t3 t4]);

%%
load('/Volumes/scienceparty_share/data/sentinel_1min.mat')
id1V=isin(V.dnum,[t1 t2]);
id2V=isin(V.dnum,[t2 t3]);
id3V=isin(V.dnum,[t2 t4]);
 
%%

figure(3);clf
subplot(211)
plot(vel.dnum(id1),vel.lat(id1),'k')
hold on
plot(vel.dnum(id2),vel.lat(id2),'r')
plot(vel.dnum(id3),vel.lat(id3),'b')
plot(sonar.datenum(id1H),sonar.lat(id1H),'k--')
plot(sonar.datenum(id2H),sonar.lat(id2H),'r--')
plot(sonar.datenum(id3H),sonar.lat(id3H),'b--')

subplot(212)
plot(vel.dnum(id1),vel.lon(id1))
hold on
plot(vel.dnum(id2),vel.lon(id2))
plot(vel.dnum(id3),vel.lon(id3))
plot(sonar.datenum(id1H),sonar.lon(id1H),'--')
plot(sonar.datenum(id2H),sonar.lon(id2H),'--')
plot(sonar.datenum(id3H),sonar.lon(id3H),'--')

%%
cl=0.75*[-1 1]
yl=[0 70]

figure(1);clf
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 2,3);

axes(ax(1))
ezpc(vel.lat(id1),vel.z,vel.u(:,id1))
caxis(cl)
ylim(yl)

axes(ax(3))
ezpc(vel.lat(id2),vel.z,vel.u(:,id2))
caxis(cl)
ylim(yl)

axes(ax(5))
ezpc(vel.lat(id3),vel.z,vel.u(:,id3))
caxis(cl)
ylim(yl)
%
axes(ax(2))
ezpc(vel.lat(id1),vel.z,vel.v(:,id1))
caxis(cl)
ylim(yl)

axes(ax(4))
ezpc(vel.lat(id2),vel.z,vel.v(:,id2))
caxis(cl)
ylim(yl)

axes(ax(6))
ezpc(vel.lat(id3),vel.z,vel.v(:,id3))
caxis(cl)
ylim(yl)

colormap(bluered)
linkaxes(ax)

%
figure(2);clf
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 2,3);

axes(ax(1))
%ezpc(V.dnum(id1V),V.z,V.u(:,id1V))
ezpc(sonar.lat(id1H),sonar.depths,real(sonar.U(:,id1H)))
caxis(cl)
ylim(yl)

axes(ax(3))
%ezpc(V.dnum(id2V),V.z,V.u(:,id2V))
ezpc(sonar.lat(id2H),sonar.depths,real(sonar.U(:,id2H)))
caxis(cl)
ylim(yl)

axes(ax(5))
%ezpc(V.dnum(id3V),V.z,V.u(:,id3V))
ezpc(sonar.lat(id3H),sonar.depths,real(sonar.U(:,id3H)))
caxis(cl)
ylim(yl)

axes(ax(2))
%ezpc(V.dnum(id1V),V.z,V.u(:,id1V))
ezpc(sonar.lat(id1H),sonar.depths,imag(sonar.U(:,id1H)))
caxis(cl)
ylim(yl)

axes(ax(4))
%ezpc(V.dnum(id2V),V.z,V.u(:,id2V))
ezpc(sonar.lat(id2H),sonar.depths,imag(sonar.U(:,id2H)))
caxis(cl)
ylim(yl)

axes(ax(6))
%ezpc(V.dnum(id3V),V.z,V.u(:,id3V))
ezpc(sonar.lat(id3H),sonar.depths,imag(sonar.U(:,id3H)))
caxis(cl)
ylim(yl)

colormap(bluered)
linkaxes(ax)