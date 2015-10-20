%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ReadRossADCP.m
%
% Read the RDI file for 1st deployment into mat
%
% 08/31/15 A. Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

cd /Volumes/scienceparty_share/ROSS/Deploy1/adcp

name='/Volumes/scienceparty_share/ROSS/Deploy1/adcp/raw/_RDI_005.000'
[adcp,cfg,ens,hdr]=rdradcp(name,1);
adcp.mtime(end)=nan;
%
save('/Volumes/scienceparty_share/ROSS/Deploy1/adcp/mat/Deploy1_beam.mat','adcp','cfg','ens','hdr')

%%

figure(1);clf
ezpc(adcp.mtime,cfg.ranges,adcp.north_vel)
caxis(1*[-1 1])

% %%
% %addpath /Users/Andy/Cruises_Research/mixing_software/adcp/
% nadcp=beam2earth_workhorse(adcp);
% 
% %%
% 
% figure(1);clf
% %ezpc(adcp.mtime,cfg.ranges,nadcp.vel1)
% ezpc(adcp.mtime,cfg.ranges,nadcp.vel2)
% caxis([-1 1])
% colormap(bluered)
% shg
% 
% %%
% 
% figure(1);clf
% %ezpc(adcp.mtime,cfg.ranges,nadcp.vel1)
% ezpc(adcp.mtime,cfg.ranges,conv2(diffs(nadcp.vel2),ones(1,10)/10,'same'))
% %caxis(3e-3*[-1 1])
% colormap(bluered)
% shg
% %%
% 
% save('/Volumes/scienceparty_share/ROSS/adcp/Deploy1_beam.mat','adcp','cfg','ens','hdr')
% 
% %%