%%


clear ; close all

load('/Volumes/scienceparty_share/sidepole/mat/ASIRI 2Hz deployment 20150828T043335_split_000.000_earth.mat')
nadcp1=nadcp;clear nadcp

load('/Volumes/scienceparty_share/sidepole/mat/ASIRI 2Hz deployment 20150828T043335_split_000.000_earth2.mat')

%%
%hdif=
%figure(1);clf

%%

figure(1);clf
imagesc(nadcp.vel1-nadcp1.vel1)
colorbar
caxis(0.5*[-1 1])
colormap(bluered)
%%