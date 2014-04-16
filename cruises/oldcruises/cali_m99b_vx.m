% Script to calibrate sensors:

% First one might want to modify the header coefficients

head.coef.S1(1)=1e-4*head.coef.S1(1);
head.coef.S2(1)=1e-4*head.coef.S2(1);
head.coef.S3(1)=1e-4*head.coef.S3(1);

% set VX coefficients to those determined by fit of velocity
% sensor to ADP speeds (tow15)
   head.coef.VX(1:2)=[13.2 43.3]; 
   
% also for MARLIN, generate ptime series - this has time in units 
% of decimal drop number 
% I'm hoping this will help in the initial analysis stages
% real time needs to be kept as well for finishing 
len=length(data.P1);
file_len_secs=len/slow_samp_rate;
standard_len=320;
time_secs=1/slow_samp_rate:1/slow_samp_rate:file_len_secs;
cal.PTIME=(ip+time_secs./standard_len)';
head.irep.PTIME=head.irep.P1;
% for MARLIN processing we need to use ADP data for FALLSPD
% for m99b, we get data every 20 seconds 
[sontek]=get_speedf(ip);
% interpolate to slow_samp_rate
R=fix(20*slow_samp_rate);
spd=(interp(sontek.speed,R))';
lenspd=length(spd);
cal.FALLSPD=100.*spd(lenspd/4+1:1:end-lenspd/4); % get middle points only
head.irep.FALLSPD=head.irep.P1;
q.fspd=mean(cal.FALLSPD);

% calibrate is called as 
% calibrate('series','method',{'filter1','filter2',...})
% where series is the series to calibrate ( 'T1', 'TP2', 'S1', 'UC', etc.)
% and method is the method to use ('T','TP','S','UC', etc.)
% filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.

calibrate('p2','p','l0.5')
calibrate('p1','p','l0.5') 
calibrate('vx','volts')
cal.VX_VOLTS=cal.VX;
head.irep.VX_VOLTS=head.irep.VX;
calibrate('vx','poly')

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
