%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ReadRossADCP_Deploy3.m
%
% Read ROSS ADCP data for3rd deployment south on 89 34.5 on ASIRI
% 2015.
%
% Read into matlab format (still in beam coordinates)
%
% 09/06/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

addpath('/Volumes/scienceparty_share/mfiles/pipestring/')

% read into matlab
name='/Volumes/scienceparty_share/ROSS/Deploy3/adcp/raw/ROSS3003.000'
[adcp,cfg,ens,hdr]=rdradcp(name,1);
adcp.mtime(end)=nan;

%% quick check that data looks ! normal

figure(1);clf
ezpc(adcp.mtime,cfg.ranges,adcp.north_vel)
caxis(1*[-1 1])

shg
%% save mat file for analysis

save('/Volumes/scienceparty_share/ROSS/Deploy3/adcp/mat/Deploy3_beam.mat','adcp','cfg','ens','hdr')

%%