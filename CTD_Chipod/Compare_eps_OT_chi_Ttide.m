%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Compare_eps_OT_chi_Ttide.m
%
% Script to compare epsilon from overturns and chipod for T-tide CTD
% stations.
%
%
% Started Apr. 1 2015
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

saveplots=0

CTD_path='/Users/Andy/Dropbox/TTIDE_OBSERVATIONS/scienceparty_share/TTIDE-RR1501/data/ctd_processed/'

load('/Users/Andy/Dropbox/TTIDE_OBSERVATIONS/scienceparty_share/TTIDE-RR1501/data/CTD_stationlist.mat')

wh_station=7

% load station file with all CTD casts combined
load(fullfile(CTD_path,['CTD_' CTD.name{wh_station} '.mat']))

figure(1);clf
em=(nanmean(C.all.eps_rho,2));
ig=find(log10(em)>-11);
%semilogx(nanmean(C.all.eps_rho,2),C.all.z,'d')
hot=semilogx(em(ig),C.all.z(ig),'linewidth',2)
%hold on
%semilogx(nanmean(C.all.eps_t,2),C.all.z,'--')
axis ij
%xlim([1e-9 1e-6])
grid on
ylabel('depth [m]')
title(['Station ' CTD.name{wh_station} ])
xlabel('epsilon [Wkg^{-1}]')

% ** add bootstrap limits on mean?

%~ get CTD cast numbers for this station
%castnums=CTD.firstcast(wh_station):CTD.firstcast(wh_station+1)-1
castnums=CTD.firstcast(wh_station):CTD.firstcast(wh_station)+ size(C.all.s,2)/2 -1

% load chi profiles for these casts and plot eps from chi

chi_processed_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/Processed/';
chi_data_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/'
%up_down_big=1

%for up_down_big=1%:2
    % load chipod data
    short_labs={'up_1012','down_1013','big','down_1010'};
    big_labs={'Ti UpLooker','Ti DownLooker','Unit 1002','Ti Downlooker'};
    


zvec=C.all.p;

epschi_up=nan*ones(length(zvec),length(castnums));
epschi_dn=nan*ones(length(zvec),length(castnums));
dnum_up=nan*ones(1,length(castnums));
dnum_dn=nan*ones(1,length(castnums));
for whcast=1:length(castnums)
    
    castnumber=castnums(whcast);
    
    clear avg ctd
    
    if castnumber<10
        cast_suffix=['00' num2str(castnumber)];
    end
    
    if castnumber>9 && castnumber <100
        cast_suffix=['0' num2str(castnumber)];
    end
    
    if castnumber >99
        cast_suffix=[ num2str(castnumber)];
    end
    
    % uplooker
    clear up_down_big processed_file
    up_down_big=1
    processed_file=[chi_processed_path 'chi_' short_labs{up_down_big} '/avg/avg_' ...
        cast_suffix '_' short_labs{up_down_big} '.mat']    
    % load avg,ctd
    load(processed_file)
    clear ig
    ig=find(~isnan(avg.P));
    epschi_up(:,whcast)=interp1(avg.P(ig),avg.eps1(ig),zvec);
    dnum_up(whcast)=nanmean(avg.datenum);
    
    % downlooker
    clear up_down_big processed_file
    up_down_big=2
    processed_file=[chi_processed_path 'chi_' short_labs{up_down_big} '/avg/avg_' ...
        cast_suffix '_' short_labs{up_down_big} '.mat']    
    % load avg,ctd
    load(processed_file)
    clear ig
    ig=find(~isnan(avg.P));
    epschi_dn(:,whcast)=interp1(avg.P(ig),avg.eps1(ig),zvec);
    dnum_dn(whcast)=nanmean(avg.datenum);
end

