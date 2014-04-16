fallspd=[];
press1=[];
press2=[];
t1=[];
t5=[];
c1=[];
c2=[];
az=[];
axt=[];
ayt=[];
time=[];
varaxhi=[];
varayhi=[];
varazhi=[];
varaxlo=[];
varaylo=[];
varazlo=[];
chi1=[];
eps1=[];
eps2=[];
eps3=[];
w1=[];
t1p=[];
scat=[];

for iprof=[161:309];
   display(iprof)
q.script.num=iprof;
q.script.prefix='m99a';
q.script.pathname='g:\marlin\';
clear cal data temp

raw_load

cali_m99a

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

avg=average_data2({'FALLSPD','T1','C1','C2','T1P','P1','P2',...
      'AX_TILT','AY_TILT','AZ','SCAT',...
      'VARAZHI','VARAXHI','VARAYHI',...
      'VARAZLO','VARAXLO','VARAYLO',...
      'CHI1','EPSILON1','EPSILON2','EPSILON3','W1'},...
   'depth_or_time','time','min_bin',0,'binsize',5,'nfft',256)

% get time base
% *** be sure to specify year & month ***
make_time_series;
yr=1999;
month=4;
day=str2num(head.starttime(15:17))-90;% date in April 1999
hr=str2num(head.starttime(6:7));
minutes=str2num(head.starttime(9:10));
sec=str2num(head.starttime(12:13));
start_time=datenum(yr,month,day,hr,minutes,sec)
cal.TIME=datenum(yr,month,day,hr,minutes,sec+cal.TIME);
avg.TIME=datenum(yr,month,day,hr,minutes,sec+avg.TIME);

% flag AZ vibrations
%idx=find(avg.VARAZ>3.e-05)
%avg.EPSILON1(idx)=NaN;
%avg.EPSILON2(idx)=NaN;
%avg.EPS=(avg.EPSILON1+avg.EPSILON2)./2

%it=1:1:length(data.P);
%cal.TIME=it/slow_samp_rate;

fallspd=[fallspd avg.FALLSPD];
press2=[press2 avg.P2];
press1=[press1 avg.P1];
t1=[t1 avg.T1];
t5=[t5 avg.T5];
c1=[c1 avg.c1];
c2=[c2 avg.c2];
axt=[axt avg.AX_TILT];
ayt=[ayt avg.AY_TILT];
az=[az avg.AZ];
time=[time avg.TIME];
varaxhi=[varaxhi avg.VARAXHI];
varayhi=[varayhi avg.VARAYHI];
varazhi=[varazhi avg.VARAZHI];
varaxlo=[varaxlo avg.VARAXLO];
varaylo=[varaylo avg.VARAYLO];
varazlo=[varazlo avg.VARAZLO];
chi1=[chi1 avg.CHI1];
eps1=[eps1 avg.EPSILON1];
eps2=[eps2 avg.EPSILON2];
eps3=[eps3 avg.EPSILON3];
w1=[w1 avg.W1];
t1p=[t1p avg.T1P];
scat=[scat avg.SCAT];

end

subplot(311),plot(time,-press1,time,-press2);grid;datetick
ylabel('Depth [m]')
subplot(312),plot(time,fallspd);grid;datetick
ylabel('Speed [cm s^{-1}]')
subplot(313),plot(time,t1);grid;datetick
ylabel('Temperature [C]')

save 161_309_5s_2_avg time press1 press2 t1 t5 t1p c1 c2 axt ayt az fallspd varaxhi varaxlo ...
	varayhi varaylo varazhi varazlo chi1 eps1 eps2 eps3 w1 scat
