function  ax=PlotRDI_BmVels(adcp,cfg)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Pcolor beam velocities from RDI ADCP
%
% INPUTS
% - adcp , cfg : ADCP data as read w/ RDADCP
%
%
%------------------------
% 05/02/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%~~~ beam velocities
cl=0.75*[-1 1]
yl=[0 60]
figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05,1,4);

axes(ax(1))
ezpc(adcp.mtime,cfg.ranges,adcp.east_vel);
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')
title([ adcp.name '  Beam velocities'])
SubplotLetterMW('Bm1');

axes(ax(2))
ezpc(adcp.mtime,cfg.ranges,adcp.north_vel);
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')
SubplotLetterMW('Bm2');

axes(ax(3))
ezpc(adcp.mtime,cfg.ranges,adcp.vert_vel);
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')
SubplotLetterMW('Bm3');

axes(ax(4))
ezpc(adcp.mtime,cfg.ranges,adcp.error_vel);
caxis(cl)
ylim(yl)
datetick('x')
colorbar
ylabel('range [m]')
SubplotLetterMW('Bm4');

linkaxes(ax)


%%