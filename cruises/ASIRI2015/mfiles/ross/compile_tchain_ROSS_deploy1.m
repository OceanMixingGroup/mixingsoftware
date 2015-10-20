% script to compile T_chain data.
clear all
datapath56='/Users/mixz/Desktop/ROSS_DATA/SBE';
%datapath37='../data/raw/T-chain/sbe37/';

tchain.depth56=[0.6 1.6 2.6 3.6 4.6 6.6 7.6 8.6 9.6 10.6 12.6 13.6 14.6 15.6 16.6 17.6 18.6 19.6];
%tchain.depth37=[-.5 1.5 3.5 9.8];
tchain.ser56=[0358 0333 0335 0337 0336 0334 0354 0340 0349 0351 0344 0356 0348 0350 0347 0353 0341 0355];
offset=[0 9 9 9 9 9 0 0 0 1 -3 -3 -3 0 0 0 0 0 0 0]./24./3600;
%tchain.ser37=[10550 7819 10553 7812];
patm=10; %assumed
starttime=datenum('24-Aug-2015-05:45:00'); 
endtime=datenum('25-Aug-2015-05:30:00');
clf
tchain.config.tlims=[starttime
    endtime];
delt=2/24/3600; % 2 second interpolation
tchain.date=tchain.config.tlims(1):delt:tchain.config.tlims(2);
tchain.T=NaN*zeros(length(tchain.depth56),length(tchain.date));
for a=1:length(tchain.ser56);

fname=['SBE05600' num2str(tchain.ser56(a)) '_2015-08-25.cnv'];

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
title 'SBE56 Temp, ROSS 1st deploy'
ylabel 'Depth (m)'
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy1_SBE56_T.png','-dpng','-r300')

clf
pcolor(tchain.date,-tchain.depth56(1:end-1),tchain.zgrad);shading flat; colorbar
xlim([datenum('24-Aug-2015-05:45:00') datenum('25-Aug-2015-05:30:00')])
title 'SBE56 Temp z-grad, ROSS 1st deploy'
ylabel 'Depth (m)'
datetick('keeplimits','keepticks')
caxis([-0.01 0.01])
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy1_SBE56_T_z-grad.png','-dpng','-r300')

%% Add the RBR concertos manually
RSK=RSKopen('/Users/mixz/Desktop/ROSS_DATA/RBR/060093_20150825_1437.rsk');
RSK=RSKreaddata(RSK,starttime,endtime);
RBR.SN60093.T=RSK.data.values(:,2);
RBR.SN60093.P=RSK.data.values(:,3)-patm;
RBR.SN60093.C=RSK.data.values(:,1);
RBR.SN60093.time=RSK.data.tstamp;
RBR.SN60093.S=sw_salt(RBR.SN60093.C/sw_c3515,RBR.SN60093.T,RBR.SN60093.P);
clear RSK
clf
plot(RBR.SN60093.time,RBR.SN60093.P)
pause(5.0)

RSK=RSKopen('/Users/mixz/Desktop/ROSS_DATA/RBR/060166_20150825_0809.rsk');
RSK=RSKreaddata(RSK,starttime,endtime);
RBR.SN60166.T=RSK.data.values(:,2);
RBR.SN60166.P=RSK.data.values(:,3)-patm;
RBR.SN60166.C=RSK.data.values(:,1);
RBR.SN60166.time=RSK.data.tstamp;
RBR.SN60166.S=sw_salt(RBR.SN60166.C/sw_c3515,RBR.SN60166.T,RBR.SN60166.P);
clear RSK

RSK=RSKopen('/Users/mixz/Desktop/ROSS_DATA/RBR/060182_20150825_0914.rsk');
RSK=RSKreaddata(RSK,starttime-8/24/3600,endtime-8/24/3600);
RBR.SN60182.T=RSK.data.values(:,2);
RBR.SN60182.P=RSK.data.values(:,3)-patm;
RBR.SN60182.C=RSK.data.values(:,1);
RBR.SN60182.S=sw_salt(RBR.SN60182.C/sw_c3515,RBR.SN60182.T,RBR.SN60182.P);
clear RSK

RSK=RSKopen('/Users/mixz/Desktop/ROSS_DATA/RBR/060183_20150825_0755.rsk');
RSK=RSKreaddata(RSK,starttime,endtime);
RBR.SN60183.T=RSK.data.values(:,2);
RBR.SN60183.P=RSK.data.values(:,3)-patm;
RBR.SN60183.C=RSK.data.values(:,1);
RBR.SN60183.S=sw_salt(RBR.SN60183.C/sw_c3515,RBR.SN60183.T,RBR.SN60183.P);
clear RSK

%we now have the RBRs loaded and SBE56s in an array. Time to merge them and
%use the pressure to determine the true depth. First we need to sub-sample
%down to the correct number of samples

