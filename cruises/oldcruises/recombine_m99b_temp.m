% script to read marlin mat files and string together as 1 file
iprof=[2467:2699];
[lx ly]=size(iprof);
time_avg=1;
ll=ly*320/time_avg; % factor to presize the arrays
marlin.time=nan*ones(1,ll);
marlin.ptime=nan*ones(1,ll);
%fallspd=nan*ones(1,ll);
%vx=nan*ones(1,ll);
marlin.press2=nan*ones(1,ll);
marlin.t1=nan*ones(1,ll);
marlin.t2=nan*ones(1,ll);
marlin.t3=nan*ones(1,ll);
marlin.t4=nan*ones(1,ll);
marlin.t5=nan*ones(1,ll);
marlin.tf2=nan*ones(1,ll);
marlin.tf3=nan*ones(1,ll);
marlin.tf4=nan*ones(1,ll);
marlin.c1=nan*ones(1,ll);
marlin.c2=nan*ones(1,ll);

icnt=0;

fout=['d:\analysis\m99b\marlin\tow08\summary_files\m99b_tv_',num2str(iprof(1)),'_',num2str(iprof(end))];

for ip=iprof
   fname=['d:\analysis\m99b\marlin\tow08\temperature\m99b_temp_volts',num2str(ip),'.mat'];
   if exist(fname) ~= 0
   eval(['load ' fname])
   disp(fname)
   
% find length of data set
len=length(avg.P2);
icnt=icnt+len;

% make arrays
%fallspd(icnt-len+1:icnt)=avg.FALLSPD;
%vx(icnt-len+1:icnt)=avg.VX;
marlin.time(icnt-len+1:icnt)=avg.TIME;
marlin.ptime(icnt-len+1:icnt)=avg.PTIME;
marlin.press2(icnt-len+1:icnt)=avg.P2;
marlin.t1(icnt-len+1:icnt)=avg.T1;
marlin.t2(icnt-len+1:icnt)=avg.T2;
marlin.t3(icnt-len+1:icnt)=avg.T3;
marlin.t4(icnt-len+1:icnt)=avg.T4;
marlin.t5(icnt-len+1:icnt)=avg.T5;
marlin.tf2(icnt-len+1:icnt)=avg.TF2;
marlin.tf3(icnt-len+1:icnt)=avg.TF3;
marlin.tf4(icnt-len+1:icnt)=avg.TF4;
marlin.c1(icnt-len+1:icnt)=avg.C1;
marlin.c2(icnt-len+1:icnt)=avg.C2;

end

end

eval(['save ' fout ' marlin '])
