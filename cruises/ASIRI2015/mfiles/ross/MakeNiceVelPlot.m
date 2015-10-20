%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% MakeNiceVelPlot.m
%
% Plot transects of velocity from Ross and ship
%
% 09/01/15 - AP
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

load('/Volumes/scienceparty_share/ROSS/Deploy1/adcp/mat/Deploy1_adcp_proc_smoothed.mat')

load('/Volumes/scienceparty_share/data/pipestring_1min.mat')

load('/Volumes/scienceparty_share/data/os150nb_uv.mat')

%%
figure(1);clf
agutwocolumn(1)
wysiwyg

m=3
n=1

ax1=subplot(m,n,1)
ezpc(vel.dnum,vel.z,vel.v)
caxis([-1 1])
datetick('x')
ylim([0 60])


ax2=subplot(m,n,2)
ezpc(P.dnum,P.z,P.v)
caxis([-1 1])
datetick('x')
ylim([0 60])
colormap(bluered)

linkaxes([ax1 ax2])
%%

%% plot vs lat

figure(1);clf
agutwocolumn(1)
wysiwyg

m=3
n=1

ax1=subplot(m,n,1)
ezpc(vel.lat,vel.z,vel.v)
caxis([-1 1])
cb=colorbar
cb.Label.String='m/s'
ylim([0 60])
ylabel('Depth [m]')
xlabel('Latitude [^oN]')
SubplotLetterMW('ROSS v')
xl=[nanmin(vel.dnum)-1/24 nanmax(vel.dnum)+1/24];
idt=isin(P.dnum,xl);
idts=isin(S.datenum,xl);
%
ax2=subplot(m,n,2)
ezpc(P.lat(idt),P.z,P.v(:,idt))
cb=colorbar
cb.Label.String='m/s'
caxis([-1 1])
ylabel('Depth [m]')
ylim([0 60])
colormap(bluered)
SubplotLetterMW('Ship 300kHz v')
xlabel('Latitude [^oN]')

ax3=subplot(m,n,3)
ezpc(S.lat(idts),S.z,S.v(:,idts))
cb=colorbar
cb.Label.String='m/s'
caxis([-1 1])
ylabel('Depth [m]')
ylim([0 60])
colormap(bluered)
SubplotLetterMW('Ship 150kHz v')
xlabel('Latitude [^oN]')

linkaxes([ax1 ax2 ax3])

print('/Volumes/scienceparty_share/ROSS/Deploy1/figures/Deploy1_v_vs_lat_withship','-dpng')

%%