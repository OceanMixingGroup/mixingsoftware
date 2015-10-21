%~~~~~~~~~~~~~~~~~
%
% CombineSplitFilesSidepole.m
%
%
% 09/17/15 -A.Pickering
%~~~~~~~~~~~~~~~~
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
%fnameshort='ASIRI_2Hz_deployment_20150824T043756.pd0';lab='File1';
%fnameshort='ASIRI 2Hz deployment 20150828T043335.pd0';lab='File2';
%fnameshort='ASIRI 2Hz deployment 20150829T123832.pd0';lab='File3';
fnameshort='ASIRI 2Hz deployment 20150904T053350.pd0';lab='File4'
%fnameshort='ASIRI 2Hz deployment 20150908T141555.pd0';lab='File5';
%fnameshort='ASIRI 2Hz deployment 20150911T223729.pd0';lab='File6';
%fnameshort='ASIRI 2Hz deployment 20150915T165213.pd0';lab='File7';
%fnameshort='ASIRI 2Hz deployment 20150917T091838.pd0';lab='File8';


% list of split files (~50mb each)
Flist=dir(fullfile(dir_data,[fnameshort(1:end-4) '_split*'])) % some have capital 'S' in split
%%

% load in navigation data from ship (more reliable than the internal
% sensors in the instrument itself). this is a file created by
% 'asiri_read_running_nav.m' and it outputs a structure "N".
% disp('loading nav data')
% load('/Volumes/scienceparty_share/data/nav_tot.mat')
% ttemp_nav=N.dnum_hpr; ig=find(diff(ttemp_nav)>0); ig=ig(1:end-1)+1;
%
% offsets=nan*ones(1,length(Flist))

Vtot=struct();
Vtot.dnum=[];
Vtot.u=[];
Vtot.v=[];
Vtot.z=[];
Vtot.lat=[];
Vtot.lon=[];

for ifile=1:length(Flist)
    clear V
%    fname=fullfile('/Volumes/scienceparty_share/sidepole/mat/',[Flist(ifile).name '_proc.mat'])
    fname=fullfile(SciencePath,'sidepole','mat',[Flist(ifile).name '_proc.mat']);
    try
        load(fname)
        
        Vtot.dnum=[Vtot.dnum V.dnum];
        Vtot.u=[Vtot.u V.u];
        Vtot.v=[Vtot.v V.v];
        Vtot.lat=[Vtot.lat V.lat];
        Vtot.lon=[Vtot.lon V.lon];
        
        Vtot.z=V.z;
    catch
        disp([fname ' not loaded!'])
    end
end
%
%clear V

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,4);

axes(ax(1))
plot(Vtot.dnum,Vtot.lat)
datetick('x')
cb=colorbar;killcolorbar(cb)

axes(ax(2))
plot(Vtot.dnum,Vtot.lon)
datetick('x')
cb=colorbar;killcolorbar(cb)

axes(ax(3))
ezpc(Vtot.dnum,Vtot.z,Vtot.u)
caxis(0.5*[-1 1])
datetick('x')
colormap(bluered)
colorbar

axes(ax(4))
ezpc(Vtot.dnum,Vtot.z,Vtot.v)
caxis(0.5*[-1 1])
datetick('x')
colormap(bluered)
colorbar
freqline(datenum(2015,9,5,11,35,57))
freqline(datenum(2015,9,5,19,04,05))


linkaxes(ax,'x')

%%
V=Vtot;
save(fullfile(SciencePath,'sidepole','mat',['sentinel_1min_' lab '.mat']),'V')
%%