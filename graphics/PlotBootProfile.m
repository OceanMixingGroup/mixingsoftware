function h=PlotBootProfile(bb,z)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function h=PlotBootProfile(bb,z)
%
% Plot bootstrap mean and shade in 95% confidence intervals for profile.
%
% INPUT
% bb (MX3): Bootstrap mean and 95% conf. limits from bootstrap_profile.m
%  z (MX1): Depth vector corresponding to bb profile.
%
% OUTPUT
%  h: Handles to patch and and line.
%
% See also bootstrap_profile.m, boot_v5.m
%
% 4 Mar. 2015 - A. Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

hax=gca;
idg=find(~isnan(bb(:,1)));
hf=fill([bb(idg,1)' flipud(bb(idg,3))'],[z(idg)' flipud(z(idg))'],0.75*[1 1 1]);
hf.EdgeColor=[1 1 1];
hold on
hL=semilogx(bb(:,2),z,'k','linewidth',2)
axis ij 
shg
h=[hf hL];

return
%%