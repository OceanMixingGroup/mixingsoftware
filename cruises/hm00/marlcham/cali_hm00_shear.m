% Script to calibrate sensors:

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

% if cast>165 & cast<181
%    head.coef.ADVX=[-5 2 0 0 0];
%    head.coef.ADVY=[-5 2 0 0 0];
%    head.coef.ADVZ=[-5 2 0 0 0];
% end
% %###################################
% %location of the start end end of the file
% lat.start=str2num(head.saildata(12:13))+str2num(head.saildata(14:20))/60;
% lon.start=-(str2num(head.saildata(24:26))+str2num(head.saildata(27:33))/60);
% lat.end=str2num(head.saildata(48:49))+str2num(head.saildata(50:56))/60;
% lon.end=-(str2num(head.saildata(60:62))+str2num(head.saildata(63:69))/60);
% 
% %distance betweenstart end end locations
% dist=sw_dist([lat.start lat.end],[lon.start lon.end],'km')*1000;
% cal.DIST=(0:dist/(length(data.P2)-1):dist)';
% %###################################

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

% calibrate('p2','p','l0.4')
% calibrate('p1','p','l0.4') 
% calibrate('advx','poly','l0.4')
%advx lowpassed in order to calculate
%mean velocity, we do not need any fluctuations
%to use it in full spectra i should lowhpass it 
%on 10 Hz (the sensor does not resolve more)
%calibrate('advx','poly','l10')
%??calibrate('p2','p','l0.5')
%??calibrate('p1','p','l0.5') 


% calibrate('ax1','tilt')
% calibrate('ax2','tilt')
% calibrate('az','tilt')
% calibrate('ax2','ax','h1')
% cal.AXHI=cal.AX2;
% calibrate('ax2','ax','l1')
% cal.AXLO=cal.AX2;
% calibrate('ay','ay','h1')
% cal.AYHI=cal.AY;
% calibrate('ay','ay','l1')
% cal.AYLO=cal.AY;
% calibrate('az','az','h1')
% cal.AZHI=cal.AZ;
% calibrate('az','az','l1')
% cal.AZLO=cal.AZ;
calibrate('ax2','ax')
calibrate('ay','ay')
calibrate('az','az')

% first let us select the range over which the data is the real drop:
% start at 9m

% run some script or function which selects the appropriate depth range and
% places the indices into q.mini and q.maxi

% determine_depth_range is one possibility...
%[q.mini,q.maxi]=determine_depth_range(1);

% now select only the data within that depth range
%len=select_depth_range(q.mini,q.maxi);
%[data.P,mini,maxi]=extrapolate_depth_range(data.P);
% extrapolate_depth_range flips the ends of p over itself before calibrating so
% that starting and ending transients are elliminated.
make_time_series

calibrate('s1','s',{'h0.3'})
calibrate('s2','s',{'h0.3'})
calibrate('s3','s',{'h0.3'})

return;

ind=find(hm00.ptime>=cast & hm00.ptime<cast+1);
P=hm00.P(ind);
in=find(isnan(P));
P(in)=nanmean(P);
if length(P)==0
    cal.P(1:length(cal.PTIME))=NaN;
else
    cal.P=interp1(hm00.ptime(ind),P,cal.PTIME,'linear','extrap');
end
head.irep.P=head.irep.PTIME;
T=hm00.T(ind);
in=find(isnan(T));
T(in)=nanmean(T);
if length(T)==0
    cal.T(1:length(cal.PTIME))=NaN;
else
    cal.T=interp1(hm00.ptime(ind),T,cal.PTIME,'linear','extrap');
end
head.irep.T=head.irep.PTIME;
C=hm00.C(ind);
in=find(isnan(P));
C(in)=nanmean(C);
if length(P)==0
    cal.C(1:length(cal.PTIME))=NaN;
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
%data.S1=remove_sonar_spikes(data.S1);
%calibrate('s1','s');%,{'h1','l8'})
%data.S2=remove_sonar_spikes(data.S2);
%calibrate('s2','s');%,{'h1','l8'})
%calibrate('s2','s','n4-7')
%data.S3=remove_sonar_spikes(data.S3);
%calibrate('s3','s');%,{'h1','l8'})
%calibrate('s3','s','n4-7')

% Determine the cutoff frequency for w:
% this should be a cutoff frequency at 3m.
%freq=num2str(q.fspd/100/3) ;
%calibrate('w','w',{['h' freq]})
% calibrate('w1','volts',{'h0.4','l6'})
% calibrate('scat1','volts')
% calibrate('scat2','volts')
% 
% calibrate('c1','c','l5');
% calibrate('c2','c','l5');
% cal.C1=cal.C1*10; %from S/m to Mmho/cm
% cal.C2=cal.C2*10; %from S/m to Mmho/cm
% calibrate('t1','t')
% calibrate('t2','t',{'n4-6','l15'})
% calibrate('t3','t')
% calibrate('t4','t')
% calibrate('t5','t')
% calc_salt('s','c1','t1','p1')
% head.coef.T1P(2)=0.12;
% calibrate('t1p','volts',{'h1','l15'})
% data.T1P=cal.T1P;
% cal.T1P=calibrate_tp(data.T1P,head.coef.T1P,data.T1,head.coef.T1,cal.FALLSPD);
% cal.T1P2=cal.T1P.^2; % square to compute variance
% head.irep.T1P2=head.irep.T1P;
% 
% head.coef.T2P(2)=0.12;
% calibrate('t2p','volts',{'h1','l15'})
% data.T2P=cal.T2P;
% cal.T2P=calibrate_tp(data.T2P,head.coef.T2P,data.T2,head.coef.T2,cal.FALLSPD);
% 
% head.coef.T3P(2)=0.12;
% calibrate('t3p','volts',{'h1','l15'})
% data.T3P=cal.T3P;
% cal.T3P=calibrate_tp(data.T3P,head.coef.T3P,data.T3,head.coef.T3,cal.FALLSPD);
