%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ReadRossADCP_Deploy5.m
%
% Read ROSS ADCP data for 5th deployment on ASIRI
% 2015.
%
% Read into matlab format (still in beam coordinates)
%
% 09/09/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

addpath('/Volumes/scienceparty_share/mfiles/pipestring/')

% read into matlab
name='/Volumes/scienceparty_share/ROSS/Deploy5/adcp/raw/ROSS5000.000'
[adcp,cfg,ens,hdr]=rdradcp(name,1);
adcp.mtime(end)=nan;

%% quick check that data looks ! normal

figure(1);clf
ezpc(adcp.mtime,cfg.ranges,adcp.north_vel)
caxis(1*[-1 1])
datetick('x')
shg
%% save mat file for analysis

save('/Volumes/scienceparty_share/ROSS/Deploy5/adcp/mat/Deploy5_beam.mat','adcp','cfg','ens','hdr')

%%