%% sub-sampling
dfac=12;
win=hann(2*dfac)/sum(hann(2*dfac));
RBR.SN60093.T=decimate(conv(RBR.SN60093.T-mean(RBR.SN60093.T),win,'same'),dfac)+mean(RBR.SN60093.T);
RBR.SN60093.S=decimate(conv(RBR.SN60093.S-mean(RBR.SN60093.S),win,'same'),dfac)+mean(RBR.SN60093.S);
RBR.SN60093.P=decimate(conv(RBR.SN60093.P-mean(RBR.SN60093.P),win,'same'),dfac)+mean(RBR.SN60093.P);
RBR.SN60093.C=decimate(conv(RBR.SN60093.C-mean(RBR.SN60093.C),win,'same'),dfac)+mean(RBR.SN60093.C);

RBR.SN60166.T=decimate(conv(RBR.SN60166.T-mean(RBR.SN60166.T),win,'same'),dfac)+mean(RBR.SN60166.T);
RBR.SN60166.S=decimate(conv(RBR.SN60166.S-mean(RBR.SN60166.S),win,'same'),dfac)+mean(RBR.SN60166.S);
RBR.SN60166.P=decimate(conv(RBR.SN60166.P-mean(RBR.SN60166.P),win,'same'),dfac)+mean(RBR.SN60166.P);
RBR.SN60166.C=decimate(conv(RBR.SN60166.C-mean(RBR.SN60166.C),win,'same'),dfac)+mean(RBR.SN60166.C);

RBR.SN60182.T=decimate(conv(RBR.SN60182.T-mean(RBR.SN60182.T),win,'same'),dfac)+mean(RBR.SN60182.T);
RBR.SN60182.S=decimate(conv(RBR.SN60182.S-mean(RBR.SN60182.S),win,'same'),dfac)+mean(RBR.SN60182.S);
RBR.SN60182.P=decimate(conv(RBR.SN60182.P-mean(RBR.SN60182.P),win,'same'),dfac)+mean(RBR.SN60182.P);
RBR.SN60182.C=decimate(conv(RBR.SN60182.C-mean(RBR.SN60182.C),win,'same'),dfac)+mean(RBR.SN60182.C);

RBR.SN60183.T=decimate(conv(RBR.SN60183.T-mean(RBR.SN60183.T),win,'same'),dfac)+mean(RBR.SN60183.T);
RBR.SN60183.S=decimate(conv(RBR.SN60183.S-mean(RBR.SN60183.S),win,'same'),dfac)+mean(RBR.SN60183.S);
RBR.SN60183.P=decimate(conv(RBR.SN60183.P-mean(RBR.SN60183.P),win,'same'),dfac)+mean(RBR.SN60183.P);
RBR.SN60183.C=decimate(conv(RBR.SN60183.C-mean(RBR.SN60183.C),win,'same'),dfac)+mean(RBR.SN60183.C);

%% Depth correction
inds.rope1=1:5;
inds.rope2=6:10;
inds.rope3=11:18;
ptop{1}=RBR.SN60093.P;
pbot{1}=RBR.SN60166.P;
ptop{2}=pbot{1};
pbot{2}=RBR.SN60183.P;
ptop{3}=pbot{2};
pbot{3}=RBR.SN60182.P;

%string 1
for i=1:length(inds.rope1); rope1_depth(i,:)=tchain.depth56(inds.rope1(i))*((pbot{1}-ptop{1})/5.6)+ptop{1};end %#ok<*SAGROW>
%string 2
for i=1:length(inds.rope2); rope2_depth(i,:)=(tchain.depth56(inds.rope2(i))-5.6).*((pbot{2}-ptop{2})/6)+ptop{2};end
%string 3
for i=1:length(inds.rope3); rope3_depth(i,:)=(tchain.depth56(inds.rope3(i))-11.6).*((pbot{3}-ptop{3})/9)+ptop{3};end

%% populate

chain.depth(1,:)=ptop{1};
chain.depth(2:6,:)=rope1_depth;
chain.depth(7,:)=ptop{2};
chain.depth(8:12,:)=rope2_depth;
chain.depth(13,:)=ptop{3};
chain.depth(14:21,:)=rope3_depth;
chain.depth(22,:)=pbot{3};

chain.T=NaN.*chain.depth;
chain.S=chain.T;

chain.T(1,:)=RBR.SN60093.T;
chain.T(2:6,:)=tchain.T(inds.rope1,1:end-1);
chain.T(7,:)=RBR.SN60166.T;
chain.T(8:12,:)=tchain.T(inds.rope2,1:end-1);
chain.T(13,:)=RBR.SN60183.T;
chain.T(14:21,:)=tchain.T(inds.rope3,1:end-1);
chain.T(22,:)=RBR.SN60182.T;

