% script to read raw marlin files, calibrate and write o/p file

% specify Marlin tow number(s)
itow=[13:15];

for it=itow;

str_it=num2str(it+100);

% these files specified for eps, chi computation - they should all
% have coincident adp files to compute speed from - for other calculations
% where speed not needed, can just go through in order, 
% checking for existence 1st
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
   iprof ==[2090:2460]; % tow07
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

time_avg=1; % averaging time interval

global cal data head irep q

for ip=iprof;
str_ip=num2str(ip+10000);
q.script.num=ip;
q.script.prefix='m99b';
q.script.pathname='d:\raw_data\m99b\marlin\';
disp(['profile ',num2str(ip)])

fin=[q.script.pathname q.script.prefix str_ip(2),'.',str_ip(3:5)];
if exist(fin)

raw_load

cali_m99b_ptime

warning off
avg=average_data({'FALLSPD','T1','T2','T3',...
      'T4','T5','TF4','TF2','TF3','C1','C2','T1P','P1','P2',...
      'AX2_TILT','AY_TILT','AZ','SCAT','PTIME',...
      'EPSILON1','EPSILON2','EPSILON3','W1','CHI1','CHI2','CHI3','SCAT'},...
   'depth_or_time','time','min_bin',0,'binsize',time_avg,'nfft',256);
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

fout=['d:\analysis\m99b\marlin\tow',str_it(2:3),'\mat_files\m99b_v2_',num2str(q.script.num)];

eval(['save ' fout ' avg'])

end
end
end