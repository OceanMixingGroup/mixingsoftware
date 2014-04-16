% Script to calibrate sensors:

% First one might want to modify the header coefficients

%head.coef.S1(1)=0.0000471;

% calibrate is called as 
% calibrate('series','method',{'filter1','filter2',...})
% where series is the series to calibrate ( 'T1', 'TP2', 'S1', 'UC', etc.)
% and method is the method to use ('T','TP','S','UC', etc.)
% filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.

calibrate('p','p','l2')
calibrate('az','az')
calibrate('ay','tilt')
calibrate('ax','tilt')

% first let us select the range over which the data is the real drop:
% start at 9m

% run some script or function which selects the appropriate depth range and
% places the indices into q.mini and q.maxi

% determine_depth_range is one possibility...
[q.mini,q.maxi]=determine_depth_range(15);

% now select only the data within that depth range
len=select_depth_range(q.mini,q.maxi);
[data.P,mini,maxi]=extrapolate_depth_range(data.P);
% extrapolate_depth_range flips the ends of p over itself before calibrating so
% that starting and ending transients are elliminated.
calibrate('p','p','l1') 
calibrate('p','fallspd','l1') 
data.P=data.P(mini:maxi);
cal.P=cal.P(mini:maxi);
cal.FALLSPD=cal.FALLSPD(mini:maxi);

q.fspd=mean(cal.FALLSPD);

calibrate('s1','s',{'l30','h.5'})
calibrate('s2','s',{'l30','h.5'})
% Determine the cutoff frequency for w:
% this should be a cutoff frequency at 3m.
freq=num2str(2*q.fspd/100/3) ;
%calibrate('w','w',{['h' freq]})
calibrate('w','volts','h0.01')
spd=q.fspd;
sp=1/head.coef.W(2);
rho=1.024;
cal1.W=cal.W./(2*rho*spd.*sp);
calibrate('w','volts',{['h' freq]})
cal2.W=cal.W./(2*rho*spd.*sp);
calibrate('t','t')
calibrate('c','c')

cond=cal.C(1:head.irep.C:length(cal.C));
temp=cal.T;
press=cal.P;
cal.SAL=sw_salt(cond/sw_c3515,temp,press);
head.irep.SAL=head.irep.P;
%cal.SIGTH=sw_pden(salinity,cal.T,cal.P,0)-1000head;
%head.irep.SIGTH=head.irep.P;

%calc_salt('sal','c','t','p');
calc_theta('theta','sal','t','p');
calc_sigma('sigth','sal','t','p');

inds=calc_order('sigth','P');

%[temp.w,mini,maxi]=extrapolate_depth_range(cal.W,250);
%temp.az=extrapolate_depth_range(cal.AZ,500);
%temp.fallspd=extrapolate_depth_range(cal.FALLSPD,250);
%cal.W1=calc_w(temp.w,temp.az,temp.fallspd);
%cal.W1=cal.W1(mini:maxi);