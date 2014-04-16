% Script to calibrate sensors:

% First one might want to modify the header coefficients

%head.coef.S1(1)=0.000045;
%head.coef.S2(1)=0.000040;

% calibrate is called as 
% calibrate('series','method',{'filter1','filter2',...})
% where series is the series to calibrate ( 'T1', 'TP2', 'S1', 'UC', etc.)
% and method is the method to use ('T','TP','S','UC', etc.)
% filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.

calibrate('p','p','l1')
%calibrate('p2','p','l1') 
calibrate('vx','t','l1')

calibrate('ax','tilt')
%data.AY=2*data.AY;
calibrate('ay','tilt')
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
q.fspd=mean(cal.VX);
cal.FALLSPD=100.*cal.VX;
head.irep.FALLSPD=head.irep.VX;
calibrate('s1','s',{'l10','h.5'})
calibrate('s2','s',{'l10','h.5'})
% Determine the cutoff frequency for w:
% this should be a cutoff frequency at 3m.

%freq=num2str(q.fspd/100/3) ;
%calibrate('w','w',{['h' freq]})
calibrate('t','t')
head.coef.TP(2)=0.1;
calibrate('tp','volts','l5')
data.TP=cal.TP;
cal.TP=calibrate_tp(data.TP,head.coef.TP,data.T,head.coef.T,cal.FALLSPD);

