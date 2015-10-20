%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ReadRossADCP_Deploy2.m
%
% Read ROSS ADCP data for 2nd deployment (NE across 'Squirt') on ASIRI
% 2015.
%
% Read into matlab format (still in beam coordinates)
%
% 08/25/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% read into matlab
name='/Volumes/scienceparty_share/ROSS/Deploy2/adcp/_RDI_000.000'
[adcp,cfg,ens,hdr]=rdradcp(name,1);
adcp.mtime(end)=nan;

%% quick check that data looks normal

figure(1);clf
ezpc(adcp.mtime,cfg.ranges,adcp.north_vel)
caxis(1*[-1 1])

shg
%% save mat file for analysis

save('/Volumes/scienceparty_share/ROSS/Deploy2/adcp/Deploy2_beam.mat','adcp','cfg','ens','hdr')

%%