%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% CompareSentinelToPipestring.m
%
%
% 08/30/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

%load('/Volumes/scienceparty_share/data/sentinel_1min.mat')
load('/Volumes/scienceparty_share/data/sentinel_1min_2ndFile.mat')

load('/Volumes/scienceparty_share/data/pipestring_1min.mat')
%%

cl=1*[-1 1]
yl=[0 50]

figure(1);clf
agutwocolumn(1)
wysiwyg

ax1=subplot(411)
ezpc(V.dnum,V.z,V.u)
caxis(cl)
datetick('x')
ylim(yl)
title('500 kHz u')
colorbar

ax3=subplot(412)
ezpc(P.dnum,P.z,P.u)
caxis(cl)
datetick('x')
ylim(yl)
title('300 kHz u')
colorbar

ax2=subplot(413)
ezpc(V.dnum,V.z,V.v)
caxis(cl)
datetick('x')
ylim(yl)
title('500 kHz v')
colorbar

ax4=subplot(414)
ezpc(P.dnum,P.z,P.v)
caxis(cl)
datetick('x')
ylim(yl)
title('300 kHz u')
colorbar

colormap(bluered)

linkaxes([ax1 ax2 ax3 ax4])

%%
print('/Volumes/scienceparty_share/figures/sidepole_pipestring_compare','-dpng')
%%