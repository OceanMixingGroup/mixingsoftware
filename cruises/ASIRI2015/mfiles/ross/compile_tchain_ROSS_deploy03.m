% script to compile T_chain data.
clear all
datapath56='/Volumes/scienceparty_share/ROSS/Deploy3/SBE/';
tchain.depth56=[0.6 1.6 2.6 3.6 4.6 6.6 5.6 7.6 8.6 9.6 11.5 12.6 13.6 14.6 15.6 16.6 17.6 18.6 19.6];
tchain.ser56=[0358 0333 0335 0337 0336 342 0334 0354 0340 0349 0351 0344 0356 0348 0350 0347 0353 0341 0355];
offset=[0 9 9 9 9 9 0 0 0 1 -3 -3 -3 0 0 0 0 0 0 15]./24./3600;
patm=10; %assumed
starttime=datenum('05-Sep-2015-03:35:00'); 
endtime=datenum('05-Sep-2015-9:55:00');
clf
tchain.config.tlims=[starttime
    endtime];
delt=2/24/3600; % 2 second interpolation
tchain.date=tchain.config.tlims(1):delt:tchain.config.tlims(2);
tchain.T=NaN*zeros(length(tchain.depth56),length(tchain.date));
for a=1:length(tchain.ser56);

fname=['SBE05600' num2str(tchain.ser56(a)) '_2015-09-05.cnv'];

sbe = load_sbe56_cnv2mat(datapath56,fname,offset(a));

tmp=nonmoninterp1(sbe.time,sbe.T,tchain.date);
tchain.T(a,:)=tmp';
plotit=0;
if [plotit] %#ok<NBRAK,BDSCA>
plot(sbe.time,sbe.T);
hold on
pause(.1)
end
end
tchain.zgrad=diff(tchain.T);
colormap('jet')
clf
pcolor(tchain.date,-tchain.depth56,tchain.T);shading flat; colorbar
caxis([29.2 29.5])
xlim([starttime endtime])
datetick('keeplimits','keepticks')
title 'SBE56 Temp, ROSS 3rd deploy'
ylabel 'Depth (m)'
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy3_SBE56_T.png','-dpng','-r300')

clf
pcolor(tchain.date,-tchain.depth56(1:end-1),tchain.zgrad);shading flat; colorbar
% xlim([datenum('24-Aug-2015-05:45:00') datenum('25-Aug-2015-05:30:00')])
title 'SBE56 Temp z-grad, ROSS 3rd deploy'
ylabel 'Depth (m)'
datetick('keeplimits','keepticks')
caxis([-0.01 0.01])
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy3_SBE56_T_z-grad.png','-dpng','-r300')

%% Add the RBR concertos and the microcat manually
RSK=RSKopen('/Volumes/scienceparty_share/ROSS/Deploy3/rbr/060080_20150906_0253.rsk');
RSK=RSKreaddata(RSK,starttime,endtime);
RBR.SN60080.T=RSK.data.values(:,2);
RBR.SN60080.P=RSK.data.values(:,3)-patm;
RBR.SN60080.C=RSK.data.values(:,1);
RBR.SN60080.time=RSK.data.tstamp;
RBR.SN60080.S=sw_salt(RBR.SN60080.C/sw_c3515,RBR.SN60080.T,RBR.SN60080.P);
clear RSK

RSK=RSKopen('/Volumes/scienceparty_share/ROSS/Deploy3/rbr/060182_20150906_0301.rsk');
RSK=RSKreaddata(RSK,starttime-8/24/3600,endtime-8/24/3600);
RBR.SN60182.T=RSK.data.values(:,2);
RBR.SN60182.P=RSK.data.values(:,3)-patm;
RBR.SN60182.C=RSK.data.values(:,1);
RBR.SN60182.S=sw_salt(RBR.SN60182.C/sw_c3515,RBR.SN60182.T,RBR.SN60182.P);
clear RSK

ctd=read_sbe('/Volumes/scienceparty_share/ROSS/Deploy3/SBE/ROSS_sbe37_SN2528_090515_deploy03.asc');
ctdinds=find(ctd.time<endtime-150/24/3600 & ctd.time>starttime-150/24/3600);
SB37.T=ctd.T(ctdinds);
SB37.C=ctd.C(ctdinds)*10;
SB37.P=ctd.P(ctdinds);
SB37.time=ctd.time(ctdinds);
clear ctd
SB37.S=sw_salt(SB37.C/sw_c3515,SB37.T,SB37.P);

