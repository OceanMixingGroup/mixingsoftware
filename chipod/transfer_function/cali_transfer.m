% Script to calibrate sensors:
% First one might want to modify the header coefficients
%   $Revision: 1.2 $  $Date: 2009/06/09 22:12:09 $

global cal data head

head.coef.S1(1)=1e-4*head.coef.S1(1);
% calibrates Chameleon data for transfer function scripts
% calibrate is called as 
% calibrate('series','method',{'filter1','filter2',...})
% where series is the series to calibrate ( 'T1', 'TP2', 'S1', 'UC', etc.)
% and method is the method to use ('T','TP','S','UC', etc.)
% filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.
cal=[];
[cal]=mg_calibrate('P','p','l.5',data,head,cal);
[cal]=mg_calibrate('AZ','poly',data,head,cal);


% first let us select the range over which the data is the real drop:
% start at 9m

% run some script or function which selects the appropriate depth range and
% places the indices into q.mini and q.maxi

% determine_depth_range is one possibility...
[q.mini,q.maxi]=determine_depth_range2(0);

%q.maxi=q.maxi-50;   % pso1 - i found end of profile not detected properly 
                    % and am trying a quick fix for 3P analysis

% now select only the data within that depth range
len=select_depth_range(q.mini,q.maxi);
[data.P,mini,maxi]=extrapolate_depth_range(data.P,100);
% extrapolate_depth_range flips the ends of p over itself before calibrating so
% that starting and ending transients are elliminated.
[cal]=mg_calibrate('P','p','l.5',data,head,cal);
[cal]=mg_calibrate('P','fallspd','l.5',data,head,cal);

data.P=data.P(mini:maxi);
cal.P=cal.P(mini:maxi);
cal.FALLSPD=cal.FALLSPD(mini:maxi);

q.fspd=mean(cal.FALLSPD);


[cal]=mg_calibrate('S1','s',{'h0.4','l20'},data,head,cal);

spd=q.fspd;
%sp=1/head.coef.W(2);
rho=1.024;

if isfield(data,'MHT')
    [cal]=mg_calibrate('MHT','t',data,head,cal);
else
    [cal]=mg_calibrate('T','t',data,head,cal);
end
% [cal]=mg_calibrate('MHC','c',data,head,cal);



% 
% cond=cal.MHC(1:head.irep.MHC:length(cal.MHC));
% temp=cal.MHT(1:head.irep.MHT:end);
% press=cal.P;
% cal.SAL=sw_salt(10*cond/sw_c3515,temp,press); % convert to mmho/cm 1st
% head.irep.SAL=head.irep.P;
% %cal.SIGTH=sw_pden(salinity,cal.T,cal.P,0)-1000head;
% %head.irep.SIGTH=head.irep.P;
% 
% %calc_salt('sal','c','t','p');
% calc_theta('theta','sal','t','p');
% calc_sigma('sigth','sal','t','p');
data.UKTCP=-data.UKTCP;
