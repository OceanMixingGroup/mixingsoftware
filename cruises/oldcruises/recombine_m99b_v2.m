% script to read marlin mat files and string together as 1 file
%itow=[3:8 10:15];
itow=[7];
for it=itow
str_it=num2str(it+100);   
  if it == 3
   iprof=[678:737 745:828 832:856 860 864:954 958:979]; %tow03
elseif it == 4
   iprof=[989:1040 1044:1059 1064:1119 1123:1154 1159:1199 1203:1266]; % tow04
elseif it == 5
   iprof=[1276:1278 1287:1289 1292:1293 1297:1355 1359:1478 1482:1546 ...
         1550:1595 1599:1638 1641:1680]; % tow05
elseif it == 6
   iprof=[1703:1716 1721:1777 1781:1815 1819:1833 1837:2086]; %tow06
elseif it == 7
   iprof=[2090:2453]; % tow07
elseif it == 8
   iprof=[2467:2492 2497:2603 2607:2699]; %tow08
elseif it == 10
   iprof=[2864:3033 3037:3076]; %tow10
elseif it == 11
   iprof=[3077:3338 3342:3344 3348:3365]; %tow11
elseif it == 12
   iprof=[3367:3390 3394:3440 3444:3501 3505:3710]; %tow12
elseif it == 13
   iprof=[3719:3750 3754:3782 3786:3854 3859:3982 3986:4060]; %tow13
elseif it == 14   
   iprof=[4083:4176 4180:4237 4242:4251 4255:4282 4287:4291 .... 
         4295:4304 4308:4370]; % tow14
elseif it == 15   
   iprof=[4372:4453]; % tow 15
end
 
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
c1=nan*ones(1,ll);
c2=nan*ones(1,ll);
az=nan*ones(1,ll);
axt=nan*ones(1,ll);
ayt=nan*ones(1,ll);
chi1=nan*ones(1,ll);
chi2=nan*ones(1,ll);
chi3=nan*ones(1,ll);
eps1=nan*ones(1,ll);
eps2=nan*ones(1,ll);
eps3=nan*ones(1,ll);

icnt=0;

fout=['d:\analysis\m99b\marlin\tow',str_it(2:3),'\summary_files\m99b_recombine_v2_tow',str_it(2:3)];

for ip=iprof
   fname=['d:\analysis\m99b\marlin\tow',str_it(2:3),'\mat_files\m99b_v2_',num2str(ip),'.mat'];
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
c1(icnt-len+1:icnt)=avg.C1;
c2(icnt-len+1:icnt)=avg.C2;
az(icnt-len+1:icnt)=avg.AZ;
axt(icnt-len+1:icnt)=avg.AX2_TILT;
ayt(icnt-len+1:icnt)=avg.AY_TILT;
chi1(icnt-len+1:icnt)=avg.CHI1;
chi2(icnt-len+1:icnt)=avg.CHI2;
chi3(icnt-len+1:icnt)=avg.CHI3;
eps1(icnt-len+1:icnt)=avg.EPSILON1;
eps2(icnt-len+1:icnt)=avg.EPSILON2;
eps3(icnt-len+1:icnt)=avg.EPSILON3;

end

end

eval(['save ' fout ' time ptime press1 press2 t1 t2 t3 t4 t5 c1 c2 ' ... 
      'axt ayt az fallspd chi1 ' ...
      'chi2 chi3 eps1 eps2 eps3'])
end