% script to read raw marlin files and string together many files
iprof=[2100:2450];
time_avg=1; % averaging time interval

global cal data head irep q

for ip=iprof;

q.script.num=ip;
q.script.prefix='m99b';
q.script.pathname='d:\data\m99b\marlin\data\';
disp(['profile ',num2str(ip)])

raw_load

cali_m99b_ptime

% compute other stuff
cal.W1VAR=(cal.W1-mean(cal.W1)).^2; %variance of W1
head.irep.W1VAR=head.irep.W1;

warning off
avg=average_data({'PTIME','VARW1'},...
   'depth_or_time','time','min_bin',0,'binsize',time_avg);
warning on

% get time base
%make_time_series;
yr=1999;
month=8;
day=str2num(head.starttime(15:17))-212;% date in August 1999
hr=str2num(head.starttime(6:7));
mint=str2num(head.starttime(9:10));
sec=str2num(head.starttime(12:13));
start_time=datenum(yr,month,day,hr,mint,sec);
cal.TIME=datenum(yr,month,day,hr,mint,sec+cal.TIME);
avg.TIME=datenum(yr,month,day,hr,mint,sec+avg.TIME);

fout=['d:\data\m99b\marlin\tow07\mat_files\m99b_w_',num2str(ip)];

eval(['save ' fout ' avg'])

end
