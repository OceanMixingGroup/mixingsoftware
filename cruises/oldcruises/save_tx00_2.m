for ix=[1968:1977];
q.script.num=ix;
q.script.prefix='tx00';
q.script.pathname='r:\';
clear cal data

global data head irep q
raw_load

cali_tx00_2

if cal.P(end)>cal.P(1)  % only do down profiles

rho=cal.SIGTH(1:1:length(cal.SIGTH)-1);
g=9.81;
rhoav=1023;

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


% save selected cal data
dat.p=cal.P(1:head.irep.P:end);
dat.fallspd=cal.FALLSPD(1:head.irep.FALLSPD:end);
dat.theta=cal.THETA(1:head.irep.THETA:end);
dat.tp=cal.TP(1:head.irep.TP:end);
dat.sal=cal.SAL(1:head.irep.SAL:end);
dat.sigt=cal.SIGTH(1:head.irep.SIGTH:end);
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

figure(1)
xl=[1021.5 1026.1];
yl=[-40 0];
subplot(131),plot(cal.SIGTH,-cal.P);grid
set(gca,'xlim',xl,'ylim',yl);
xl=[-7.5 7.5];
subplot(132),plot(dat.tp,-dat.p);grid
set(gca,'xlim',xl,'ylim',yl);
title(num2str(q.script.num),'fontsize',16)
xl=[0 0.5];
subplot(133),plot(dat.scat,-dat.p);grid
set(gca,'xlim',xl,'ylim',yl);

pause(0.5)

fout=['d:\analysis\tx00\chameleon\all_down\dntx00.',num2str(q.script.num)];

eval(['save ',fout,' hd dat'])

end %if cal.P(end)>cal.P(1)
end