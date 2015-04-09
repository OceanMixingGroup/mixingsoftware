%
% tests31Mar.m
%
% Comparing dpdt and time_offset using 24Hz and 1 m CTD data.
%
% 1m doenst work for comparing to CTD
%
%%

clear ; close all

% 24 hz data ('data2')
load('/Users/Andy/Dropbox/TTIDE_OBSERVATIONS/scienceparty_share/TTIDE-RR1501/data/ctd_processed/24hz/ttide_leg1_017_0.mat')

% 1m binned data
load('/Users/Andy/Dropbox/TTIDE_OBSERVATIONS/scienceparty_share/TTIDE-RR1501/data/ctd_processed/ttide_leg1_017.mat')

chi_data_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/'
chi_path=fullfile(chi_data_path,'1012')
suffix='A1012';
isbig=0;
az_correction=-1;
%
 tlim=now+5*365;
    if data2.time > tlim
        % jen didn't save us a real 24 hz time.... so create timeseries. JRM
        % from data record
        %disp('test!!!!!!!!!!')
        tmp=linspace(data2.time(1),data2.time(end),length(data2.time));
        data2.datenum=tmp'/24/3600+datenum([1970 1 1 0 0 0]);
    end
    
    clear tlim tmp
    time_range=[min(data2.datenum) max(data2.datenum)];
    chidat=load_chipod_data(chi_path,time_range,suffix,isbig);
    %
% low-passed p
data2.p_lp=conv2(medfilt1(data2.p),hanning(30)/sum(hanning(30)),'same');
data2.dpdt=gradient(data2.p_lp,nanmedian(diff(data2.datenum*86400)));
data2.dpdt(data2.dpdt>10)=mean(data2.dpdt); % JRM added to remove large spike spikes in dpdt

% high-passed dpdt
data2.dpdt_hp=data2.dpdt-conv2(data2.dpdt,hanning(750)/sum(hanning(750)),'same');
data2.dpdt_hp(abs(data2.dpdt_hp)>2)=mean(data2.dpdt_hp); % JRM added to remove large spike spikes in dpdt_hp

% compute dpdt from 1m data also

dat=datad_1m;
% low-passed p
dat.p_lp=conv2(medfilt1(dat.p),hanning(30)/sum(hanning(30)),'same');
dat.dpdt=gradient(dat.p_lp,nanmedian(diff(dat.datenum*86400)));
dat.dpdt(dat.dpdt>10)=mean(dat.dpdt); % JRM added to remove large spike spikes in dpdt
%
% high-passed dpdt
dat.dpdt_hp=dat.dpdt-conv2(dat.dpdt,hanning(750)/sum(hanning(750)),'same');
dat.dpdt_hp(abs(dat.dpdt_hp)>2)=mean(dat.dpdt_hp); % JRM added to remove large spike spikes in dpdt_hp



%%
figure(1);clf
%plot(data2.datenum,data2.dpdt)
%hold on
%plot(data2.datenum,data2.dpdt_hp)
%hold on
plot(dat.datenum,dat.dpdt_hp)
hold on
%
%~ AP - compute chipod w by integrating z-accelertion?
%chidat.AZ_hp=filter_series(chidat.AX,100,'h.02');
tmp=az_correction*9.8*(chidat.AZ-median(chidat.AZ)); tmp(abs(tmp)>10)=0;
tmp2=tmp-conv2(tmp,hanning(3000)/sum(hanning(3000)),'same');
w_from_chipod=cumsum(tmp2*nanmedian(diff(chidat.datenum*86400)));

plot(chidat.datenum,w_from_chipod)
shg

%% see if we can get highpassed dpdt from RBR

clear ; close all

load('/Volumes/LENOVO/jois/RBR/050651.mat')
data2=data;
data2.datenum=data2.time;
data2.p_lp=conv2(medfilt1(data2.P),hanning(30)/sum(hanning(30)),'same');
data2.dpdt=gradient(data2.p_lp,nanmedian(diff(data2.datenum*86400)));
data2.dpdt(data2.dpdt>10)=mean(data2.dpdt); % JRM added to remove large spike spikes in dpdt

% high-passed dpdt
data2.dpdt_hp=data2.dpdt-conv2(data2.dpdt,hanning(750)/sum(hanning(750)),'same');
data2.dpdt_hp(abs(data2.dpdt_hp)>2)=mean(data2.dpdt_hp); % JRM added to remove large spike spikes in dpdt_hp

%%
figure(1);clf
plot(data2.datenum,data2.dpdt)
hold on
plot(data2.datenum,data2.dpdt_hp)
%%