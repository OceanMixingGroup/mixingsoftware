%~~~~~~~~~~~~~~~~~~~~
%
% CombineSplitFilesSidepole_V2.m
%
% Testing new method to do smoothing/filtering after combining files, to
% elimiate edge effects.
%
%--------------
% 10/20/15 -A.Pickering
%~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

SciencePath='/Volumes/Midge/ExtraBackup/scienceshare_092015/'

% path for m-files (github repo)
MfilePath='/Users/Andy/Cruises_Research/mixingsoftware/cruises/ASIRI2015/mfiles/'
%cd(fullfile(SciencePath,'mfiles','sidepole'))

% root directory for data
%dir_data='/Volumes/scienceparty_share/sidepole/raw'
dir_data=fullfile(SciencePath,'sidepole','raw')

% filenames
whfile=4;
switch whfile
    case 1
        fnameshort='ASIRI_2Hz_deployment_20150824T043756.pd0';lab='File1';
    case 2
        fnameshort='ASIRI 2Hz deployment 20150828T043335.pd0';lab='File2';
    case 3
        fnameshort='ASIRI 2Hz deployment 20150829T123832.pd0';lab='File3';
    case 4
        fnameshort='ASIRI 2Hz deployment 20150904T053350.pd0';lab='File4'
    case 5
        fnameshort='ASIRI 2Hz deployment 20150908T141555.pd0';lab='File5';
    case 6
        fnameshort='ASIRI 2Hz deployment 20150911T223729.pd0';lab='File6';
    case 7
        fnameshort='ASIRI 2Hz deployment 20150915T165213.pd0';lab='File7';
    case 8
        fnameshort='ASIRI 2Hz deployment 20150917T091838.pd0';lab='File8';
end

% list of split files (~50mb each)
Flist=dir(fullfile(dir_data,[fnameshort(1:end-4) '_split*'])) % some have capital 'S' in split

Vtot=struct();
Vtot.dnum=[];
Vtot.u=[];
Vtot.v=[];
Vtot.z=[];
Vtot.lat=[];
Vtot.lon=[];

for ifile=1:length(Flist)
    clear V
    fname=fullfile(SciencePath,'sidepole','mat',[Flist(ifile).name '_proc_raw.mat']);
    try
        load(fname)
        
        Vtot.dnum=[Vtot.dnum A2.dnum];
        Vtot.u=[Vtot.u A2.u];
        Vtot.v=[Vtot.v A2.v];
        Vtot.lat=[Vtot.lat A2.lat];
        Vtot.lon=[Vtot.lon A2.lon];        
        Vtot.z=A2.z;
    catch
        disp([fname ' not loaded!'])
    end
end
%

%% despike and average data
addpath(fullfile(SciencePath,'mfiles','pipestring')) % for despike.m
Af=DespikeAndFiltADCP(Vtot)

%%

clear ig
ig=find(diff(Vtot.dnum)>0); ig=ig(1:end-1)+1;
Af.lon=interp1(Vtot.dnum(ig),Vtot.lon(ig),Af.dnum);
Af.lat=interp1(Vtot.dnum(ig),Vtot.lat(ig),Af.dnum);

%%
figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,4);
%
axes(ax(1))
plot(Af.dnum,Af.lat)
datetick('x')
cb=colorbar;killcolorbar(cb)

axes(ax(2))
plot(Af.dnum,Af.lon)
datetick('x')
cb=colorbar;killcolorbar(cb)

axes(ax(3))
ezpc(Af.dnum,Af.z,Af.u)
caxis(0.5*[-1 1])
datetick('x')
colormap(bluered)
colorbar

axes(ax(4))
ezpc(Af.dnum,Af.z,Af.v)
caxis(0.5*[-1 1])
datetick('x')
colormap(bluered)
colorbar

linkaxes(ax,'x')

% save final processed file
V=Af;
save(fullfile(SciencePath,'sidepole','mat',['sentinel_1min_' lab '_v2.mat']),'V')
%%