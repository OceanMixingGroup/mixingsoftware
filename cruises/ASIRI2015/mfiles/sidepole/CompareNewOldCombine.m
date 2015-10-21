%~~~~~~~~~~~~~~~~~~~~~~~
%
% CompareNewOldCombine.m
%
% compare old and new method for comibining ADCP files and smoothing
%
%----------------
% 10/20/15 - AP
%~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

load('/Volumes/Midge/ExtraBackup/scienceshare_092015/sidepole/mat/sentinel_1min_File4.mat')
V1=V;clear V

load('/Volumes/Midge/ExtraBackup/scienceshare_092015/sidepole/mat/sentinel_1min_File4_v2.mat')
V2=V;clear V


%%
figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,2);

axes(ax(1))
ezpc(V1.dnum,V1.z,V1.u)
datetick('x')
cb=colorbar;
caxis(0.5*[-1 1])
colormap(bluered)

axes(ax(2))
ezpc(V2.dnum,V2.z,V2.u)
datetick('x')
cb=colorbar;
caxis(0.5*[-1 1])

linkaxes(ax)
%%