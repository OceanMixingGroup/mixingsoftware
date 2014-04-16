% script to read raw marlin files and string together many files
iprof=[1202:1286];
time_avg=1; % averaging time interval

global cal data head irep q

for ip=iprof;

q.script.num=ip;
q.script.prefix='m99b';
q.script.pathname='d:\data\m99b\marlin\data\';
disp(['profile ',num2str(ip)])

raw_load

cali_m99b_volts

warning off
avg=average_data({'T1','T2','T3','PTIME',...
      'T4','T5','TF4','TF2','TF3','C1','C2','P2'},...
   'depth_or_time','time','min_bin',0,'binsize',time_avg,'nfft',256);
warning on
% find length of data set
len=length(avg.P2);
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

fout=['d:\data\m99b\marlin\tow04\temp\m99b_temp_volts',num2str(ip)];

eval(['save ' fout ' avg'])

end

