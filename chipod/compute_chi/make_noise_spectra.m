% make_noise_spectra
%% get the data
clear all;close all; fclose all;
unit=205;
% ts=datenum(2005,10,21,0,0,0);
% tf=datenum(2005,10,23,6,00,0);
ts=datenum(2005,11,8,0,0,0);
tf=datenum(2005,11,10,0,0,0);
dpath='\\mserver\Data\chipod\tao_sep05\';
directory=[dpath '\noise_spec\deglitched\'];
[avgchi]=get_avgchi(directory,unit,ts,tf);
figure(13),clf
subplot(3,1,1)
semilogy(avgchi.time,avgchi.chi1,'r')
set(gca,'ylim',[1e-11 5e-6])
grid on
kdatetick
title('\chi_1')
subplot(3,1,2)
semilogy(avgchi.time,avgchi.chi2,'b')
kdatetick
set(gca,'ylim',[1e-11 5e-6])
grid on
title('\chi_2')
subplot(3,1,3)
plot(avgchi.time,avgchi.fspd,'g')
kdatetick
title('Fallspeed')
%% then scale / average / plot
% 1st sort
if unit==120
%     chi_lo=1e-11;chi_hi=1e-6;
%     fspd_lo=0.4;fspd_hi=0.75;
    chi_lo=.4e-11;chi_hi=1e-6;
    fspd_lo=0.4;fspd_hi=0.75;
% ts=datenum(2005,10,21,0,0,0);
% tf=datenum(2005,10,21,18,00,0);
elseif unit==204
%     chi_lo=2e-10;chi_hi=1e-8;
%     fspd_lo=0.3;fspd_hi=0.5;
    chi_lo=8e-11;chi_hi=1e-7;
    fspd_lo=0.3;fspd_hi=0.75;
% ts=datenum(2005,10,21,0,0,0);
% tf=datenum(2005,10,21,18,00,0);
elseif unit==205
%     chi_lo=.3e-11;chi_hi=1e-8;
%     fspd_lo=0.6;fspd_hi=0.75;
    chi_lo=.3e-11;chi_hi=1e-8;
    fspd_lo=0.6;fspd_hi=0.85;
% ts=datenum(2005,11,8,0,0,0);
% tf=datenum(2005,11,10,0,0,0);
end
id11=find(avgchi.fspd<fspd_lo & avgchi.chi1<chi_lo);% lo_slo
id12=find(avgchi.fspd<fspd_lo & avgchi.chi2<chi_lo);% lo_slo
id21=find(avgchi.fspd<fspd_lo & avgchi.chi1>chi_hi);% hi_slo
id22=find(avgchi.fspd<fspd_lo & avgchi.chi2>chi_hi);% hi_slo
id31=find(avgchi.fspd>fspd_hi & avgchi.chi1<chi_lo);% lo_fast
id32=find(avgchi.fspd>fspd_hi & avgchi.chi2<chi_lo);% lo_fast
id41=find(avgchi.fspd>fspd_hi & avgchi.chi1>chi_hi);% hi_fast
id42=find(avgchi.fspd>fspd_hi & avgchi.chi2>chi_hi);% hi_fast
% plot sorted spectra as function of frequency
freq=avgchi.k1(:,1)*avgchi.fspd(1);
figure(39);clf
loglog(freq,nanmean(avgchi.spec1(:,id11),2),'k');grid on;hold on% lo_slo
loglog(freq,nanmean(avgchi.spec2(:,id12),2),'k.');% lo_slo
loglog(freq,nanmean(avgchi.spec1(:,id21),2),'b');% hi_slo
loglog(freq,nanmean(avgchi.spec2(:,id22),2),'b.');% hi_slo
loglog(freq,nanmean(avgchi.spec1(:,id31),2),'g');% lo_fast
loglog(freq,nanmean(avgchi.spec2(:,id32),2),'g.');% lo_fast
loglog(freq,nanmean(avgchi.spec1(:,id41),2),'r');% hi_fast
loglog(freq,nanmean(avgchi.spec2(:,id42),2),'r.');% hi_fast
ylabel('\phi_{T_x}');xlabel('frequency [Hz]')
%%
% noise spectra - save the files
noise.freq=freq;
% fit a curve
noise.spec=nanmean(avgchi.spec1(:,id31),2);
noise.coef=polyfit(log10(noise.freq),log10(noise.spec),4);
noise.fit_spec=polyval(noise.coef,log10(noise.freq));noise.fit_spec=10.^noise.fit_spec;
save([dpath '\noise_spec\noise_spec_chipod',num2str(unit),'_T1'],'noise')
% fit a curve
noise.spec=nanmean(avgchi.spec2(:,id32),2);
p=polyfit(log10(noise.freq),log10(noise.spec),4);
noise.coef=polyfit(log10(noise.freq),log10(noise.spec),4);
noise.fit_spec=polyval(noise.coef,log10(noise.freq));noise.fit_spec=10.^noise.fit_spec;
save([dpath '\noise_spec\noise_spec_chipod',num2str(unit),'_T2'],'noise')
% plot noise spectra
figure(67);clf
load([dpath '\noise_spec\noise_spec_chipod',num2str(unit),'_T1'])
loglog(noise.freq,noise.spec,'k');hold on;grid on
loglog(noise.freq,noise.fit_spec,'color',.5*[1 1 1]);
load([dpath '\noise_spec\noise_spec_chipod',num2str(unit),'_T2'])
loglog(noise.freq,noise.spec,'k--');hold on; grid on
loglog(noise.freq,noise.fit_spec,'--','color',.7*[1 1 1]);
legend('T_1','T_1 fit','T_2','T_2 fit','location','NW');legend boxoff
xlabel('frequency [Hz]')
ylabel('\phi_{T_x}')
title(['chipod unit ',num2str(unit),' / noise spectra'])
print('-dpng','-r150',[dpath '\noise_spec\noise_chipod_unit_',num2str(unit)]);
