for i=[60:76;82;84;87:89;91:113;118:134;235:243;245:246;248:249;251:254];
q.script.num=i;
q.script.prefix='bc9';
q.script.pathname='e:\raw_data\';
clear cal data

raw_load

cali_bc90

%do other stuff
rho=cal.SIGTH(1:1:length(cal.SIGTH)-1);
cal.SIGTH=cal.SIGTH;
cal.SIGTH_ORDER=cal.SIGTH_ORDER;
g=9.81;
rhoav=1023;
cal.BV2=(g/rhoav).*diff(cal.SIGTH_ORDER)./diff(cal.P)
cal.BV2(length(cal.BV2)+1)=cal.BV2(length(cal.BV2));
head.irep.BV2=head.irep.P;
cal.VARLT=(cal.THORPE-mean(cal.THORPE)).^2; %variance Thorpe scale 
head.irep.VARLT=head.irep.THORPE;
cal.VARAZ=(cal.AZ-mean(cal.AZ)).^2; %variance of AZ
head.irep.VARAZ=head.irep.AZ;

avg=average_data({'P','FALLSPD','THETA','SAL','SIGTH','SIGTH_ORDER','BV2','VARLT','epsilon1','epsilon2','varaz'},'depth_min',0,'binsize',4,'nfft',256)
avg.LT=sqrt(avg.VARLT);

% flag AZ vibrations
idx=find(avg.VARAZ>3.e-05)
avg.EPSILON1(idx)=NaN;
avg.EPSILON2(idx)=NaN;
avg.EPS=(avg.EPSILON1+avg.EPSILON2)./2

% compute Ozmidov scale
bv=sqrt(avg.BV2);
avg.LO=sqrt((avg.EPS)./(bv).^3)

figure(1)
subplot(181),plot(avg.FALLSPD,-avg.P);grid
ylabel('depth [m]')
xlabel('fallspd')
subplot(182),plot(avg.THETA,-avg.P);grid
xlabel('\theta')
subplot(183),plot(avg.SAL,-avg.P);grid
xlabel('salinity')
subplot(184),plot(avg.SIGTH,-avg.P,avg.SIGTH_ORDER,-avg.P);grid
xlabel('sigma_{\theta}')
subplot(185),plot(avg.BV2,-avg.P);grid
xlabel('N^2')
subplot(186),plot(avg.LT,-avg.P,avg.LO,-avg.P);grid
xlabel('L_T,L_o')
subplot(187),semilogx(avg.EPSILON1,-avg.P,avg.EPSILON2,-avg.P,avg.EPS,-avg.P,'k');grid
xlabel('\epsilon')
subplot(188),semilogx(avg.VARAZ,-avg.P);grid
xlabel('A_z')

temp=num2str(q.script.num+10000)
fn=['c:\data\bc90\length_scales\' q.script.prefix '_' temp(2:5)]
eval(['save ' fn ' avg']);
clear cal
clear data
clear avg
clear bv rho idx head cond temp press inds

end
