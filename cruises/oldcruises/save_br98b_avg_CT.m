time=[];
sbC=[];
sbT=[];
mT1=[];
mT2=[];
mT3=[];
mT4=[];
mT5=[];
mC1=[];
mP2=[];
mVx=[];

for iprof=[161:202];
% process Marlin data file   
q.script.num=iprof;
q.script.prefix='B98b';
q.script.pathname='r:\Brns98b\Marlin_1\';
clear cal data avg

raw_load

cali_br98b

avg=average_data({'VX','T1','T2','T3','T4','T5','P2','C1'},...
   'depth_or_time','time','min_bin',0,'binsize',1,'nfft',256);

% get time base
make_time_series;
yr=1998;
month=12;
day=str2num(head.starttime(15:17))-334;% date in December 1998
hr=str2num(head.starttime(6:7));
minutes=str2num(head.starttime(9:10));
sec=str2num(head.starttime(12:13));
start_time=datenum(yr,month,day,hr,minutes,sec);
cal.TIME=datenum(yr,month,day,hr,minutes,sec+cal.TIME);
avg.TIME=datenum(yr,month,day,hr,minutes,sec+avg.TIME);

% load and process Seabird data file
sbf=num2str(10000+iprof);
sb_fname=['r:\brns98b\marlin_1\b98b',sbf(2:5),'.sbd'];
rd_sbrd_file;

time=[time avg.TIME(1:310)];
sbC=[sbC sb.C(1:310)];
sbT=[sbT sb.T(1:310)];
mT1=[mT1 avg.T1(1:310)];
mT2=[mT2 avg.T2(1:310)];
mT3=[mT3 avg.T3(1:310)];
mT4=[mT4 avg.T4(1:310)];
mT5=[mT5 avg.T5(1:310)];
mC1=[mC1 avg.C1(1:310)];
mP2=[mP2 avg.P2(1:310)];
mVx=[mVx avg.VX(1:310)];

end

save marl_CT time sbC sbT mT1 mT2 mT3 mT4 mT5 mC1 mP2 mVx
