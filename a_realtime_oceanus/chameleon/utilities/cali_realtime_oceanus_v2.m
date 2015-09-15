% cali_realtime_oceanus
%
% adapted from cali_realtime for the YQ14 cruise. 
%   -   conductivity: C was changed to COND
%   -   temperature: T and T2 were changed to T1 and T2
%   -   salinity: S changed to SAL
%
% This code is a bit antiquated still. It uses a structure "q" that I would
% love to get rid of. 
%
%
% Comments from old cali_realtime:
%
% calibrate is called as 
% calibrate('series','method',{'filter1','filter2',...})
% where series is the series to calibrate ( 'T1', 'TP2', 'S1', 'UC', etc.)
% and method is the method to use ('T','TP','S','UC', etc.)
% filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.
%
% Script to calibrate sensors:
%
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
%
%
%
% Futher notes by Sally Warner, January 2014
%
% (sjw Nov 2014) v2 is changed to add calc_epsilon_filt_gen and set_filters
% instead of just using calc_epsilon


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% CHANGE HEADER COEFFICIENTS IF NECESSARY %%%%%

%%%%% The coefficients are wrong for the YQ14 cruise. Jim fit the
%%%%% chameleon data to the ctd data to get the best coefficients.

% if strcmp(head.thisfile(end-10:end-7),'YQ14') == 1
if strcmp(head.thisfile(end-9:end-6),'YQ14') == 1
    
    % based on fits to ctd04 / profile 938
    head.coef.T1=[52.0 34.8 6.91 0 0];
    head.coef.T2=[-15.8 -21.9 -4.77 0 0];
%     head.coef.C=[0.69 2.10 0 0 0];
 
    % offsets to apply to calibrated T,C to make fit to CTD
    t_offset=0;
    c_offset=0.09;
    
    
elseif strcmp(head.thisfile(end-9:end-6),'EQ14') == 1
    
    disp('using new cali coefs')
    
    if str2num(head.thisfile(end-4:end))*1000 < 1643
     
        % based on fits to ctd04 / profile 938
    %     head.coef.T1=[21.6659 3.4690 0.0528 0.0095 0];
    %     head.coef.T2=[21.9858 3.8049 0.1993 0.0690 0];
    %     head.coef.COND=[16.9396 -25.2747 15.1426 -2.7321 0];
    %     head.coef.COND=[10.5962 -14.7959 9.3676 -1.6806 0];
%         head.coef.T1=[21.7618 3.5440 0.0404 0 0];
%         head.coef.T2=[22.1453 3.8255 0.0162 0 0];
        head.coef.COND = [-0.2137 2.7161 -0.0479 0 0];

        % offsets to apply to calibrated T,C to make fit to CTD
        t_offset=0;
        c_offset=0;
    
    elseif str2num(head.thisfile(end-4:end))*1000 > 1643 
        
        % based on fit of cham 1652 to ctdcast 32
        
        head.coef.COND = [0.0294 2.4225 0.0166 0 0];
        
        
    end
 
 
 
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% make a small change to the shear coefficients within the header
modify_header


% make sure the chameleon has been synced with the computer
[data,bad]=issync(data,head);
if bad==1
   disp('no sync');
   wait=0;
    return;
end

% make sure length of file is long enough
if length(data.P)<500
   disp('no sync or too short file');
    bad=1;
    wait=0;
    return;
end

% calibrate pressure and vertical accelerations and check to make sure
% profile is long enough and that pressure is right sign
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
%
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

% check to make sure the cast is long enough
if maxi-mini<500
    disp('profile < 10m');
    bad=1;
    wait=0;
    return;
end

%%%% PRESSURE %%%%
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

%%%% FALL SPEED %%%%
cal.FALLSPD=cal.FALLSPD(mini:maxi);
q.fspd=mean(cal.FALLSPD);

% the following corrects fallspd so that it is the mean of fallspd at
% depth, and is as measured near the surface:
len=round(length(cal.FALLSPD)/2);
mult=zeros(size(cal.FALLSPD));
mult(1:len)=(len:-1:1)/len;
cal.FALLSPD=q.fspd+(cal.FALLSPD-q.fspd).*mult;

%%%% TEMPERATURE %%%%
calibrate('t1','t','l20')
if isfield(data,'T2')
    calibrate('t2','t','l20')
elseif isfield(data,'MHT')
    calibrate('mht','t','l20')
    head.irep.T2=head.irep.MHT;
    cal.T2=cal.MHT;
end

%%%% CONDUCTIVITY %%%
% it looks like "C" has been changed to "COND". I assume that this lag of
% -6 is needed. ** talk to Jim about this **
% if ~isfield(data,'C')
%     calibrate('mhc','c','l20')
%     head.irep.C=head.irep.MHC;
%     cal.C=cal.MHC;
% else
%     lag=-6;% I think that this works for the fast drops 
%     data.C=lag_sensor(data.C,lag);
%     calibrate('c','c','l20')
% end

% not sure if lag needs to be included!
lag=-6;
data.COND=lag_sensor(data.COND,lag);
calibrate('cond','c','l20')                   
cal.COND(cal.COND<=0)=NaN;

% apply T,C offsets
if exist('c_offset')
    cal.T1=cal.T1+t_offset;
    cal.COND=cal.COND+c_offset;
end


%%%% TEMPERATURE DIFFERENTIAL %%%%
% calibrate('tp','tp')
% clear tfield
head.coef.TP(2)=0.1;
calibrate('tp','volts',{'h1','l15'});
data.TP=cal.TP;
cal.TP=calibrate_tp(data.TP,head.coef.TP,data.T1,head.coef.T1,cal.FALLSPD);


% THIS WAS ALREADY COMMENTED OUT
% determine which temperature to use when calculating conductivity.
% if isfield(data,'MHT')
%     tfield='mht';
%     calibrate('mht','t')
% else
%     tfield='t';
% end
tfield='t1';

% SALINITY
% calc_salt('sal','cond',tfield,'p')
cal.SAL=sw_salt(10*cal.COND/sw_c3515,cal.T1,cal.P); % convert to mmho/cm 1st, so multipy by 10
head.irep.SAL=head.irep.P;

% SIGMA THETA
calc_sigma('sigma','sal',tfield,'p')
cal.SIGMA=cal.SIGMA-1000;
calc_theta('theta','sal',tfield,'p')

% SHEAR
calibrate('s1','s',{'h.4','l20'})
calibrate('s2','s',{'h.4','l20'})

% SCATTERING
calibrate('scat','volts')

% ACCELERATIONS
calibrate('az','az')
calibrate('ax','ax')
calibrate('ay','ay')
calibrate('ax','tilt','l.8')
calibrate('ay','tilt','l.8')

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