chain.S(1,:)=RBR.SN60093.S;
chain.S(7,:)=RBR.SN60166.S;
chain.S(13,:)=RBR.SN60183.S;
chain.S(22,:)=RBR.SN60182.S;

for i=1:22; chain.time(i,:)=tchain.date(1:end-1); end

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
caxis([29.2 29.5])
colorbar
title 'ROSS 1st Deploy: temperature (C) vs. pressure corrected depth'
ylabel 'Depth (m)'
datetick('keeplimits','keepticks')
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy1_T_press_corrected.png','-dpng','-r300')



%% 3D cross-sectional plot in lat-lon-z space

%lat and lon as function of time
%parameterize
%????
%profit


%% T-S plot for the middle bin
clf
plot(RBR.SN60166.T,RBR.SN60166.S, '.k')
title 'T-S at SN60166'
ylabel 'S (psu)'
xlabel 'T(C)'
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy1_T-S.png','-dpng','-r300')


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
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy1_varT_press_corrected.png','-dpng','-r300')
clf
subplot(2,1,2)
pcolor(chain.time,-chain.depth,log10(chain.varT))
shading flat
colorbar
title 'log10(varT) zoom'
ylabel 'Depth (m)'
ylim([-15 0])
caxis([-6 -3])
xlim([datenum('24-Aug-2015-12:00:00') datenum('24-Aug-2015-14:00:')])
datetick('keeplimits','keepticks')
subplot(2,1,1)
pcolor(chain.time,-chain.depth,chain.T), shading flat
colormap('jet')
caxis([29.2 29.5])
colorbar
title 'ROSS 1st Deploy: temperature (C) vs. pressure corrected depth zoom'
ylabel 'Depth (m)'
xlim([datenum('24-Aug-2015-12:00:00') datenum('24-Aug-2015-14:00:')])
ylim([-15 0])
datetick('keeplimits','keepticks')

h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy1_varT_and_T_press_corrected_zoom.png','-dpng','-r300')

%% Add interped salinity (work in progress)

for i=2:6
    chain.S(i,:)=chain.S(7,:)+(chain.S(1,:)-chain.S(7,:)).*((chain.T(7,:)-chain.T(i,:))./(-chain.T(1,:)+chain.T(7,:)));
end
for i=8:12  
    chain.S(i,:)=chain.S(13,:)+(chain.S(7,:)-chain.S(13,:)).*((chain.T(7,:)-chain.T(i,:))./(-chain.T(7,:)+chain.T(13,:))); 
end
for i=14:21
    chain.S(i,:)=chain.S(22,:)+(chain.S(13,:)-chain.S(22,:)).*((chain.T(13,:)-chain.T(i,:))./(-chain.T(13,:)+chain.T(22,:)));
end


%% Add ADCP data

