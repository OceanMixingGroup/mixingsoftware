% Script to calibrate sensors:

% First one might want to modify the header coefficients

head.coef.S1(1)=1e-4*head.coef.S1(1);
head.coef.S2(1)=1e-4*head.coef.S2(1);
head.coef.S3(1)=1e-4*head.coef.S3(1);

%head.coef.VX(1:2)=[4.02 21.57];

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
calibrate('vx','t','l1')

calibrate('ax','tilt')
calibrate('ay','tilt')
calibrate('ax','ax','h1')
cal.AXHI=cal.AX;
calibrate('ax','ax','l1')
cal.AXLO=cal.AX;
calibrate('ay','ay','h1')
cal.AYHI=cal.AY;
calibrate('ay','ay','l1')
cal.AYLO=cal.AY;
calibrate('az','az','h1')
cal.AZHI=cal.AZ;
calibrate('az','az','l1')
cal.AZLO=cal.AZ;


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
q.fspd=mean(cal.VX);
cal.FALLSPD=cal.VX;
head.irep.FALLSPD=head.irep.VX;
calibrate('s1','s',{'l10','h1'})
calibrate('s2','s',{'l10','h1'})
calibrate('s3','s',{'l10','h1'})

% Determine the cutoff frequency for w:
% this should be a cutoff frequency at 3m.

%freq=num2str(q.fspd/100/3) ;
%calibrate('w','w',{['h' freq]})
calibrate('t1','t','l5')
head.coef.T1P(2)=0.1;
calibrate('t1p','volts','l15')
data.T1P=cal.T1P;
cal.T1P=calibrate_tp(data.T1P,head.coef.T1P,data.T1,head.coef.T1,cal.FALLSPD);

calibrate('w1','volts')
