%%
%
% updated pipestring processing and checking to see if new results match
% old data
%
% 09/19/15 AP
%
%%

clear ; close all

 load('/Volumes/scienceparty_share/data/pipestring_1min.mat')
 P1=P;clear P
load('/Volumes/scienceparty_share/data/pipestring_1min_v2.mat')
P2=P;clear P

%%

cl=0.75*[-1 1]
yl=[0 60]

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,4);

axes(ax(1))
ezpc(P1.dnum,P1.z,P1.u)
caxis(cl)
datetick('x')
ylim(yl)

axes(ax(2))
ezpc(P2.dnum,P2.z,P2.u)
caxis(cl)
datetick('x')
ylim(yl)

axes(ax(3))
ezpc(P1.dnum,P1.z,P1.v)
caxis(cl)
datetick('x')
ylim(yl)

axes(ax(4))
ezpc(P2.dnum,P2.z,P2.v)
caxis(cl)
datetick('x')
ylim(yl)

colormap(bluered)

linkaxes(ax)
%%