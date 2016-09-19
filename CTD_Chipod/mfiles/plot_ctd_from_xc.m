function ax=plot_ctd_from_xc(XC)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ax=plot_ctd_from_xc(XC)
%
% Make a generic pcolor plot of CTD temp and sal for a CTD-chipod cruise
%
% INPUT
%  XC - structure w/ fields
%       - ctd.t
%       - ctd.s
%       - ctd.p
%       - lat
%
% OUTPUT
%  ax - Vector of axes handles
%
%------------------
% 09/19/16 - A.Pickering - andypicke@gmail.com
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

close all
figure(1);clf
agutwocolumn(1)
wysiwyg
set(gcf,'DefaultAxesFontsize',14)

ax1=subplot(211);
ezpc(XC.lat,XC.ctd.p,XC.ctd.t);
hold on
%contour(proc_info.lat,zout,t,[0:1:30],'k')
%plot(proc_info.lat,zmax,'ko')
cb=colorbar;
cb.Label.String='^oC';
ylim([0 nanmax(XC.ctd.p)])
xlabel('Latitude','fontsize',16)
ylabel('P [db]','fontsize',16)

ax2=subplot(212);
ezpc(XC.lat,XC.ctd.p,XC.ctd.s);
cb=colorbar;
cb.Label.String='psu';
ylim([0 nanmax(XC.ctd.p)])
colormap(gca,salmap);
xlabel('Latitude','fontsize',16)
ylabel('P [db] ','fontsize',16)

ax=[ax1 ax2];

linkaxes(ax)

%%