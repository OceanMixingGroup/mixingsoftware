%global cal head data q;
cal=[];
% Script to calibrate sensors:
[st,i]=dbstack;
str=date;
[tmp,machine_name] = dos('hostname');
str=strcat(machine_name,' ',str);
for i=1:length(st)
  str=strcat(str,st(i).name);
  str = strcat(str,' and  ');
end;
cal.madewith=str

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
start=str2num(head.starttime(15:17))+datenum(2000,1,0,...
    str2num(head.starttime(6:7)),str2num(head.starttime(9:10)),...
    str2num(head.starttime(12:13)));
len_file=length(data.SYNC)/round(head.slow_samp_rate*10)*10;
cal.CTIME=[start:len_file/length(data.SYNC)/3600/24:start+len_file/length(data.SYNC)/3600/24*(length(data.SYNC)-1)]';
head.irep.CTIME=head.irep.P1;
% GPS time
start=str2num(head.starttime(15:17))+datenum(2000,1,0,...
    str2num(head.saildata(1:2)),str2num(head.saildata(3:4)),...
    str2num(head.saildata(5:10)));
cal.STIME=[start:len_file/length(data.SYNC)/3600/24:start+len_file/length(data.SYNC)/3600/24*(length(data.SYNC)-1)]';
head.irep.STIME=head.irep.P1;

% calibrate is called as 
% calibrate('series','method',{'filter1','filter2',...})
% where series is the series to calibrate ( 'T1', 'TP2', 'S1', 'UC', etc.)
% and method is the method to use ('T','TP','S','UC', etc.)
% filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.

cal=calibrate('p2','p','l0.4',data,head,q,cal);
cal=calibrate('p1','p','l0.4',data,head,q,cal); 
cal=calibrate('advx','poly','l0.4',data,head,q,cal);

cal=calibrate('ax1','tilt','',data,head,q,cal);
cal=calibrate('ax2','tilt','',data,head,q,cal);
cal=calibrate('az','tilt','',data,head,q,cal);
cal=calibrate('ax2','ax','',data,head,q,cal);
cal=calibrate('ay','ay','',data,head,q,cal);
cal=calibrate('az','az','',data,head,q,cal);

cal=make_time_series(data,head,cal);

% get the fallspeed from vel_eq.mat

ind=find(vel_eq.ptime>=cast & vel_eq.ptime<cast+1);
if ~isempty(ind)
  q.fspd=mean(vel_eq.vel(ind));%[m/s]
  cal.FALLSPD=interp1(vel_eq.ptime(ind),vel_eq.vel(ind),cal.PTIME, ...
		      'linear','extrap')*100;% [cm/s]
  head.irep.FALLSPD=head.irep.P1;
  cal.FLAG=vel_eq.flag(ind(1));
else
  cal.FALLSPD=100*cal.ADVX; % [cm/s]
  cal.FLAG=0*cal.PTIME;
end;

cal=calibrate('s1','s',{'h0.3'},data,head,q,cal);
cal=calibrate('s2','s',{'h0.3'},data,head,q,cal);
cal=calibrate('s3','s',{'h0.3'},data,head,q,cal);

% T,C,P from Marlin...
cal=calibrate('c1','c','l5',data,head,q,cal);
cal=calibrate('c2','c','l5',data,head,q,cal);
cal=calibrate('t1','t','',data,head,q,cal);
cal=calibrate('t2','t',{'n4-6','l15'},data,head,q,cal);
cal=calibrate('t3','t','',data,head,q,cal);
cal=calibrate('t4','t','',data,head,q,cal);
cal=calibrate('t5','t','',data,head,q,cal);


% get TCP from Seabird sum_tcp file...
ind=find(hm00.ptime>=cast & hm00.ptime<cast+1);
P=hm00.P(ind);
in=find(isnan(P));
P(in)=nanmean(P);
if length(P)==0
    cal.P(1:length(cal.PTIME))=cal.P1;
else
    cal.P=interp1(hm00.ptime(ind),P,cal.PTIME,'linear','extrap');
end
head.irep.P=head.irep.PTIME;
T=hm00.T(ind);
in=find(isnan(T));
T(in)=nanmean(T);
if length(T)==0
  
    cal.T(1:length(cal.PTIME))=cal.T2;
else
    cal.T=interp1(hm00.ptime(ind),T,cal.PTIME,'linear','extrap');
end
head.irep.T=head.irep.PTIME;
C=hm00.C(ind);
in=find(isnan(P));
C(in)=nanmean(C);
if length(P)==0
    cal.C(1:length(cal.PTIME))=cal.C1;
else
    cal.C=interp1(hm00.ptime(ind),C,cal.PTIME,'linear','extrap');
end
head.irep.C=head.irep.PTIME;
S=hm00.S(ind);
in=find(isnan(S));
S(in)=nanmean(S);
if length(P)==0
    cal.S(1:length(cal.PTIME))=NaN;
else
    cal.S=interp1(hm00.ptime(ind),S,cal.PTIME,'linear','extrap');
end
head.irep.S=head.irep.PTIME;
% make column vectors;
cal.P=cal.P';
cal.S=cal.S';
cal.C=cal.C';
cal.T=cal.T';

% Determine the cutoff frequency for w:
% this should be a cutoff frequency at 3m.
%freq=num2str(q.fspd/100/3) ;
%calibrate('w','w',{['h' freq]})
cal=calibrate('w1','volts',{'h0.4','l6'},data,head,q,cal);
cal=calibrate('scat1','volts','',data,head,q,cal);
cal=calibrate('scat2','volts','',data,head,q,cal);

% calc_salt('s','c1','t1','p1')
head.coef.T1P(2)=0.12;
cal=calibrate('t1p','volts',{'h1','l15'},data,head,q,cal);
data.T1P=cal.T1P;
cal.T1P=calibrate_tp(data.T1P,head.coef.T1P,data.T1,head.coef.T1,cal.FALLSPD);
cal.T1P2=cal.T1P.^2; % square to compute variance
head.irep.T1P2=head.irep.T1P;
% 
head.coef.T2P(2)=0.12;
cal=calibrate('t2p','volts',{'h1','l15'},data,head,q,cal);
data.T2P=cal.T2P;
cal.T2P=calibrate_tp(data.T2P,head.coef.T2P,data.T2,head.coef.T2,cal.FALLSPD);
% 
head.coef.T3P(2)=0.12;
cal=calibrate('t3p','volts',{'h1','l15'},data,head,q,cal);
data.T3P=cal.T3P;
cal.T3P=calibrate_tp(data.T3P,head.coef.T3P,data.T3,head.coef.T3,cal.FALLSPD);
