% this should be the same as cali_hm00_jmk, except that it uses mg_
% routines.

% Assumes that there exists variables q, data, head.
% check for vel_eq and the sum_tcp stuff...

% need the velocity from the ADV


% Script to calibrate sensors:
[st,i]=dbstack;
str=date;
%[tmp,machine_name] = dos('hostname');
machine_name='';
str=strcat(machine_name,' ',str);
for i=1:length(st)
  str=strcat(str,st(i).name);
  str = strcat(str,' and  ');
end;
cal.madewith=str;

% First one might want to modify the header coefficients

head.coef.S1(1)=1e-4*head.coef.S1(1);
head.coef.S2(1)=1e-4*head.coef.S2(1);
head.coef.S3(1)=1e-4*head.coef.S3(1);

cast = q.script.num;
% set VX coefficients to those determined by fit of velocity
% sensor to ADP speeds (m99b)
%for ip=[988:1286 4371:4456]
%   head.coef.VX(1:2)=[13.2 43.3]; 
%end

if cast>165 & cast<181
  head.coef.ADVX=[-5 2 0 0 0];
  head.coef.ADVY=[-5 2 0 0 0];
  head.coef.ADVZ=[-5 2 0 0 0];
end

% also for MARLIN, generate ptime series - this has time in units 
% of decimal drop number 
% I'm hoping this will help in the initial analysis stages
% real time needs to be kept as well for finishing 
len=length(data.P1);
file_len_secs=len/head.slow_samp_rate;
standard_len=320; %standard length of file in seconds
time_secs=1/head.slow_samp_rate:1/head.slow_samp_rate:file_len_secs;
cal.PTIME=(cast+time_secs./standard_len)';
head.irep.PTIME=head.irep.P1;

% computer time
start=str2num(head.starttime(15:17))+datenum(2002,1,0,...
    str2num(head.starttime(6:7)),str2num(head.starttime(9:10)),...
    str2num(head.starttime(12:13)));
len_file=length(data.SYNC)/round(head.slow_samp_rate*10)*10;
cal.CTIME=[start:len_file/length(data.SYNC)/3600/24:start+len_file/length(data.SYNC)/3600/24*(length(data.SYNC)-1)]';
head.irep.CTIME=head.irep.P1;
% GPS time
start=str2num(head.starttime(15:17))+datenum(2002,1,0,...
    str2num(head.saildata(1:2)),str2num(head.saildata(3:4)),...
    str2num(head.saildata(5:10)));
cal.STIME=[start:len_file/length(data.SYNC)/3600/24:start+len_file/length(data.SYNC)/3600/24*(length(data.SYNC)-1)]';
head.irep.STIME=head.irep.P1;

% calibrate is called as 
% cal=calibrate('series','method',{'filter1','filter2',...},data,head,cal)
% where series is the series to calibrate ( 'T1', 'TP2', 'S1', 'UC', etc.)
% and method is the method to use ('T','TP','S','UC', etc.)
% filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.


cal=mg_calibrate('p2','p','',data,head,cal);
cal=mg_calibrate('p1','p','',data,head,cal); 


cal=mg_calibrate('ax1','tilt',data,head,cal);
cal=mg_calibrate('ax2','tilt',data,head,cal);
cal=mg_calibrate('az','tilt',data,head,cal);
cal=mg_calibrate('ax1','ax',data,head,cal);
cal=mg_calibrate('ax2','ax',data,head,cal);
cal=mg_calibrate('ay','ay',data,head,cal);
cal=mg_calibrate('az','az',data,head,cal);

[cal,head]=mg_make_time_series(data,head,cal);


% T,C,P from Marlin...
cal=mg_calibrate('c1','c','l5',data,head,cal);
cal=mg_calibrate('c2','c','l5',data,head,cal);
cal=mg_calibrate('t1','t',data,head,cal);
cal=mg_calibrate('t2','t',data,head,cal);
head.coef.T3(1:2) = [3.9 -0.37]
cal=mg_calibrate('t3','t',data,head,cal);

cal=mg_calibrate('w1','volts','',data,head,cal);
cal=mg_calibrate('scat1','volts',data,head,cal);
cal=mg_calibrate('scat2','volts',data,head,cal);

head.coef.T1P(2)=0.12;

% To get the velocity I need to consult another file....
sprintf('%s/ADV/%s%04d.adv',q.script.pathname, ...
		       q.script.prefix,q.script.num)
adv = read_adv(sprintf('%sADV/%s%04d.adv',q.script.pathname, ...
		       q.script.prefix,q.script.num));
adv
if ~isempty(adv);
  % interpolate
  cal.ADVX = interp1(adv.time,adv.vel(1,:),cal.CTIME);
  cal.ADVY = interp1(adv.time,adv.vel(2,:),cal.CTIME);
  cal.ADVZ = interp1(adv.time,adv.vel(3,:),cal.CTIME);
  cal.FALLSPD = cal.ADVX/1000;
else
  cal.FALLSPD=1+0*cal.CTIME;
end;

cal=mg_calibrate('s1','s',{},data,head,cal);

cal=mg_calibrate('s1','s',{'h0.03'},data,head,cal);
cal=mg_calibrate('s2','s',{'h0.03'},data,head,cal);
cal=mg_calibrate('s3','s',{'h0.03'},data,head,cal);

cal=mg_calibrate('t1p','volts',{},data,head,cal);
T1P=cal.T1P;
cal.T1P=calibrate_tp(T1P,head.coef.T1P,data.T1,head.coef.T1,cal.FALLSPD);
% 
head.coef.T2P(2)=0.12;
cal=mg_calibrate('t2p','volts',{},data,head,cal);
T2P=cal.T2P;
cal.T2P=calibrate_tp(T2P,head.coef.T2P,data.T2,head.coef.T2,cal.FALLSPD);
% 
head.coef.T3P(2)=0.12;
cal=mg_calibrate('t3p','volts',{},data,head,cal);
T3P=cal.T3P;
cal.T3P=calibrate_tp(T3P,head.coef.T3P,data.T3,head.coef.T3,cal.FALLSPD);