%we now have the RBRs loaded and SBE56s in an array. Time to merge them and
%use the pressure to determine the true depth. First we need to sub-sample
%down to the correct number of samples

%% sub-sampling
dfac=36;
win=hann(2*dfac)/sum(hann(2*dfac));
RBR.SN60080.T=decimate(conv(RBR.SN60080.T-mean(RBR.SN60080.T),win,'same'),dfac)+mean(RBR.SN60080.T);
RBR.SN60080.S=decimate(conv(RBR.SN60080.S-mean(RBR.SN60080.S),win,'same'),dfac)+mean(RBR.SN60080.S);
RBR.SN60080.P=decimate(conv(RBR.SN60080.P-mean(RBR.SN60080.P),win,'same'),dfac)+mean(RBR.SN60080.P);
RBR.SN60080.C=decimate(conv(RBR.SN60080.C-mean(RBR.SN60080.C),win,'same'),dfac)+mean(RBR.SN60080.C);

RBR.SN60182.T=decimate(conv(RBR.SN60182.T-mean(RBR.SN60182.T),win,'same'),dfac)+mean(RBR.SN60182.T);
RBR.SN60182.S=decimate(conv(RBR.SN60182.S-mean(RBR.SN60182.S),win,'same'),dfac)+mean(RBR.SN60182.S);
RBR.SN60182.P=decimate(conv(RBR.SN60182.P-mean(RBR.SN60182.P),win,'same'),dfac)+mean(RBR.SN60182.P);
RBR.SN60182.C=decimate(conv(RBR.SN60182.C-mean(RBR.SN60182.C),win,'same'),dfac)+mean(RBR.SN60182.C);
%this time we also have to down-sample the sbe56s
dfac=3;
win=hann(2*dfac)/sum(hann(2*dfac));
for i=1:min(size(tchain.T))
   tchain.Ti(i,:)=decimate(conv(tchain.T(i,:)-mean(tchain.T(i,:)),win ,'same'),dfac)+mean(tchain.T(i,:));
end
clear tchain.T
tchain.T=tchain.Ti;
clear tchain.Ti
tchain.date=decimate(conv(tchain.date-mean(tchain.date),win,'same'),dfac)+mean(tchain.date);

%% Depth correction
inds.rope1=1:11;
inds.rope2=12:19;
ptop{1}=SB37.P;
pbot{1}=RBR.SN60080.P(1:end-1);
ptop{2}=pbot{1};
pbot{2}=RBR.SN60182.P(1:end-1);
tchain.depth56s=tchain.depth56(:,1:end-1);
%string 1
for i=1:length(inds.rope1); rope1_depth(i,:)=tchain.depth56(inds.rope1(i))*((pbot{1}-ptop{1})/12.6)+ptop{1};end %#ok<*SAGROW>
%string 2
for i=1:length(inds.rope2); rope2_depth(i,:)=(tchain.depth56(inds.rope2(i))-12.6).*((pbot{2}-ptop{2})/7)+ptop{2};end

%% populate

chain.depth(1,:)=ptop{1};
chain.depth(2:12,:)=rope1_depth;
chain.depth(13,:)=ptop{2};
chain.depth([14:20 22],:)=rope2_depth;
chain.depth(21,:)=pbot{2};

chain.T=NaN.*chain.depth;
chain.S=chain.T;

chain.T(1,:)=SB37.T;
chain.T(2:12,:)=tchain.T(inds.rope1,1:end-1);
chain.T(13,:)=RBR.SN60080.T(1:end-1);
chain.T([14:20 22],:)=tchain.T(inds.rope2,1:end-1);
chain.T(21,:)=RBR.SN60182.T(1:end-1);

chain.S(1,:)=SB37.S;
chain.S(13,:)=RBR.SN60080.S(1:end-1);
chain.S(21,:)=RBR.SN60182.S(1:end-1);

for i=1:22; chain.time(i,:)=tchain.date(1:end-1); end
%% clean up
%one of the RBRs is weird, removing it:
chain.time(20,:)=[];
chain.T(20,:)=[];
chain.depth(20,:)=[];
chain.S(20,:)=[];

%% correct for systematic offsets

%determine the time window with high corrolated vertical structure and
%choose the good t-logger

