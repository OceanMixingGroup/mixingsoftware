% set variables
profile_num=[];
start_depth=[];
end_depth=[];
depth=[];
fallspd=[];
temp=[];
sig=[];
nu=[];
buoy_freq=[];
lt=[];
eps=[];
ua=[];
va=[];
wa=[];
velaz=[];

% load patches data set
load patlst_gp98a.dat
a=patlst_gp98a;
dat.prof=a(:,1);
dat.start_depth=a(:,2);
dat.end_depth=a(:,3);

% open data files
%for iprof=[5 7 9 11 12 14:2:26 27 29:43 46:75];
for ipx=1:length(dat.prof);
prf=num2str(dat.prof(ipx));
iprof=dat.prof(ipx);
q.script.num=dat.prof(ipx);
q.script.prefix='gp98a';
q.script.pathname='r:\Data\Gp98a\';
clear cal data

raw_load

cal_gp98a

%do other stuff
 
cal_3p
%plot_u

%do other stuff
idx=find(cal.P > dat.start_depth(ipx) & cal.P < dat.end_depth(ipx));
dz(ipx)=dat.end_depth(ipx)-dat.start_depth(ipx); %use for average_data bin size

cal.U=(real(ucf)).^2;
head.irep.U=head.irep.P;
head.sensor_index.U=head.sensor_index.ZYNC;

cal.V=(vf).^2;
head.irep.V=head.irep.P;
head.sensor_index.V=head.sensor_index.TRIANG;

cal.W=(wf).^2;
head.irep.W=head.irep.P;
head.sensor_index.W=head.sensor_index.SQUARE;

cal.VAZ=(vaz).^2;
head.irep.VAZ=head.irep.P;
head.sensor_index.VAZ=head.sensor_index.AZ;

% density
rho=cal.SIG(1:1:length(cal.SIG)-1);
g=9.81;
rhoav=998;
cal.BV2=(g/rhoav).*diff(cal.SIG)./diff(cal.P);
cal.BV2(length(cal.BV2)+1)=cal.BV2(length(cal.BV2));
head.irep.BV2=head.irep.P;
q.az=mean(cal.AZ);
cal.VARAZ=(cal.AZ-q.az).^2; %variance of AZ
head.irep.VARAZ=head.irep.AZ;

avg=average_data({'P','FALLSPD','T','SIG','BV2',...
      'epsilon1','varaz','u','v','w','vaz'},...
   'min_bin',dat.start_depth(ipx),'max_bin',dat.end_depth(ipx),'binsize',...
   dz(ipx)-.001,'nfft',256)

% flag AZ vibrations
%idaz=find(avg.VARAZ>3.e-05);
%avg.EPSILON1(idaz)=NaN;

% save averaged data
profile_num=[profile_num dat.prof(ipx)];
start_depth=[start_depth dat.start_depth(ipx)];
end_depth=[end_depth dat.end_depth(ipx)];
depth=[depth avg.P];
fallspd=[fallspd avg.FALLSPD];
sig=[sig avg.SIG];
temp=[temp avg.T];
nu=[nu sw_visc(0,avg.T,avg.P)];
buoy_freq=[buoy_freq sqrt(avg.BV2)]; %buoyancy frequency
eps=[eps avg.EPSILON1];
ua=[ua avg.U];
va=[va avg.V];
wa=[wa avg.W];
velaz=[velaz avg.VAZ];

end

save patches_gp98a profile_num start_depth end_depth depth fallspd ...
   nu temp sig buoy_freq eps ua va wa velaz