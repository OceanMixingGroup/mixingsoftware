for ix=[302:302];
q.script.num=ix;
q.script.prefix='tx00';
q.script.pathname='r:\';
clear cal data

global data head irep q
raw_load

cali_tx00

% set variables
av.depth=[];
av.fallspd=[];
av.theta=[];
av.dtdz=[];
av.sal=[];
av.sigth=[];
av.buoy_freq=[];
av.lt=[];
av.eps=[];
av.eps1=[];
av.eps2=[];
av.varaz=[];

rho=cal.SIGTH(1:1:length(cal.SIGTH)-1);
g=9.81;
rhoav=1023;
cal.BV2=(g/rhoav).*diff(cal.SIGTH_ORDER)./diff(cal.P)
cal.BV2(length(cal.BV2)+1)=cal.BV2(length(cal.BV2));
head.irep.BV2=head.irep.P;
cal.DTDZ=diff(cal.THETA_ORDER)./diff(cal.P)
cal.DTDZ(length(cal.DTDZ)+1)=cal.DTDZ(length(cal.DTDZ));
head.irep.DTDZ=head.irep.P;
cal.VARLT=(cal.THORPE_SIGTH-mean(cal.THORPE_SIGTH)).^2; %variance Thorpe scale 
head.irep.VARLT=head.irep.THORPE_SIGTH;
cal.VARAZ=(cal.AZ-mean(cal.AZ)).^2; %variance of AZ
head.irep.VARAZ=head.irep.AZ;

% compute horizontal location of Chameleon
% when recovering and recording upward
% assume total body tilt = sqrt(xtilt^2 + ytilt^2) is in
% direction toward ship
% use fallspd as vertical velocity to get horizontal speed
%			u=fallspd*tan(tilt)
% then integrate to get horizontal distance toward ship

tilt=sqrt(cal.AX_TILT.^2 + cal.AY_TILT.^2); % tilt magnitude
horspd=cal.FALLSPD.*tan(tilt(1:2:end)*pi/180); % horizontal speed 
cal.X=cumsum((1/(100*slow_samp_rate)).*horspd); % horizontal distance
head.irep.X=head.irep.P;

avg=average_data({'P','X','FALLSPD','THETA','SAL','SIGTH','SIGTH_ORDER','BV2','VARLT', ...
      'epsilon1','epsilon2','varaz','DTDZ'},'min_bin',3,'binsize',1,'nfft',128)


% flag AZ vibrations
idaz=find(avg.VARAZ>1.e-02);
avg.EPSILON1(idaz)=NaN;
avg.EPSILON2(idaz)=NaN;
avg.EPS=(avg.EPSILON1+avg.EPSILON2)./2;
% set last eps values to NaN
avg.EPS(end)=NaN;
% flag up casts
if (cal.P(end)<cal.P(1))
   avg.EPSILON1(1:end)=NaN;
   avg.EPSILON2(1:end)=NaN;
   avg.EPS=(avg.EPSILON1+avg.EPSILON2)./2;
   cal.TP(1:end)=NaN;
   cal.THORPE_SIGTH(1:end)=NaN;
end

% save selected cal data
dat.p=cal.P(1:head.irep.P:end);
dat.x=cal.X(1:head.irep.X:end);
dat.fallspd=cal.FALLSPD(1:head.irep.FALLSPD:end);
dat.theta=cal.THETA(1:head.irep.THETA:end);
dat.lt=cal.THORPE_SIGTH(1:head.irep.THORPE_SIGTH:end);
dat.tp=cal.TP(1:head.irep.TP:end);
dat.sal=cal.SAL(1:head.irep.SAL:end);
dat.sigt=cal.SIGTH(1:head.irep.SIGTH:end);
dat.axtilt=cal.AX_TILT(1:head.irep.AX_TILT:end);
dat.aytilt=cal.AY_TILT(1:head.irep.AY_TILT:end);
dat.scat=cal.SCAT(1:head.irep.SCAT:end);

% save header data 
hd.profile_num=q.script.num;
hd.time_gps.start=[head.time.start(1:2),':',head.time.start(3:4),':',head.time.start(5:6)];
hd.time_gps.end=[head.time.end(1:2),':',head.time.end(3:4),':',head.time.end(5:6)];
hd.time_das.start=[head.starttime(15:17),' ',head.starttime(6:7),':',head.starttime(9:10),':',head.starttime(12:13)];
hd.time_das.end=[head.endtime(15:17),' ',head.endtime(6:7),':',head.endtime(9:10),':',head.endtime(12:13)];
hd.lat.start=head.lat.start;
hd.lat.end=head.lat.end;
hd.lon.start=head.lon.start;
hd.lon.end=head.lon.end;

% save averaged data
av.depth=[av.depth avg.P];
av.fallspd=[av.fallspd avg.FALLSPD];
av.theta=[av.theta avg.THETA];
av.dtdz=[av.dtdz avg.DTDZ];
av.sal=[av.sal avg.SAL];
av.sigth=[av.sigth avg.SIGTH];
av.buoy_freq=[av.buoy_freq sqrt(abs(avg.BV2))]; %buoyancy frequency
av.lt=[av.lt sqrt(avg.VARLT)]; %rms thorpe scale
av.eps1=[av.eps1 avg.EPSILON1];
av.eps2=[av.eps2 avg.EPSILON2];
av.eps=[av.eps avg.EPS];
av.varaz=[av.varaz avg.VARAZ];


figure(1)
xl=[1021.5 1026.1];
yl=[-40 0];
subplot(151),plot(cal.SIGTH,-cal.P);grid
set(gca,'xlim',xl,'ylim',yl);
xl=[0 0.12];
subplot(152),plot(av.buoy_freq,-av.depth);grid
set(gca,'xlim',xl,'ylim',yl);
xl=[1e-10 2e-4];
title(num2str(q.script.num),'fontsize',16)
subplot(153),semilogx(av.eps1,-av.depth,av.eps2,-av.depth,av.eps,-av.depth);grid
set(gca,'xlim',xl,'ylim',yl);
xl=[-7.5 7.5];
subplot(154),plot(dat.tp,-dat.p);grid
set(gca,'xlim',xl,'ylim',yl);
xl=[0 0.5];
subplot(155),plot(dat.scat,-dat.p);grid
set(gca,'xlim',xl,'ylim',yl);

figure(2);clf
subplot(131)
plot(cal.AX_TILT(1:head.irep.AX_TILT:end),-cal.P);hold on
plot(cal.AY_TILT(1:head.irep.AY_TILT:end),-cal.P,'r');grid on
set(gca,'ylim',yl);
subplot(132),plot(tilt(1:2:end),-cal.P);grid
set(gca,'ylim',yl);
subplot(133),plot(cal.X,-cal.P);grid
set(gca,'ylim',yl);

pause(0.5)

%fout=['d:\analysis\tx00\chameleon\chamtx00.',num2str(q.script.num)];

%eval(['save ',fout,' hd dat av'])

end