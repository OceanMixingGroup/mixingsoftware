% Script to calibrate sensors:

% First one might want to modify the header coefficients

head.coef.S1(1)=0.0000471;

warning('THIS SCRIPT CAME FROM /home/nalu/shared/matview/cal')
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

% run some script or function which selects the appropriate depth range and
% places the indices into q.mini and q.maxi

% determine_depth_range is one possibility (we want from 9m to the bottom.
% Note that this script needs az and p
[q.mini,q.maxi]=determine_depth_range(9);

% now select only the data within that depth range
len=select_depth_range(q.mini,q.maxi);
[data.P,mini,maxi]=extrapolate_depth_range(data.P);
% extrapolate_depth_range flips the ends of p over itself before calibrating so
% that starting and ending transients are elliminated.  This is generally
% not needed
calibrate('p','p','l1') 
calibrate('p','fallspd','l1') 
data.P=data.P(mini:maxi);
cal.P=cal.P(mini:maxi);
cal.FALLSPD=cal.FALLSPD(mini:maxi);

q.fspd=mean(cal.FALLSPD);

calibrate('s1','s',{'h1'})
% some series requiring more than variable for 
% calibration are called explicitly:

% Determine the cutoff frequency for w:
% this should be a cutoff frequency at 3m.
freq=num2str(q.fspd/100/3);
calibrate('t1','t')
calibrate('c','c')

hp_length=2; % high pass length
lp_freq=15; % low pass frequency
options= 'correct' % there are a number of options ...
    % this one corrects for the body motion. 
calibrate_w(hp_length,lp_freq,options) 

% Al this point, TP, UC, and UCP must be calibrated using their own
% calibration functions: CALIBRATE_TP and CALIBRATE_UC.  Once calibrate_uc
% is run, then calibrate_tp may be used to calibrate UCP.
cal.TP=calibrate_tp(data.TP,head.coef.TP,data.T1,head.coef.T1,cal.FALLSPD);
[cal.UC, head.coef.UC]=calibrate_uc(data.UC,cal.C);
cal.UCP=calibrate_tp(data.UCP,head.coef.UCP,data.UC,head.coef.UC,cal.FALLSPD);

