% script to read raw marlin files and string together many files

for i=[2]
      
   if i==1
      iprof=[452:670]; %tow 2
   elseif i==2
      iprof=[677:985]; %tow 3
   elseif i==3
      iprof=[1270:1682]; %tow 5
   elseif i==4
      iprof=[1694:2086]; %tow 6
   elseif i==5
      iprof=[2087:2463]; %tow 7
   elseif i==6
      iprof=[2466:2696]; %tow 8
   elseif i==7
      iprof=[2724:2859]; %tow 9
   elseif i==8
      iprof=[2862:3075]; %tow 10
   elseif i==9
      iprof=[3076:3365]; %tow 11
   elseif i==10
      iprof=[3366:3714]; %tow 12
   elseif i==11
      iprof=[3718:4066]; %tow 13
   elseif i==12
      iprof=[4082:4370]; %tow 14
   end
     
[lx ly]=size(iprof);
time_avg=5; % averaging time interval
ll=ly*320/time_avg; % factor to presize the arrays
time=nan*ones(1,ll);
ptime=nan*ones(1,ll);
p1=nan*ones(1,ll);
p2=nan*ones(1,ll);
vx=nan*ones(1,ll);
vx_volts=nan*ones(1,ll);
fallspd==nan*ones(1,ll);
icnt=0;

for ip=iprof;
q.script.num=ip;
q.script.prefix='m99b';
q.script.pathname='d:\data\m99b\marlin\data\';
clear cal data avg

disp(['profile ',num2str(ip)])

snum=num2str(10000+q.script.num);
fn=[q.script.pathname q.script.prefix snum(2) '.' snum(3:5)];

if exist(fn)

   
   raw_load

   cali_m99b_vx

% average
avg=average_data({'P1','P2','VX','VX_VOLTS','TIME','FALLSPD','PTIME'},...
   'depth_or_time','time','min_bin',time_avg,'binsize',5);

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
time(icnt-len+1:icnt)=avg.TIME;
ptime(icnt-len+1:icnt)=avg.PTIME;
fallspd(icnt-len+1:icnt)=avg.FALLSPD;
p1(icnt-len+1:icnt)=avg.P1;
p2(icnt-len+1:icnt)=avg.P2;
vx(icnt-len+1:icnt)=avg.VX;
vx_volts(icnt-len+1:icnt)=avg.VX_VOLTS;

end
end

fout=['d:\data\m99b\adp\mat_files\marlin_vx_',num2str(iprof(1)),'_',num2str(iprof(end))];

eval(['save ' fout ' time ptime p1 p2 fallspd vx vx_volts'])

end
