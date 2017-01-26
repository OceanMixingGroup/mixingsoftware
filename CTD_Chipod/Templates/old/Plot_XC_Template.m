%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Plot_XC_Template.m
%
% 
%
%------------------
% 06/13/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Plot all vars for one chipod

whSN='SN1013';castdir='up'
whSN='SN2002';castdir='up'

close all

% Versus time
ax=PlotChipodXC_allVars(XC,whSN,castdir,'T1','dnum');

% Versus lat
ax=PlotChipodXC_allVars(XC,whSN,castdir,'T1','lat');

%% Plot chi from down and upcast for one chipod

saveplot=0

whSN='SN2009'

yl=[0 6000]

whsens='T1'
whvar='chi'

figure(1);clf

castdir='down'
X=XC.([whSN '_' castdir '_' whsens]);
X.dnum(find(X.dnum==0))=nan;
X.dnum(find(diffs(X.dnum)<0))=nan;

ax1=subplot(211);
ezpc(X.dnum,X.P,log10(X.(whvar)))
hold on
plot(X.dnum,0,'kd')
cb=colorbar
caxis([-10 -5]);
title([whSN ' ' castdir 'cast ' whsens ' log_{10} ' whvar])
ylim(yl)
datetick('x')
ylabel('Pressure [db]','fontsize',16)
%

castdir='up'
X=XC.([whSN '_' castdir '_' whsens]);
X.dnum(find(X.dnum==0))=nan;
X.dnum(find(diffs(X.dnum)<0))=nan;

ax2=subplot(212);
ezpc(X.dnum,X.P,log10(X.(whvar)))
hold on
plot(X.dnum,0,'kd')
cb=colorbar;
caxis([-10 -5])
title([whSN ' ' castdir 'cast ' whsens ' log_{10} ' whvar])
ylim(yl)
datetick('x')
ylabel('Pressure [db]','fontsize',16)

linkaxes([ax1 ax2])

if saveplot==1
%     figdir='/Users/Andy/Cruises_Research/ChiPod/Tasmania/Figures/Falkor/'
%     figname=[whSN '_' whvar '_' whsens '_UpDownPcolor']
%     print(fullfile(figdir,figname),'-dpng')
end

%%