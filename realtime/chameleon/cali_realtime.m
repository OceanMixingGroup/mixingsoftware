% Script to calibrate sensors:

% First one might want to modify the header coefficients
% %%############# CORRECT FOR CT01B CRUISE ######################
% if (q.script.num==5910 | q.script.num==7888)
%     bad=1;
%     return;
% end
% if q.script.num>=5891 & q.script.num<=5910
%     head.coef.T=[12.068535 1.570163 0.008578 0.000822 1];
% end
% if q.script.num>=7825 & q.script.num<=7888
%     head.coef.T=[11.811 1.269 0.00328 0.000573 1];
% end
% if q.script.num>=7473 & q.script.num<=7494
%     head.coef.C=[3.823639 0.381308 0.000089 -0.000026 1];
% end
% %##############################################################
% head.coef.TP(2)=0.1225;
modify_header
%%
% calibrate is called as 
% calibrate('series','method',{'filter1','filter2',...})
% where series is the series to calibrate ( 'T1', 'TP2', 'S1', 'UC', etc.)
% and method is the method to use ('T','TP','S','UC', etc.)
% filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.

[data,bad]=issync(data,head);
if bad==1
   disp('no sync');
   wait=0;
    return;
end
if length(data.P)<500
   disp('no sync or too short file');
    bad=1;
    wait=0;
    return;
end
calibrate('p','p','l2');
calibrate('az','az')
if (abs(max(cal.P)-min(cal.P))<10 | any(cal.P<-2.5));
   bad=1;
   disp('profile < 10m or negative P');
   disp(['min pressure = ' num2str(min(cal.P))]);
   wait=0;
   return;
end;
% determine if it's down or up cast and set the flag
if nanmean(diff(cal.P))<0
   head.direction='u';
else
   head.direction='d';
end
% run some script or function which selects the appropriate depth range and
% places the indices into q.mini and q.maxi
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% determine_depth_range is one possibility...
if head.direction=='d'
  [q.mini,q.maxi,head.got_bottom]=determine_depth_range2(3);

  % now select only the data within that depth range
  len=select_depth_range(q.mini,q.maxi);
  [data.P,mini,maxi]=extrapolate_depth_range(data.P,min(5000,(length(cal.P)-2)));
  % extrapolate_depth_range flips the ends of p over itself before calibrating so
  % that starting and ending transients are eliminated.
else
   mini=1; maxi=length(data.P);
   head.got_bottom='n';
end
if maxi-mini<500
    disp('profile < 10m');
    bad=1;
    wait=0;
    return;
end
calibrate('p','p','l2') 
calibrate('p','fallspd','l.5') 
data.P=data.P(mini:maxi);
cal.P=cal.P(mini:maxi);
if (abs(max(cal.P)-min(cal.P))<10);
   bad=1;
   disp('profile < 10m');
   wait=0;
   return;
end;
cal.FALLSPD=cal.FALLSPD(mini:maxi);
q.fspd=mean(cal.FALLSPD);

% the following corrects fallspd so that it is the mean of fallspd at
% depth, and is as measured near the surface:
len=round(length(cal.FALLSPD)/2);
mult=zeros(size(cal.FALLSPD));
mult(1:len)=(len:-1:1)/len;
cal.FALLSPD=q.fspd+(cal.FALLSPD-q.fspd).*mult;
calibrate('t','t','l20')
if isfield(data,'T2')
    calibrate('t2','t','l20')
elseif isfield(data,'MHT')
    calibrate('mht','t','l20')
    head.irep.T2=head.irep.MHT;
    cal.T2=cal.MHT;
end
if ~isfield(data,'C')
    calibrate('mhc','c','l20')
    head.irep.C=head.irep.MHC;
    cal.C=cal.MHC;
else
    lag=-6;% I think that this works for the fast drops 
    data.C=lag_sensor(data.C,lag);
    calibrate('c','c','l20')
end
cal.C=cal.C*10;                    
cal.C(cal.C<=0)=NaN;
calibrate('tp','tp')
clear tfield
% if isfield(data,'MHT')
%     tfield='mht';
%     calibrate('mht','t')
% else
%     tfield='t';
% end
tfield='t';
calc_salt('s','c',tfield,'p')
calc_sigma('sigma','s',tfield,'p')
cal.SIGMA=cal.SIGMA-1000;
calc_theta('theta','s',tfield,'p')
calibrate('s1','s',{'h.4','l20'})
calibrate('s2','s',{'h.4','l20'})
calibrate('scat','volts')
calibrate('az','az')
calibrate('ax','tilt')
calibrate('ay','tilt')

temp=filter_series(cal.AZ,102.4*head.irep.AZ,'h2'); % this was changed from .2 to 2
cal.AZ2=temp.*temp;
head.irep.AZ2=head.irep.AZ;

% first calculate thorpe scales...
% for temperature.
calc_order('theta','p');
% for density
calc_order('sigma','p');
% calculate the mean temperature gradient on small scales:
cal.DTDZ=[0 ; diff(cal.THETA_ORDER)./diff(cal.P)];
head.irep.DTDZ=1;
% calculate the mean density gradient on small scales:
cal.DRHODZ=[0 ; diff(cal.SIGMA_ORDER)./diff(cal.P)];
head.irep.DRHODZ=1;
rhoav=mean(cal.SIGMA(1:1:length(cal.SIGMA)-1))+1000;
cal.N2=(9.81/rhoav).*diff(cal.SIGMA_ORDER)./diff(cal.P);
cal.N2(length(cal.N2)+1)=cal.N2(length(cal.N2));
head.irep.N2=head.irep.P;
% calibrate_w(2.2,15,'correct');
% head.irep.WD2=head.irep.WD;
% cal.WD2=cal.WD.*cal.WD;

