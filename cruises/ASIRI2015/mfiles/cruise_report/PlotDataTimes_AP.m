%~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotDataTimes_AP.m
%
% (was PlotDataTimes.m)
%
% Make a figure showing when different instruments were operating during
% Aug 2015 ASIRI cruise on R/V Revelle.
%
% * Section names come from fctd_sec_name_time.m *
%
%
%-------------------
% 09/02/15 - A.Pickering - apickering@coas.oregonstate.edu
% 10/14/15 - AP - Copied from my science share copy to my laptop after
% cruise, now working on this copy.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% path to my back-up of science share that has data files on it
SciencePath='/Volumes/Midge/ExtraBackup/scienceshare_092015/'
DataPath='/Volumes/Midge/ExtraBackup/scienceshare_092015/data/'
MfilePath='/Users/Andy/Cruises_Research/mixingsoftware/cruises/ASIRI2015/mfiles/'
% 
% vmp.start=[201508240859,201508241007,201508241049,201508252352,...
%     201508260218,201508260629,201508260951,201508261249,201508261858,...
%     201509080915,201509090501,201509121042];
% vmp.stop=[201508240913,201508241042,201508241135,201508260137,...
%     201508260600,201508260855,201508261040,201508261435,201508270236,...
%     201509081339,201509091453,201509141440];
vmp.start=[201508240859, 201508252352, 201509080915,201509090501,201509121042]
    vmp.stop=[201508241135 ,201508270236 ,201509081339,201509091453,201509141440]
vmp.start=datenum(num2str(vmp.start(:)),'yyyymmddHHMM');
vmp.stop=datenum(num2str(vmp.stop(:)),'yyyymmddHHMM');

ross.start=[201508240537,201508252342,201509050300,201509071143,201509071338,201509100312,201509101103,201509140416];
ross.stop=[201508250604,201508261137,201509051039,201509071235,201509080857,201509100828,201509101144,201509141523];
ross.start=datenum(num2str(ross.start(:)),'yyyymmddHHMM');
ross.stop=datenum(num2str(ross.stop(:)),'yyyymmddHHMM');

% AP 10/16/15 - I don't see last two times in the ship's log?
reel.start=[201508271018,201508301143,201509020248,201509041442,201509100312,201509140416];
reel.stop=[201508280220,201508301555,201509020312,201509041513,201509100828,201509141523];
reel.start=datenum(num2str(reel.start(:)),'yyyymmddHHMM');
reel.stop=datenum(num2str(reel.stop(:)),'yyyymmddHHMM');

bow.start=[201508240415,201508280550,201508291336,201509020913,201509040612,201509061132,201509090205,201509120349,201509151914,201509171107];
bow.stop=[201508270535,201508290900,201509020344,201509031330,201509060952,201509090024,201509110133,201509150340,201509170554,201509192347];
bow.start=datenum(num2str(bow.start(:)),'yyyymmddHHMM');
bow.stop=datenum(num2str(bow.stop(:)),'yyyymmddHHMM');

sp.start=[201508240510,201508280505];
sp.stop=[201508270508,201508290900];
sp.start=datenum(num2str(sp.start(:)),'yyyymmddHHMM');
sp.stop=datenum(num2str(sp.stop(:)),'yyyymmddHHMM');

%load('/Volumes/scienceparty_share/data/combined_met.mat')
load(fullfile(DataPath,'combined_met.mat'))
met.LA(met.LA<10)=nan;
met.LO(met.LO<80)=nan;

ctd=[201508240250,201508241137,201508270246,201508280257,...
    201508290152,201508300251,201508310244,201509010244,201509020449,...
    201509030450,201509040406,201509070044,201509071049,201509090034,...
    201509111101,201509120948,201509130305,201509140326,201509150259];
ctd=datenum(num2str(ctd(:)),'yyyymmddHHMM');

%%

saveplot=1

%load(fullfile(SciencePath,'FCTD','FCTD_scratch','fctd_names.mat'))
load(fullfile(MfilePath,'cruise_report','fctd_names.mat'))

xl=[datenum(2015,8,24) datenum(2015,9,23)];

figure(1);clf
orient landscape
set(gcf,'defaultaxesfontsize',15)
wysiwyg
ax = MySubplot2(0.15, 0.075, 0.02, 0.06, 0.1, 0.01,1,2);

axes(ax(1))

% shade the different named sections alternating light/dark gray
aa=1
for whst=1:length(fctd_names)
    if iseven(aa)
        col=0.6*[1 1 1];
    else
        col=0.8*[1 1 1];
    end
hf=fill([fctd_names(whst).st fctd_names(whst).st fctd_names(whst).et fctd_names(whst).et],[13 20 20 13],col,'edgecolor','none')
hold on
aa=aa+1;
end

% plot lat vs time
axes(ax(1))
[AX,H1,H2]=plotyy(met.Time,met.LA,met.Time,met.LO)%,'linewidth',2)
H1.LineWidth=2;H2.LineWidth=2;
set(AX(1),'Ylim',[13 20])
set(AX(2),'Ylim',[84 93])
AX(1).YLabel.String='Lat'
AX(2).YLabel.String='Lon'
grid on
set(AX(1),'Xlim',xl);set(AX(2),'Xlim',xl)
title('ASIRI Aug. 2015 - R/V Revelle - RR1513')
%

