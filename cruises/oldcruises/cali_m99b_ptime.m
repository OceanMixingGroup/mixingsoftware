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
[sontek]=get_speedf(ip,it);
% interpolate to slow_samp_rate
R=fix(20*slow_samp_rate);
spd=(interp(sontek.speed,R))';
lenspd=length(spd);
cal.FALLSPD=100.*spd(lenspd/4+1:1:end-lenspd/4); % get middle points only
head.irep.FALLSPD=head.irep.P1;
q.fspd=mean(cal.FALLSPD);

% new T/C coefficents using SeaBird fits
   head.coef.T1(1:4)=[8.827 1.846 0.00532 0];
   head.coef.T2(1:4)=[10.136 1.812 0.00311 0];
if any(ip==[450:1685])
   head.coef.T4(1:4)=[3.733 0.3681 0.000404 0];
end
if any(ip==[988:4456])
   head.coef.C2(1:4)=[4.188 0.343 0.00169 0];
end
if any(ip=[2466:4456])
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
calibrate('p1','p','l0.5') 
calibrate('vx','poly')

calibrate('ax1','tilt')
calibrate('ax2','tilt')
calibrate('ay','tilt')
calibrate('az','az')
%cal.AXHI=cal.AX2;
%calibrate('ax2','ax','l1')
%cal.AXLO=cal.AX2;
%calibrate('ay','ay','h1')
%cal.AYHI=cal.AY;
%calibrate('ay','ay','l1')
%cal.AYLO=cal.AY;
%calibrate('az','az','h1')
%cal.AZHI=cal.AZ;
%calibrate('az','az','l1')
%cal.AZLO=cal.AZ;


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

%q.fspd=mean(cal.VX);
%cal.FALLSPD=cal.VX;
%head.irep.FALLSPD=head.irep.VX;
%if mean(cal.FALLSPD<20)
%   cal.FALLSPD(1:end)=85;
%end

data.S1=remove_sonar_spikes(data.S1);
calibrate('s1','s',{'h1','l30'})
data.S2=remove_sonar_spikes(data.S2);
calibrate('s2','s',{'h1','l30'})
data.S3=remove_sonar_spikes(data.S3);
calibrate('s3','s',{'h1','l30'})

% Determine the cutoff frequency for w:
% this should be a cutoff frequency at 3m.
%freq=num2str(q.fspd/100/3) ;
%calibrate('w','w',{['h' freq]})
calibrate('w1','volts','l10')
calibrate('scat','volts')

calibrate('c1','c','l5');
calibrate('c2','c','l5');
calibrate('t1','t')
calibrate('t2','t')
calibrate('t3','t')
calibrate('t4','t')
calibrate('t5','t')
calibrate('tf4','t')
calibrate('tf2','t')
calibrate('tf3','t')
head.coef.T1P(2)=0.1;
calibrate('t1p','volts',{'h1','l20'})
data.T1P=cal.T1P;
cal.T1P=calibrate_tp(data.T1P,head.coef.T1P,data.T1,head.coef.T1,cal.FALLSPD);

head.coef.T2P(2)=0.1;
calibrate('t2p','volts',{'h1','l20'})
data.T2P=cal.T2P;
cal.T2P=calibrate_tp(data.T2P,head.coef.T2P,data.T2,head.coef.T2,cal.FALLSPD);

head.coef.T3P(2)=0.1;
calibrate('t3p','volts',{'h1','l20'})
data.T3P=cal.T3P;
cal.T3P=calibrate_tp(data.T3P,head.coef.T3P,data.T3,head.coef.T3,cal.FALLSPD);
