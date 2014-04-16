% Script to calibrate sensors:

% ****************************************
% PRESSURE
[q.butter(1:3) q.butter(4:6)]=butter(2,.02);
cal.p=filtfilt(q.butter(1:3),q.butter(4:6),(qv_calp(data.P,coef.P)*0.689476));
% note that the 0.689476 gives the conversion from psi to db
% make a pressure series with irep=8
cal.p8=interp8(cal.p,8);
irep.P8=8*irep.P;

% ****************************************
% FALLSPEED
% differentiate to get fspd in cm/s

cal.fspd=100*[0 ; diff(cal.p8)]*slow_samp_rate*irep.P8;
irep.FSPD=irep.P8;

% select the range over which to calibrate stuff
% this will be used for the 
% thermocouple
% microconductivity
% fallspd for lagging
% top is the depth to start at
% bot is the height above the bottom to end at
q.top=10;
q.bot=5;
q.mini=max(find(cal.p<q.top));
if(isempty(q.mini))
  q.mini=1;
end
q.maxi=min(find(cal.p>(max(cal.p)-q.bot)));
if q.maxi<q.mini
  q.maxi=length(data.P);
  q.mini=1;
end
q.fspd=mean(cal.fspd(irep.FSPD*(q.mini:q.maxi)));

% first I think that all the sensors should get properly lagged before any
% calibrations are made
% lag in points = lag [cm] x102.4 x irep /fspd
lag=round(-.2*102.4*irep.T0/q.fspd);
data.T0=qv_lag(data.T0,lag);
lag=round(-.2*102.4*irep.SQUARE/q.fspd);
data.SQUARE=qv_lag(data.SQUARE,lag);
lag=round(0.7*102.4*irep.UC/q.fspd);
data.UC=qv_lag(data.UC,lag);
lag=round(0.7*102.4*irep.UCP/q.fspd);
data.UCP=qv_lag(data.UCP,lag);
lag=round(-6*102.4*irep.C/q.fspd);
data.C=qv_lag(data.C,lag);

% ****************************************
% SHEAR
temp=cl_s1_97(ch(data.S1));

cal.s1=qv_cals1(temp,coef.S1,cal.fspd);
% ****************************************
% THERMISTORS
cal.t1=qv_calp(data.T1,coef.T1);

% filter the series at 20 Hz
[b,a]=butter(2,.2);
temp=filtfilt(b,a,ch(data.TP));

% calibrate t-prime
cal.tp1=qv_caltp(temp,coef.TP,data.T1,coef.T1,cal.fspd);
irep.TP1=irep.TP;

if q_script.num>53
% change the calibration for T2 if it is incorrect.  
  coef.T2=[  3.12822029984079   1.87877800685168  -0.04193978327355   0.00450547882969 1.0];
head.coef(5,:)=coef.T2;
end

cal.t2=qv_calp(data.T2,coef.T2);
cal.tp2=qv_caltp(data.ZYNC,coef.ZYNC,data.T2,coef.T2,cal.fspd);
irep.TP2=irep.ZYNC;

% ****************************************
% Thermocouple

[cal.tc,coef.T0]=qv_caltc(cal.t1,data.T0,data.ZQUARE,q.mini,q.maxi);
irep.TC=irep.T0;
[b,a]=butter(2,.2/2);
temp=filtfilt(b,a,ch(data.SQUARE));
% the time constant for the thermocouple was not correct...
coef.SQUARE=[0.092007 0 0 0 1];
cal.tcp=qv_caltcp(temp,coef.SQUARE,data.T0,coef.T0,cal.fspd);
irep.TCP=irep.SQUARE;

% ****************************************
% Conductivity
cal.c=qv_calp(data.C,coef.C);

% ****************************************
% Salinity
cal.s=sw_salt(cal.c/sw_c3515,cal.t1,cal.p);
irep.S=1;

% ****************************************
% Salinity
cal.rho=sw_dens(cal.s,cal.t1,cal.p);
irep.RHO=1;


% ****************************************
% MicroConductivity

[cal.uc,coef.UC]=qv_caluc(data.UC,cal.c,q.mini,q.maxi,'deglitch');

% filter the series at 20 Hz
[b,a]=butter(2,.2/4);
temp=filtfilt(b,a,ch(data.UCP));
cal.ucp=qv_caltp(temp,coef.UCP,data.UC,coef.UC,cal.fspd);

% ****************************************
% AZ
cal.az=qv_calp(data.AZ,coef.AZ);

% ****************************************
% Pitot
temp=qv_calp(data.W,coef.W);
[b,a]=butter(2,.001,'high');
cal.w=filtfilt(b,a,temp);




% ****************************************
% Plotting
% q.series={'fspd','az','s1','tp1','ucp','tcp','t1','c'};
% q.top=1;
% q.bot=1;
% q.mini=max(find(cal.p<q.top));
% q.maxi=min(find(cal.p>(max(cal.p)-q.bot)));
% q.step=10;
% qv_plot;
% ****************************************
% ****************************************
% ****************************************
  