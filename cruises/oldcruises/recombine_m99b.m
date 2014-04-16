% script to read marlin mat files and string together as 1 file
iprof=[2690:2695];
[lx ly]=size(iprof);
time_avg=1; % define averaging time in s used in cal
ll=ly*320/time_avg; % factor to presize the arrays
time=nan*ones(1,ll);
ptime=nan*ones(1,ll);
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

fout=['d:\analysis\m99b\marlin\tow08\summary_files\m99b_',num2str(iprof(1)),'_',num2str(iprof(end))];

for ip=iprof
   fname=['d:\analysis\m99b\marlin\tow08\mat_files\m99b_',num2str(ip),'.mat'];
   if exist(fname) ~= 0
   eval(['load ' fname])
   disp(fname)
   
   
% find length of data set
len=length(avg.P1);
icnt=icnt+len;

% make arrays
fallspd(icnt-len+1:icnt)=avg.FALLSPD;
time(icnt-len+1:icnt)=avg.TIME;
ptime(icnt-len+1:icnt)=avg.PTIME;
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

end

eval(['save ' fout ' time ptime press1 press2 t1 t2 t3 t4 t5 tf2 tf3 tf4 t1p c1 c2 ' ... 
      'axt ayt az fallspd varaxhi varaxlo varayhi varaylo varazhi varazlo chi1 ' ...
      'chi2 chi3 eps1 eps2 eps3 w1 scat'])