load('/Users/mixz/Desktop/ROSS_DATA/ADCP/Deploy1_adcp_proc_smoothed.mat');
adcpinds=find(vel.dnum>starttime & vel.dnum<endtime);
chain.u=vel.u(:,adcpinds);
chain.v=vel.v(:,adcpinds);
chain.u=conv2(vel.u(:,adcpinds),hann(540)'/sum(hann(540)),'same');
chain.v=conv2(vel.v(:,adcpinds),hann(540)'/sum(hann(540)),'same');
chain.adcp_z=vel.z;
chain.adcp_time=vel.dnum(adcpinds);
for i=1:max(size(chain.T)); chinds(i)=find(chain.adcp_time >= chain.time(1,i), 1 ); end
chain.adcp_lat=vel.lat(adcpinds);
chain.adcp_lon=vel.lon(adcpinds);
for i=1:22; chain.lat(i,:)=chain.adcp_lat(chinds); end
for i=1:22; chain.lon(i,:)=chain.adcp_lon(chinds); end

%% calculate sheer
chain.sheer_u=diff(chain.u);
chain.sheer_v=diff(chain.v);
chain.square_sheer=chain.sheer_u.^2+chain.sheer_v.^2;

figure(101)
clf
subplot(3,1,1)
pcolor(chain.adcp_time,-chain.adcp_z(1:end-1), chain.sheer_u)
shading flat
colorbar
colormap('bluered')
ylabel 'Depth (m)'
title 'ROSS 1st Deploy: Sheer (u-component)'
datetick('keeplimits','keepticks')
caxis([-0.1 0.1])
subplot(3,1,2)
pcolor(chain.adcp_time,-chain.adcp_z(1:end-1), chain.sheer_v)
shading flat
colorbar
colormap('bluered')
ylabel 'Depth (m)'
title 'ROSS 1st Deploy: Sheer (v-component)'
datetick('keeplimits','keepticks')
caxis([-0.1 0.1])
subplot(3,1,3)
pcolor(chain.adcp_time,-chain.adcp_z(1:end-1), chain.square_sheer)
shading flat
colorbar
colormap('bluered')
ylabel 'Depth (m)'
title 'ROSS 1st Deploy: Sheer^2'
datetick('keeplimits','keepticks')
caxis([0 0.002])
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy01_sheer.png','-dpng','-r300')

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
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy1_u.png','-dpng','-r300')

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
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy1_v.png','-dpng','-r300')

%now for the main plot:
zoomwin=[datenum('24-Aug-2015-12:00:00') datenum('24-Aug-2015-14:00:')];
zinds=find(chain.time(1,:)>zoomwin(1) & chain.time(1,:)< zoomwin(2));
adcpzinds=find(chain.adcp_time>zoomwin(1) & chain.adcp_time<zoomwin(2));
clf
subplot(5,1,1)
pcolor(chain.adcp_lat(adcpzinds), -chain.adcp_z, chain.v(:,adcpzinds))
shading interp
caxis([-0.7 0.7])
colorbar
title 'ROSS 1st deploy: v(m/s)'
ylabel 'depth (m)'
xlabel 'Latitude'
colormap(gca,'bluered')
ylim([-45 0]);
subplot(5,1,2)
pcolor(chain.adcp_lat(adcpzinds), -chain.adcp_z, chain.u(:,adcpzinds))
shading interp
caxis([-0.7 0.7])
colorbar
title 'ROSS 1st deploy: u(m/s)'
ylabel 'depth (m)'
colormap(gca,'bluered')
ylim([-45 0]);
subplot(5,1,5)
pcolor(chain.lat(:,zinds),-chain.depth(:,zinds),log10(chain.varT(:,zinds)))
shading flat
colorbar
title 'ROSS 1st deploy: log temperature variance (C^2)'
ylabel 'Depth (m)'
ylim([-15 0])
colormap(gca,'jet')
caxis([-6 -3])
subplot(5,1,4)
pcolor(chain.lat(:,zinds),-chain.depth(:,zinds),chain.T(:,zinds)), shading flat
colormap(gca,'jet')
caxis([29.2 29.5])
colorbar
title 'ROSS 1st Deploy: Temperature (C)'
ylabel 'Depth (m)'
ylim([-15 0])
subplot(5,1,3)
%plot(chain.lat(1,zinds),chain.S(7,zinds))
[c,h]=contourf(chain.lat([1 7 13 22],zinds),-chain.depth([1 7 13 22],zinds),chain.S([1 7 13 22],zinds),64);
%pcolor(chain.lat(:,zinds),-chain.depth(:,zinds),chain.S(:,zinds)), shading flat
set(h,'LineColor','none')
colorbar
colormap(gca,'jet')
caxis([32.9 34])
ylim([-15 0])
title 'ROSS 1st Deploy: Salinity (psu)'
ylabel 'Depth (m)'
xlabel 'Latitude'

h=gcf;
set(h,'PaperOrientation','portrait')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_1st_deploy_multi.png','-dpng','-r250')

clf
subplot(3,1,1)
pcolor(chain.adcp_lat(adcpzinds),-chain.adcp_z(1:end-1), chain.sheer_u(:,adcpzinds))
shading flat
colorbar
colormap('bluered')
ylim([-45 0])
ylabel 'Depth (m)'
xlabel 'Latitude'
title 'ROSS 1st Deploy: Sheer (u-component)'
caxis([-0.1 0.1])
subplot(3,1,2)
pcolor(chain.adcp_lat(adcpzinds),-chain.adcp_z(1:end-1), chain.sheer_v(:,adcpzinds))
shading flat
colorbar
colormap('bluered')
ylim([-45 0])
ylabel 'Depth (m)'
xlabel 'Latitude'
title 'ROSS 1st Deploy: Sheer (v-component)'
caxis([-0.1 0.1])
subplot(3,1,3)
pcolor(chain.adcp_lat(adcpzinds),-chain.adcp_z(1:end-1), chain.square_sheer(:,adcpzinds))
shading flat
colorbar
colormap('bluered')
ylim([-45 0])
ylabel 'Depth (m)'
xlabel 'Latitude'
title 'ROSS 1st Deploy: Sheer^2'
caxis([0 0.002])
h=gcf;
set(h,'PaperOrientation','landscape')
set(h,'PaperUnits','normalized')
set(h,'PaperPosition', [0 0 1 1])
print('/Users/mixz/Desktop/ROSS_DATA/processed/ROSS_deploy01_sheer_zoom.png','-dpng','-r300')

%% add meta data
chain.info='made with compile_tchain_ROSS_deploy1.m';

%% save the data

save('/Users/mixz/Desktop/ROSS_DATA/processed/deploy1.mat','chain','-v7.3')

%  clear all
%  close all