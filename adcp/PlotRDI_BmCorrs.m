function  ax=PlotRDI_BmCorrs(adcp,cfg)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Pcolor beam correlations from RDI ADCP
%
% INPUTS
% - adcp , cfg : ADCP data as read w/ RDADCP
%
%
%------------------------
% 05/02/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%~~~ beam correlations
cl=[0 143]
yl=[0 60]
figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05,1,4);

axes(ax(1))
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,1,:)));
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')
title(['ROSS ' name '  Beam correlations'])

axes(ax(2))
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,2,:)));
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')

axes(ax(3))
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,3,:)));
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')

axes(ax(4))
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,4,:)));
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')

colormap(parula)

linkaxes(ax)
%~~~


%%