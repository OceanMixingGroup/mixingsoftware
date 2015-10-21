%%

% PlotADCPmatfiles.m

% plot individual mat files from pipestring to check data

%%

clear ; close all

load('/Volumes/scienceparty_share/pipestring/mat/ADCP_ASIRI2015Aug002_000003_beam.mat')
%%
figure(1);clf
agutwocolumn(1)
wysiwyg
m=4
n=1

adcp.mtime(adcp.mtime==0)=nan;

subplot(m,n,1)
ezpc(adcp.mtime,adcp.config.ranges,adcp.north_vel)
%ezpc(adcp.mtime(1:end-1),adcp.config.ranges,adcp.north_vel(:,1:end-1))
colorbar
caxis(1*[-1 1])
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])
datetick('x')
title('pipestring beam velocities')
ylabel('range (m)')
%
subplot(m,n,2)
ezpc(adcp.mtime,adcp.config.ranges,adcp.east_vel)
%ezpc(adcp.mtime(1:end-1),adcp.config.ranges,adcp.east_vel(:,1:end-1))
colorbar
caxis(1*[-1 1])
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])
datetick('x')
ylabel('range (m)')

subplot(m,n,3)
ezpc(adcp.mtime,adcp.config.ranges,adcp.vert_vel)
colorbar
caxis(1*[-1 1])
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])
datetick('x')
ylabel('range (m)')

subplot(m,n,4)
ezpc(adcp.mtime,adcp.config.ranges,adcp.error_vel)
colorbar
caxis(1*[-1 1])
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])
datetick('x')
ylabel('range (m)')


%%