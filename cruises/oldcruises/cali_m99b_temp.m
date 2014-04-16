% Script to calibrate sensors:

% First one might want to modify the header coefficients

head.coef.S1(1)=1e-4*head.coef.S1(1);
head.coef.S2(1)=1e-4*head.coef.S2(1);
head.coef.S3(1)=1e-4*head.coef.S3(1);

% for MARLIN processing we need to use ADP data for FALLSPD
% for m99b, we get data every 20 seconds 
%[sontek]=get_speed(ip)
% interpolate to slow_samp_rate
%R=fix(20*slow_samp_rate);
%cal.FALLSPD=(interp(sontek.speed,R))';
%head.irep.FALLSPD=head.irep.P1;
%q.fspd=mean(cal.FALLSPD);

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

% set VX coefficients to those determined by fit of velocity
% sensor to ADP speeds
head.coef.VX(1:2)=[13.2 43.3]; 

% new T/C coefficents using SeaBird fits
   head.coef.T1(1:4)=[8.827 1.846 0.00532 0];
   head.coef.T2(1:4)=[10.136 1.812 0.00311 0];
for ip=[450:1685]
   head.coef.T4(1:4)=[3.733 0.3681 0.000404 0];
end
for ip=[988:4456]
   head.coef.C2(1:4)=[4.188 0.343 0.00169 0];
end
for ip=[2466:4456]
   head.coef.T3(1:4)=[3.5341 -0.34377 0.00024278 0];
   head.coef.T4(1:4)=[3.37 0.366 0.00103 0];
   head.coef.T5(1:4)=[6.4435 0.30611 0.00038854 0];
   head.coef.TF2(1:4)=[7.2889 1.6721 0.0048971 0];
   head.coef.TF3(1:4)=[9.732 1.73 0.0029295 0];
   head.coef.TF4(1:4)=[9.0648 1.6591 0.0043765 0];
   head.coef.C1(1:4)=[2.58 0.198 0.000181 0];
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

calibrate('p2','p','l0.5')
%calibrate('p1','p','l0.5') 
%calibrate('vx','poly')

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

%cal.FALLSPD=cal.VX;
%head.irep.FALLSPD=head.irep.VX;
%if mean(cal.FALLSPD<20)
%   cal.FALLSPD(1:end)=85;
%end

% Determine the cutoff frequency for w:
% this should be a cutoff frequency at 3m.
%freq=num2str(q.fspd/100/3) ;
%calibrate('w','w',{['h' freq]})

calibrate('c1','c');
calibrate('c2','c');
calibrate('t1','t')
calibrate('t2','t')
%calibrate('t3','t')
calibrate('t4','t')
%calibrate('t5','t')
%calibrate('tf4','t')
%calibrate('tf2','t')
%calibrate('tf3','t')