% good_t_logger=14;
% checkwin=[datenum('24-Aug-2015-12:10:00') datenum('24-Aug-2015-12:15:00')];
% chkinds=find(chain.time(1,:)<=checkwin(2) & chain.time(1,:)>=checkwin(1));
% 
% %ft the temp data
% 
% N=length(chain.time(1,chkinds));
% nwin=N; %does this make sense?
% dt=1;
% sjhat=1e02;
% f=0.4;
% q_lower=3.24697;
% q_upper=20.4831;
% M=10;
% f_N=1/(2*dt);
% win=hann(nwin)/sum(hann(nwin));
% lower=M/q_lower*sjhat;
% upper=M/q_upper*sjhat;
% for i=1:min(size(chain.T))
% clf
% mt=mean(chain.T(i,chkinds));
% ft_T(i,:)=1/N*fftshift(fft(conv(chain.T(i,chkinds)-mt,win,'same')));
% fj(i,:)=-f_N:1/(N*dt):f_N-1/(N*dt);
% Sj_T(i,:)=N*dt*ft_T(i,:).*conj(ft_T(i,:));  %autocorrolation
% fj_cut(i,:)=fj(i,ceil(5/2):5:end);
% for ii=1:floor(N/5); Sj_ba(i,ii)=sum(Sj_T(i,5*ii-4:5*ii))/5;end
% semilogy(fj_cut(i,:),Sj_ba(i,:))
% hold on
% xlim([0 f_N])
% plot(f,sjhat,'*k', [f,f], [lower,upper],'k')
% pause(0.5)
% end

%cross-corrolation and phase
% for i=2:min(size(chain.T))
% Sxy=N*delta_t*ft_T(1,:).*ft_T(i,:);
% for ii=1:floor(N/5); Sxy_ba(i,ii)=sum(Sxy(5*ii-4:5*ii))/5; end
% cohere=(conj(Sxy_ba).*Sxy_ba)./(Sj_ba199.*Sj_ba97);
% phase=atan2(-imag(Sxy_ba),real(Sxy_ba));
% gamcrit=(finv(0.95,2,M-2)/((M-2)/2+finv(0.95,2,M-2)));
% gamcritarr=gamcrit*ones(1,length(fj_cut97));
% end
%determine the offsets and add them

%% plot the corrected temperature vs. corrected depth

figure(101)
clf
pcolor(chain.time,-chain.depth,chain.T), shading flat
colormap('jet')
caxis([28.5 29])
colorbar
title 'ROSS 3rd Deploy: temperature (C) vs. pressure corrected depth'
ylabel 'Depth (m)'
datetick('keeplimits','keepticks')
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy3_T_press_corrected.png','-dpng','-r300')



%% 3D cross-sectional plot in lat-lon-z space

%lat and lon as function of time
%parameterize
%????
%profit


%% T-S plot for the middle bin
clf
plot(RBR.SN60080.T,RBR.SN60080.S, '.k')
title 'T-S at SN60080'
ylabel 'S (psu)'
xlabel 'T(C)'
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy3_T-S.png','-dpng','-r300')


%% plot temperature varience

%40 second running average 
chain.varT=chain.T*NaN;
for i=1:min(size(chain.T));
   chain.varT(i,:)=run_avg((chain.T(i,:)-run_avg(chain.T(i,:),20,chain.time(i,:))).^2, 20, chain.time(i,:));
%    clf
%    plot(chain.time(i,:),chain.varT(i,:))
%    pause(0.1)
%    title(num2str(i))
end

clf
pcolor(chain.time,-chain.depth,log10(chain.varT))
shading flat
colorbar
title 'log10(varT)'
ylabel 'depth (m)'
datetick('keeplimits','keepticks')
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy3_varT_press_corrected.png','-dpng','-r300')
clf
subplot(2,1,2)
pcolor(chain.time,-chain.depth,log10(chain.varT))
shading flat
colorbar
title 'log10(varT) zoom'
ylabel 'Depth (m)'
ylim([-15 0])
caxis([-6 -3])
%xlim([datenum('24-Aug-2015-12:00:00') datenum('24-Aug-2015-14:00:')])
datetick('keeplimits','keepticks')
subplot(2,1,1)
pcolor(chain.time,-chain.depth,chain.T), shading flat
colormap('jet')
caxis([28.5 29])
colorbar
title 'ROSS 3rd Deploy: temperature (C) vs. pressure corrected depth zoom'
ylabel 'Depth (m)'
%xlim([datenum('24-Aug-2015-12:00:00') datenum('24-Aug-2015-14:00:')])
ylim([-15 0])
datetick('keeplimits','keepticks')