% figure(2);clf
% semilogx(epschi,zvec)
% hold on
% semilogx(nanmean(epschi,2),zvec,'k','linewidth',2)
% axis ij
%xlim([1e-9 1e-6])
%
figure(4);clf
ax1=subplot(121)
%hold on
hchi=semilogx(nanmean(epschi_up,2),zvec,'r','linewidth',1)
hold on
%hchi=semilogx(nanmean(epschi,2),zvec,'r','linewidth',1)
%hchi=semilogx(nanmean(epschi_dn,2),zvec,'m.','linewidth',1)
em=(nanmean(C.all.eps_rho,2));
ig=find(log10(em)>-11);
%semilogx(nanmean(C.all.eps_rho,2),C.all.z,'d')
hot=semilogx(em(ig),C.all.z(ig),'k','linewidth',2)
axis ij
grid on
ylabel('depth [m]')
title(['Station ' CTD.name{wh_station} ])
xlabel('epsilon [Wkg^{-1}]')
xlim([1e-11 1e-4])
ax1.XTick=[1e-10 1e-9 1e-8 1e-7 1e-6 1e-5]
legend([hot,hchi],'thorpe','chi up','location','best')


ax2=subplot(122)
%hold on
%hchi=semilogx(nanmean(epschi_up,2),zvec,'r','linewidth',1)
%hold on
%hchi=semilogx(nanmean(epschi,2),zvec,'r','linewidth',1)
hchi=semilogx(nanmean(epschi_dn,2),zvec,'r','linewidth',1)
hold on
em=(nanmean(C.all.eps_rho,2));
ig=find(log10(em)>-11);
%semilogx(nanmean(C.all.eps_rho,2),C.all.z,'d')
hot=semilogx(em(ig),C.all.z(ig),'k','linewidth',2)
axis ij
grid on
ylabel('depth [m]')
title(['Station ' CTD.name{wh_station} ])
xlabel('epsilon [Wkg^{-1}]')
xlim([1e-11 1e-4])
ax2.XTick=[1e-10 1e-9 1e-8 1e-7 1e-6 1e-5]
legend([hot,hchi],'thorpe','chi down','location','best')

if saveplots==1
figname=fullfile('/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/Processed/figures','Stations',['Station_' CTD.name{wh_station} '_epsprofiles_OT_chi'])
print('-dpng','-r300',figname)
end
%
figure(6);clf
ezpc(C.all.dnum,C.all.p,C.all.t)
hold on
tm=nanmean(C.all.t,2);tm=tm(~isnan(tm));
contour(C.all.dnum,C.all.p,C.all.t,tm(1:10:end),'k')
colorbar
datetick('x')

figure(7);clf
ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.007, 1,3);
agutwocolumn(1)
wysiwyg

axes(ax(1))
ezpc(C.all.dnum,C.all.p,log10(C.all.eps_rho))
colorbar
caxis([-9 -5])
cmap=jet;
colormap([0.7*[1 1 1];cmap])
datetick('x')
SubplotLetterMW('thorpe')

axes(ax(2))
ezpc(dnum_dn,zvec,log10(epschi_dn))
%ezpc(dnum_up,zvec,log10(epschi_up))
colorbar
caxis([-9 -5])
cmap=jet;
colormap([0.7*[1 1 1];cmap])
datetick('x')
SubplotLetterMW('chi down')

axes(ax(3))
%ezpc(dnum_dn,zvec,log10(epschi_dn))
ezpc(dnum_up,zvec,log10(epschi_up))
colorbar
caxis([-9 -5])
cmap=jet;
colormap([0.7*[1 1 1];cmap])
datetick('x')
SubplotLetterMW('chi up')

linkaxes(ax)

%%

figure(5);clf
[bb]=bootstrap_profile(C.all.eps_rho,300);
PlotBootProfile(bb,C.all.p)
%%
figure(6);clf
semilogx(bb(:,2),C.all.p,'ko')
hold on
semilogx(bb(:,1),C.all.p,'r.')
semilogx(bb(:,3),C.all.p,'m.')
