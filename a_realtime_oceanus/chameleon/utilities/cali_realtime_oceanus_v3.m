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
    

    %%%%%% try 6: new calibration coefficients for EQ14 (not perfect, but
    %%%%%% as good as I'm able to get)

    if str2num(head.thisfile(end-4:end))*1000 < 4
        % based on fit of cham 0004 to ctd 12
        head.coef.COND = [2.592310133297870 -0.376285889185778 0.816605326624887 0 0];
        
    elseif str2num(head.thisfile(end-4:end))*1000 >= 4 &...
         str2num(head.thisfile(end-4:end))*1000 < 588
         % based on fit of cham 0400 to ctd 14
         head.coef.COND = [0.631839139848669 1.807231951343833 0.194997096649180 0 0];
         
    elseif str2num(head.thisfile(end-4:end))*1000 >= 588 &...
         str2num(head.thisfile(end-4:end))*1000 < 643
         % based on mean coefs between cham400/ctd14 and cham0705/ctd19
         head.coef.COND = [0.500784349692154 1.960218992738407 0.148265609225988 0 0];
         
    elseif str2num(head.thisfile(end-4:end))*1000 >= 643 &...
         str2num(head.thisfile(end-4:end))*1000 < 754
         % based on fit of cham 0705 to ctd 19
         head.coef.COND = [0.369729559535639 2.113206034132981 0.101534121802797 0 0];
         
    elseif str2num(head.thisfile(end-4:end))*1000 >= 754 &...
         str2num(head.thisfile(end-4:end))*1000 < 1643
         % based on fit of cham 1590 to ctd 30
         head.coef.COND = [0.139948422542979 2.353296664941154 0.038694063508930 0 0];
        
    elseif str2num(head.thisfile(end-4:end))*1000 >= 1643 &...
         str2num(head.thisfile(end-4:end))*1000 <= 1844    
        % based on fit of cham 1795 to ctd 33
         head.coef.COND = [-0.748414979970028   3.278049790610916  -0.211507627468904 0 0];
     
    elseif str2num(head.thisfile(end-4:end))*1000 >= 1845 &...
         str2num(head.thisfile(end-4:end))*1000 < 2072   
         % based on fit of cham 1903 to ctd 34
         head.coef.COND = [-0.410080045856984 2.946972990284236 -0.120832141826407 0 0];
         
    elseif str2num(head.thisfile(end-4:end))*1000 >= 2072 &...
         str2num(head.thisfile(end-4:end))*1000 < 2371   
         % based on fit of cham 2099 to ctd 36
         head.coef.COND = [-0.415530349140461 2.913893846882705 -0.105871120548174 0 0];
         
%     elseif str2num(head.thisfile(end-4:end))*1000 >= 2371 &...
%          str2num(head.thisfile(end-4:end))*1000 < 2582   
%          % based on fit of cham 3089 to ctd 47
%          head.coef.COND = [0.906147540207201 1.519734540413913 0.261708729641122 0 0];
%          
%     elseif str2num(head.thisfile(end-4:end))*1000 >= 2582 &...
%          str2num(head.thisfile(end-4:end))*1000 < 2855   
%          % based on fit of cham 2761 to ctd 43
%          head.coef.COND = [-0.735455345511387 3.265865804239923 -0.199759586962396 0 0];
         
    elseif str2num(head.thisfile(end-4:end))*1000 >= 2371      
        % based on fit of cham 3089 to ctd 47
         head.coef.COND = [0.906147540207201 1.519734540413913 0.261708729641122 0 0];
        
        
    end
 
    disp(num2str(head.coef.COND))

elseif strcmp(head.thisfile(end-9:end-6),'YQ15') == 1
    % as far as I know, there are no header calibration coefficients that
    % need to be changed
    
    % offsets to apply to calibrated T,C to make fit to CTD
    t_offset=0;
    c_offset=0;
    
    
 
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
if length(data.P)<100
   disp('no sync or too short file');
    bad=1;
    wait=0;
    return;
end

% calibrate pressure and vertical accelerations and check to make sure
% profile is long enough and that pressure is right sign
calibrate('p','p','l2');
calibrate('az','az')
% if (abs(max(cal.P)-min(cal.P))<10 | any(cal.P<-2.5));
if (abs(max(cal.P)-min(cal.P))<2 | any(cal.P<-2.5)); %During YQ14, the profiles are so shallow, that we need to reset this to be 4m min rather than 10m min
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
%   [q.mini,q.maxi,head.got_bottom]=determine_depth_range2(3); % SJW Sept 2015: the minimum depth range is set to 3m. In shallow areas like yaquina bay and mobile bay, we want this to be MUCH shallower, especially since we're pulling chameleon all the way out of the water
  [q.mini,q.maxi,head.got_bottom]=determine_depth_range2(0);

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
% if maxi-mini<500
if maxi-mini<100   % during YQ15, casts are very shallow. need to change threshold to be less than 10m
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
% if (abs(max(cal.P)-min(cal.P))<10);
if (abs(max(cal.P)-min(cal.P))<2);  % for YQ15, need to change depth threshold
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
% it looks like "C" has been changed to "Cond". I assume that this lag of
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
calibrate('flr','volts')

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