h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy3_varT_and_T_press_corrected_zoom.png','-dpng','-r300')

%% Add interped salinity (work in progress)
% 
% for i=2:6
%     chain.S(i,:)=chain.S(7,:)+(chain.S(1,:)-chain.S(7,:)).*((chain.T(7,:)-chain.T(i,:))./(-chain.T(1,:)+chain.T(7,:)));
% end
% for i=8:12  
%     chain.S(i,:)=chain.S(13,:)+(chain.S(7,:)-chain.S(13,:)).*((chain.T(7,:)-chain.T(i,:))./(-chain.T(7,:)+chain.T(13,:))); 
% end
% for i=14:20
%     chain.S(i,:)=chain.S(20,:)+(chain.S(13,:)-chain.S(20,:)).*((chain.T(13,:)-chain.T(i,:))./(-chain.T(13,:)+chain.T(20,:)));
% end
% 

%% Add ADCP data

load('/Volumes/scienceparty_share/ROSS/Deploy3/adcp/mat/Deploy3_adcp_proc_smoothed.mat');
adcpinds=find(vel.dnum>starttime & vel.dnum<endtime);
chain.u=vel.u(:,adcpinds);
chain.v=vel.v(:,adcpinds);
chain.u=conv2(vel.u(:,adcpinds),hann(540)'/sum(hann(540)),'same');
chain.v=conv2(vel.v(:,adcpinds),hann(540)'/sum(hann(540)),'same');
chain.adcp_z=vel.z;
chain.adcp_time=vel.dnum(adcpinds);
chinds=NaN*chain.time(1,1:end-5);
for i=1:length(chinds); chinds(i)=find(chain.adcp_time >= chain.time(1,i), 1 ); end
chain.adcp_lat=vel.lat(adcpinds);
chain.adcp_lon=vel.lon(adcpinds);
for i=1:21; chain.lat(i,:)=chain.adcp_lat(chinds); end
for i=1:21; chain.lon(i,:)=chain.adcp_lon(chinds); end

%% calculate Shear
chain.Shear_u=diff(chain.u);
chain.Shear_v=diff(chain.v);
chain.square_Shear=chain.Shear_u.^2+chain.Shear_v.^2;

figure(101)
clf
subplot(3,1,1)
pcolor(chain.adcp_time,-chain.adcp_z(1:end-1), chain.Shear_u)
shading flat
colorbar
colormap('bluered')
ylabel 'Depth (m)'
title 'ROSS 3rd Deploy: Shear (u-component)'
datetick('keeplimits','keepticks')
caxis([-0.1 0.1])
subplot(3,1,2)
pcolor(chain.adcp_time,-chain.adcp_z(1:end-1), chain.Shear_v)
shading flat
colorbar
colormap('bluered')
ylabel 'Depth (m)'
title 'ROSS 3rd Deploy: Shear (v-component)'
datetick('keeplimits','keepticks')
caxis([-0.1 0.1])
subplot(3,1,3)
pcolor(chain.adcp_time,-chain.adcp_z(1:end-1), chain.square_Shear)
shading flat
colorbar
colormap('bluered')
ylabel 'Depth (m)'
title 'ROSS 3rd Deploy: Shear^2'
datetick('keeplimits','keepticks')
caxis([0 0.002])
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy03_Shear.png','-dpng','-r300')

%% make all of the plots!!!!

colormap('redblue3')
clf
subplot(3,1,1)
pcolor(chain.adcp_time, -chain.adcp_z, chain.u)
shading interp
caxis([-0.5 0.5])
colorbar
datetick('keeplimits','keepticks')
title 'u (m/s) in time'
subplot(3,1,2)
pcolor(chain.adcp_lat, -chain.adcp_z, chain.u)
shading interp
caxis([-0.5 0.5])
colorbar
title 'u(m/s) in latitude'
subplot(3,1,3)
pcolor(chain.adcp_lon, -chain.adcp_z, chain.u)
shading interp
caxis([-0.5 0.5])
colorbar
title 'u(m/s) in longitude'
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy3_u.png','-dpng','-r300')

clf
subplot(3,1,1)
pcolor(chain.adcp_time, -chain.adcp_z, chain.u)
shading flat
caxis([-0.5 0.5])
colorbar
datetick('keeplimits','keepticks')
title 'v (m/s) in time'
subplot(3,1,2)
pcolor(chain.adcp_lat, -chain.adcp_z, chain.u)
shading flat
caxis([-0.5 0.5])
colorbar
title 'v(m/s) in latitude'
subplot(3,1,3)
pcolor(chain.adcp_lon, -chain.adcp_z, chain.u)
shading flat
caxis([-0.5 0.5])
colorbar
title 'v(m/s) in longitude'
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy3_v.png','-dpng','-r300')

%% now for the main plot:
 zoomwin=[datenum('5-Sep-2015-05:00:00') datenum('5-Sep-2015-07:00:00')];
zinds=find(chain.time(1,:)>zoomwin(1) & chain.time(1,:)< zoomwin(2));
adcpzinds=find(chain.adcp_time>zoomwin(1) & chain.adcp_time<zoomwin(2));
clf
subplot(5,1,1)
pcolor(chain.adcp_lat(adcpzinds), -chain.adcp_z, chain.v(:,adcpzinds))
shading interp
caxis([-0.7 0.7])
colorbar
title 'ROSS 3rd deploy: v(m/s)'
ylabel 'depth (m)'
xlabel 'Latitude'
colormap(gca,'bluered')
ylim([-45 0]);
subplot(5,1,2)
pcolor(chain.adcp_lat(adcpzinds), -chain.adcp_z, chain.u(:,adcpzinds))
shading interp
caxis([-0.7 0.7])
colorbar
title 'ROSS 3rd deploy: u(m/s)'
ylabel 'depth (m)'
colormap(gca,'bluered')
ylim([-45 0]);
subplot(5,1,5)
pcolor(chain.lat(:,zinds),-chain.depth(:,zinds),log10(chain.varT(:,zinds)))
shading flat
colorbar
title 'ROSS 3rd deploy: log temperature variance (C^2)'
ylabel 'Depth (m)'
ylim([-15 0])
colormap(gca,'jet')
caxis([-6 -3])
subplot(5,1,4)
pcolor(chain.lat(:,zinds),-chain.depth(:,zinds),chain.T(:,zinds)), shading flat
colormap(gca,'jet')
caxis([28.8 28.9])
colorbar
title 'ROSS 3rd Deploy: Temperature (C)'
ylabel 'Depth (m)'
ylim([-15 0])
subplot(5,1,3)
%plot(chain.lat(1,zinds),chain.S(7,zinds))
[c,h]=contourf(chain.lat([1 13 20],zinds),-chain.depth([1 13 20],zinds),chain.S([1 13 20],zinds),64);
%pcolor(chain.lat(:,zinds),-chain.depth(:,zinds),chain.S(:,zinds)), shading flat
set(h,'LineColor','none')
colorbar
colormap(gca,'jet')
caxis([30.2 31])
ylim([-15 0])
title 'ROSS 3rd Deploy: Salinity (psu)'
ylabel 'Depth (m)'
xlabel 'Latitude'

h=gcf;
set(h,'PaperOrientation','portrait')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_3rd_deploy_multi.png','-dpng','-r250')

clf
subplot(3,1,1)
pcolor(chain.adcp_lat(adcpzinds),-chain.adcp_z(1:end-1), chain.Shear_u(:,adcpzinds))
shading flat
colorbar
colormap('bluered')
ylim([-45 0])
ylabel 'Depth (m)'
xlabel 'Latitude'
title 'ROSS 3rd Deploy: Shear (u-component)'
caxis([-0.1 0.1])
subplot(3,1,2)
pcolor(chain.adcp_lat(adcpzinds),-chain.adcp_z(1:end-1), chain.Shear_v(:,adcpzinds))
shading flat
colorbar
colormap('bluered')
ylim([-45 0])
ylabel 'Depth (m)'
xlabel 'Latitude'
title 'ROSS 3rd Deploy: Shear (v-component)'
caxis([-0.1 0.1])
subplot(3,1,3)
pcolor(chain.adcp_lat(adcpzinds),-chain.adcp_z(1:end-1), chain.square_Shear(:,adcpzinds))
shading flat
colorbar
colormap('bluered')
ylim([-45 0])
ylabel 'Depth (m)'
xlabel 'Latitude'
title 'ROSS 3rd Deploy: Shear^2'
caxis([0 0.002])
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy03_Shear_zoom.png','-dpng','-r300')

%% add meta data
chain.info='made with compile_tchain_ROSS_deploy03.m';

%% save the data

save('/Users/mixz/Desktop/ROSS_DATA/processed/deploy3.mat','chain','-v7.3')

%  clear all
%  close all