%
% try plotting section names on figure
axes(AX(2))
hold on
for whst=[1:3]
    text(nanmean([fctd_names(whst).st fctd_names(whst).et]),85.5,fctd_names(whst).name,'rotation',65,'fontsize',11)
end

    text(nanmean([fctd_names(4).st fctd_names(4).et]),86,fctd_names(4).name,'rotation',65,'fontsize',11)
aa=1
for whst=[5:10 17 19 21 23 25 26 27 28 29 30 31 32 33 34]% 35 36 37 38 39:45]%4:2:length(fctd_names)
    if iseven(aa)
    text(nanmean([fctd_names(whst).st fctd_names(whst).et]),86.3,fctd_names(whst).name,'rotation',70,'fontsize',11)
    else
    text(nanmean([fctd_names(whst).st fctd_names(whst).et]),90,fctd_names(whst).name,'rotation',70,'fontsize',11)
    end
    aa=aa+1;
end

aa=1
for whst=[ 35:1:length(fctd_names)-3]%4:2:length(fctd_names)
    if iseven(aa)
    text(nanmean([fctd_names(whst).st fctd_names(whst).et]),85.5,fctd_names(whst).name,'rotation',70,'fontsize',10)
    else
    text(nanmean([fctd_names(whst).st fctd_names(whst).et]),90,fctd_names(whst).name,'rotation',70,'fontsize',10)
    end
    aa=aa+1;
end

for whst=[ length(fctd_names)-3 : length(fctd_names)]%4:2:length(fctd_names)
    text(nanmean([fctd_names(whst).st fctd_names(whst).et]),90,fctd_names(whst).name,'rotation',70,'fontsize',10)
end


xlabel('Date - 2015 ','fontsize',16)
set(ax(1),'XTick',[datenum(2015,8,23) :3: datenum(2015,9,23)])
set(AX(1),'XTick',[datenum(2015,8,23) :3: datenum(2015,9,23)])
set(AX(2),'XTick',[datenum(2015,8,23) :3: datenum(2015,9,23)])
%set(gca,'XTickLabel',[datenum(2015,8,23) :3: datenum(2015,9,23)])
axes(ax(1));datetick('x','keeplimits','keepticks')
axes(AX(1));datetick('x','keeplimits','keepticks')
axes(AX(2));datetick('x','keeplimits','keepticks')

load('/Users/Andy/Cruises_Research/Asiri/Local/Asiri2015IndexFile.mat')

%~~~~~ LOWER panel

axes(ax(2))
%
lw=8
hold on;
for m=1:length(ross.start);
    line([ross.start(m),ross.stop(m)],[1 1],'color','m','linewidth',lw);
end
for m=1:length(vmp.start);
    line([vmp.start(m),vmp.stop(m)],[2 2],'color','r','linewidth',lw);
end
for m=1:length(reel.start);
    line([reel.start(m),reel.stop(m)],[3 3],'color','b','linewidth',lw);
end
for m=1:length(bow.start);
    line([bow.start(m),bow.stop(m)],[4 4],'color','g','linewidth',lw);
end

for whst=1:length(AIndex.Bow)
    text(nanmean([AIndex.Bow(whst).st AIndex.Bow(whst).et]),3.7,AIndex.Bow(whst).name,'rotation',55,'fontsize',10)
    hold on
end

for whst=1:length(AIndex.Ross)
    text(nanmean([AIndex.Ross(whst).st AIndex.Ross(whst).et]),0.7,AIndex.Ross(whst).name,'rotation',55,'fontsize',10)
    hold on
end

% for whst=1:length(AIndex.VMP)
%     text(nanmean([AIndex.VMP(whst).st AIndex.VMP(whst).et]),2,AIndex.VMP(whst).name,'rotation',55,'fontsize',12)
%     hold on
% end
shg
%
set(gca,'Box','on')

plot(ctd,5*ones(size(ctd)),'d','markerfacecolor','k')

% plot ~ FCTD times
%load('/Volumes/scienceparty_share/FCTD/MAT/FastCTD_MATfile_TimeIndex.mat')
load(fullfile(SciencePath,'FCTD','MAT','FastCTD_MATfile_TimeIndex.mat'))
plot(FastCTD_MATfile_TimeIndex.timeStart,6*ones(size(FastCTD_MATfile_TimeIndex.timeStart)),'mp','linewidth',lw/2,'color',[.7 .7 .7])

set(gca,'YTick',[1 2 3 4 5 6 ])
set(gca,'YTickLabels',{'ROSS';'vmp';'reelCTD';'bowchain';'CTD';'FCTD'})
ylim([0 7])
grid on
xlim(xl)
set(gca,'XTick',[datenum(2015,8,23) :3: datenum(2015,9,23)])
datetick('x','keeplimits','keepticks')

linkaxes([ax AX],'x')
shg
%
if saveplot==1
    LocalPath='/Users/Andy/Cruises_Research/Asiri/Local/'

%print('/Volumes/scienceparty_share/figures/AllDataTimes','-dpng')
print(fullfile(LocalPath,'AllDataTimes'),'-dpng')
end
%%