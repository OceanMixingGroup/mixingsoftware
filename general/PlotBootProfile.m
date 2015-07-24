function h=PlotBootProfile(bb,z)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function h=PlotBootProfile(bb)
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
set(hax,'XScale','log');
%set(hax,'YScale','log');
hL=semilogx(bb(:,2),z,'linewidth',2)
thcol=hL.Color;
    col2=.75*(255-(255*thcol)) + (255*thcol);
    col3=col2/255;

idg=find(~isnan(bb(:,1)));
hf=fill([bb(idg,1)' flipud(bb(idg,3))'],[z(idg)' flipud(z(idg))'],col3);
    if ~isempty(hf)
        hf.EdgeColor=[1 1 1];
        hf.FaceAlpha=0.75;
    end
    
%    semilogx(nanmean(xout,2),zin,'color',thcol,'linewidth',3)
%hf.EdgeColor=[1 1 1];
hold on
hL=semilogx(bb(:,2),z,'color',thcol,'linewidth',2)
axis ij 
shg
set(gca,'Xscale','log')
h=[hf hL];


%%