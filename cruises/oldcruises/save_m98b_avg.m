fallspd=[];
press=[];
t=[];
axt=[];
ayt=[];
time=[];
varaxhi=[];
varayhi=[];
varazhi=[];
varaxlo=[];
varaylo=[];
varazlo=[];
eps1=[];
eps2=[];
w=[];

for iprof=[248:317];
q.script.num=iprof;
q.script.prefix='m98b';
q.script.pathname='r:\m98b\';
clear cal data

raw_load_marlin

cali_m98b

% compute other stuff
cal.VARAZHI=(cal.AZHI-mean(cal.AZHI)).^2; %variance of AZ
head.irep.VARAZHI=head.irep.AZ;
cal.VARAXHI=(cal.AXHI-mean(cal.AXHI)).^2; %variance of Ax
head.irep.VARAXHI=head.irep.AX;
cal.VARAYHI=(cal.AYHI-mean(cal.AYHI)).^2; %variance of Ay
head.irep.VARAYHI=head.irep.AY;
cal.VARAZLO=(cal.AZLO-mean(cal.AZLO)).^2; %variance of AZ
head.irep.VARAZLO=head.irep.AZ;
cal.VARAXLO=(cal.AXLO-mean(cal.AXLO)).^2; %variance of Ax
head.irep.VARAXLO=head.irep.AX;
cal.VARAYLO=(cal.AYLO-mean(cal.AYLO)).^2; %variance of Ay
head.irep.VARAYLO=head.irep.AY;

avg=average_data({'FALLSPD','T1','P2','AX_TILT','AY_TILT',...
      'VARAZHI','VARAXHI','VARAYHI',...
      'VARAZLO','VARAXLO','VARAYLO',...
      'EPSILON1','EPSILON2','W'},...
   'depth_or_time','time','min_bin',0,'binsize',10,'nfft',256)

% get time base
make_time_series;
yr=1998;
month=8;
day=str2num(head.starttime(15:17))-212;% date in August 1998
hr=str2num(head.starttime(6:7));
min=str2num(head.starttime(9:10));
sec=str2num(head.starttime(12:13));
start_time=datenum(yr,month,day,hr,min,sec)
cal.TIME=datenum(yr,month,day,hr,min,sec+cal.TIME);
avg.TIME=datenum(yr,month,day,hr,min,sec+avg.TIME);

% flag AZ vibrations
%idx=find(avg.VARAZ>3.e-05)
%avg.EPSILON1(idx)=NaN;
%avg.EPSILON2(idx)=NaN;
%avg.EPS=(avg.EPSILON1+avg.EPSILON2)./2

%it=1:1:length(data.P);
%cal.TIME=it/slow_samp_rate;

%orient landscape
%subplot(811),plot(cal.TIME,-cal.P2);grid;datetick
%ylabel('Depth [m]')
%title(num2str(iprof))
%xl=get(gca,'xlim');
%subplot(812),plot(cal.TIME,cal.AX_TILT(1:head.irep.AX:length(cal.AX_TILT)),cal.TIME,cal.AY_TILT(1:head.irep.AY:length(cal.AY_TILT)));grid;datetick
%ylabel('Tilt [degrees]')
%subplot(813),plot(cal.TIME,cal.AZ(1:head.irep.AZ:length(cal.AZ)));grid;datetick
%ylabel('Az [g]')
%subplot(814),plot(cal.TIME,cal.VX(1:head.irep.VX:length(cal.VX)));grid;datetick
%ylabel('Speed [cm s^{-1}]')
%subplot(815),plot(cal.TIME,cal.T1(1:head.irep.T1:length(cal.T1)));grid;datetick
%ylabel('T [C]')
%subplot(816),plot(cal.TIME,cal.TP(1:head.irep.TP:length(cal.TP)));grid;datetick
%ylabel('T^\prime')
%axis([xl(1) xl(2) -.5 0])
%subplot(817),plot(cal.TIME,cal.S1(1:head.irep.S1:length(cal.S1)));grid;datetick
%ylabel('S1 [s^{-1}]')
%axis([xl(1) xl(2) -.15 .15])
%subplot(818),plot(cal.TIME,cal.S2(1:head.irep.S2:length(cal.S2)));grid;datetick
%ylabel('S2 [s^{-1}]')
%axis([xl(1) xl(2) -.15 .15])
%xlabel('25 August 1998')

%pause(1)
%eval(['print ' num2str(iprof) ' -dpsc'])

% apend averaged data to previous files
fallspd=[fallspd avg.FALLSPD];
press=[press avg.P2];
t=[t avg.T1];
axt=[axt avg.AX_TILT];
ayt=[ayt avg.AY_TILT];
time=[time avg.TIME];
varaxhi=[varaxhi avg.VARAXHI];
varayhi=[varayhi avg.VARAYHI];
varazhi=[varazhi avg.VARAZHI];
varaxlo=[varaxlo avg.VARAXLO];
varaylo=[varaylo avg.VARAYLO];
varazlo=[varazlo avg.VARAZLO];
eps1=[eps1 avg.EPSILON1];
eps2=[eps2 avg.EPSILON2];
w=[w avg.W];

end

temp=t;
subplot(311),plot(time,-press);grid;datetick
subplot(312),plot(time,fallspd);grid;datetick
subplot(313),plot(time,temp);grid;datetick

save 248_317_10s_avg time press temp axt ayt fallspd varaxhi varaxlo varayhi varaylo varazhi varazlo eps1 eps2 w 
