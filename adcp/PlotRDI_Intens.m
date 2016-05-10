function  ax=PlotRDI_Intens(adcp,cfg)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Pcolor beam intensities from RDI ADCP
%
% INPUTS
% - adcp , cfg : ADCP data as read w/ RDADCP
% 
%
% 05/02/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
%~~~ beam intensities
cl=[50 150]
yl=[0 60]
figure(2);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05,1,4);

axes(ax(1))
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.intens(:,1,:)));
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')
title([adcp.name '  Beam Intensities'])

axes(ax(2))
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.intens(:,2,:)));
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')

axes(ax(3))
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.intens(:,3,:)));
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')

axes(ax(4))
ezpc(adcp.mtime,cfg.ranges,(squeeze(adcp.intens(:,4,:))));
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')

colormap(parula)

linkaxes(ax)
