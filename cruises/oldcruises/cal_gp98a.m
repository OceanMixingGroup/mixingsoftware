% Script to calibrate sensors:

% First one might want to modify the header coefficients

head.coef.S1(1)=0.000042;
head.coef.AX(1)=-2.024;

if iprof>32
   head.coef.T=[9.4978 2.3737 0 0 1];
end

% calibrate is called as 
% calibrate('series','method',{'filter1','filter2',...})
% where series is the series to calibrate ( 'T1', 'TP2', 'S1', 'UC', etc.)
% and method is the method to use ('T','TP','S','UC', etc.)
% filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.

calibrate('p','p','l.5')

% first let us select the range over which the data is the real drop:
% start at 9m

% run some script or function which selects the appropriate depth range and
% places the indices into q.mini and q.maxi

% find surface...
[q.maxi,tog]=find_top;
% arbitrarily start the profile somewhere
q.mini=201;

% now select only the data within that depth range
len=select_depth_range(q.mini,q.maxi);
[data.P,mini,maxi]=extrapolate_depth_range(data.P);
% extrapolate_depth_range flips the ends of p over itself before calibrating so
% that starting and ending transients are elliminated.
calibrate('p','p','l1') 
calibrate('p','fallspd','l.5') 
data.P=data.P(mini:maxi);

cal.P=cal.P(mini:maxi);
cal.FALLSPD=cal.FALLSPD(mini:maxi);
cal.P=cal.P-cal.P(length(cal.P));%reference detected surface value to 0 m depth
q.fspd=mean(cal.FALLSPD);

calibrate('az','az')
calibrate('ay','tilt')
calibrate('ax','tilt')
calibrate('t','t');
cal.S=zeros(size(cal.P));
head.irep.S=head.irep.P;
calc_sigma('sig','S','T','P');

calibrate('s1','s','l30')
calibrate('tp','tp','l20')
calibrate('triang','volts')
calibrate('square','volts')
calibrate('zync','volts')