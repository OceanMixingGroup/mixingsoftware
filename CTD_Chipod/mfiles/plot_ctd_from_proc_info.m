function ax=plot_ctd_from_proc_info(proc_info)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ax=plot_ctd_from_xc(proc_info)
%
% Make a generic pcolor plot of CTD temp and sal for a CTD-chipod cruise
%
% INPUT
%  proc_info - structure w/ fields
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
ezpc(proc_info.lat,proc_info.ctd.p,proc_info.ctd.t);
hold on
cb=colorbar;
cb.Label.String='^oC';
ylim([0 nanmax(proc_info.ctd.p)])
xlabel('Latitude','fontsize',16)
ylabel('P [db]','fontsize',16)

ax2=subplot(212);
ezpc(proc_info.lat,proc_info.ctd.p,proc_info.ctd.s);
cb=colorbar;
cb.Label.String='psu';
ylim([0 nanmax(proc_info.ctd.p)])
colormap(gca,salmap);
xlabel('Latitude','fontsize',16)
ylabel('P [db] ','fontsize',16)

ax=[ax1 ax2];

linkaxes(ax)

%%