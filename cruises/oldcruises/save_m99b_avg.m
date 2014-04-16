% script to read raw marlin files and string together many files
iprof=[988:1268];
[lx ly]=size(iprof);
time_avg=1; % averaging time interval
ll=ly*320/time_avg; % factor to presize the arrays
time=nan*ones(1,ll);
fallspd=nan*ones(1,ll);
press1=nan*ones(1,ll);
press2=nan*ones(1,ll);
t1=nan*ones(1,ll);
t2=nan*ones(1,ll);
t3=nan*ones(1,ll);
t4=nan*ones(1,ll);
t5=nan*ones(1,ll);
tf2=nan*ones(1,ll);
tf3=nan*ones(1,ll);
tf4=nan*ones(1,ll);
c1=nan*ones(1,ll);
c2=nan*ones(1,ll);
az=nan*ones(1,ll);
axt=nan*ones(1,ll);
ayt=nan*ones(1,ll);
varaxhi=nan*ones(1,ll);
varayhi=nan*ones(1,ll);
varazhi=nan*ones(1,ll);
varaxlo=nan*ones(1,ll);
varaylo=nan*ones(1,ll);
varazlo=nan*ones(1,ll);
chi1=nan*ones(1,ll);
chi2=nan*ones(1,ll);
chi3=nan*ones(1,ll);
eps1=nan*ones(1,ll);
eps2=nan*ones(1,ll);
eps3=nan*ones(1,ll);
w1=nan*ones(1,ll);
t1p=nan*ones(1,ll);
scat=nan*ones(1,ll);

icnt=0;

global cal data head irep q

for ip=iprof;

q.script.num=ip;
q.script.prefix='m99b';
q.script.pathname='d:\data\m99b\marlin\data\';
disp(['profile ',num2str(ip)])

raw_load

cali_m99b

% compute other stuff
cal.VARAZHI=(cal.AZHI-mean(cal.AZHI)).^2; %variance of AZ
head.irep.VARAZHI=head.irep.AZ;
cal.VARAXHI=(cal.AXHI-mean(cal.AXHI)).^2; %variance of Ax
head.irep.VARAXHI=head.irep.AX2;
cal.VARAYHI=(cal.AYHI-mean(cal.AYHI)).^2; %variance of Ay
head.irep.VARAYHI=head.irep.AY;
cal.VARAZLO=(cal.AZLO-mean(cal.AZLO)).^2; %variance of AZ
head.irep.VARAZLO=head.irep.AZ;
cal.VARAXLO=(cal.AXLO-mean(cal.AXLO)).^2; %variance of Ax
head.irep.VARAXLO=head.irep.AX2;
cal.VARAYLO=(cal.AYLO-mean(cal.AYLO)).^2; %variance of Ay
head.irep.VARAYLO=head.irep.AY;

warning off
avg=average_data({'FALLSPD','T1','T2','T3',...
      'T4','T5','TF4','TF2','TF3','C1','C2','T1P','P1','P2',...
      'AX2_TILT','AY_TILT','AZ','SCAT',...
      'VARAZHI','VARAXHI','VARAYHI',...
      'VARAZLO','VARAXLO','VARAYLO',...
      'EPSILON1','EPSILON2','EPSILON3','W1','CHI1','CHI2','CHI3','SCAT'},...
   'depth_or_time','time','min_bin',0,'binsize',time_avg,'nfft',256);
warning on
% find length of data set
len=length(avg.P1);
icnt=icnt+len;

% get time base
%make_time_series;
yr=1999;
month=8;
day=str2num(head.starttime(15:17))-212;% date in August 1998
hr=str2num(head.starttime(6:7));
mint=str2num(head.starttime(9:10));
sec=str2num(head.starttime(12:13));
start_time=datenum(yr,month,day,hr,mint,sec);
cal.TIME=datenum(yr,month,day,hr,mint,sec+cal.TIME);
avg.TIME=datenum(yr,month,day,hr,mint,sec+avg.TIME);

% make arrays
fallspd(icnt-len+1:icnt)=avg.FALLSPD;
time(icnt-len+1:icnt)=avg.TIME;
press1(icnt-len+1:icnt)=avg.P1;
press2(icnt-len+1:icnt)=avg.P2;
t1(icnt-len+1:icnt)=avg.T1;
t2(icnt-len+1:icnt)=avg.T2;
t3(icnt-len+1:icnt)=avg.T3;
t4(icnt-len+1:icnt)=avg.T4;
t5(icnt-len+1:icnt)=avg.T5;
tf2(icnt-len+1:icnt)=avg.TF2;
tf3(icnt-len+1:icnt)=avg.TF3;
tf4(icnt-len+1:icnt)=avg.TF4;
c1(icnt-len+1:icnt)=avg.C1;
c2(icnt-len+1:icnt)=avg.C2;
az(icnt-len+1:icnt)=avg.AZ;
axt(icnt-len+1:icnt)=avg.AX2_TILT;
ayt(icnt-len+1:icnt)=avg.AY_TILT;
varaxhi(icnt-len+1:icnt)=avg.VARAXHI;
varaxlo(icnt-len+1:icnt)=avg.VARAXLO;
varayhi(icnt-len+1:icnt)=avg.VARAYHI;
varaylo(icnt-len+1:icnt)=avg.VARAYLO;
varazhi(icnt-len+1:icnt)=avg.VARAZHI;
varazlo(icnt-len+1:icnt)=avg.VARAZLO;
chi1(icnt-len+1:icnt)=avg.CHI1;
chi2(icnt-len+1:icnt)=avg.CHI2;
chi3(icnt-len+1:icnt)=avg.CHI3;
eps1(icnt-len+1:icnt)=avg.EPSILON1;
eps2(icnt-len+1:icnt)=avg.EPSILON2;
eps3(icnt-len+1:icnt)=avg.EPSILON3;
w1(icnt-len+1:icnt)=avg.W1;
t1p(icnt-len+1:icnt)=avg.T1P;
scat(icnt-len+1:icnt)=avg.SCAT;

end

subplot(311),plot(time,-press1,time,-press2);grid;datetick
ylabel('Depth [m]')
subplot(312),plot(time,fallspd);grid;datetick
ylabel('Speed [cm s^{-1}]')
subplot(313),plot(time,t1);grid;datetick
ylabel('Temperature [C]')

fout=['d:\data\m99b\marlin\mat_files\marlin_',num2str(iprof(1)),'_',num2str(iprof(end))];

eval(['save ' fout ' time press1 press2 t1 t2 t3 t4 t5 tf2 tf3 tf4 t1p c1 c2 ' ... 
      'axt ayt az fallspd varaxhi varaxlo varayhi varaylo varazhi varazlo chi1 ' ...
      'chi2 chi3 eps1 eps2 eps3 w1 scat'])

