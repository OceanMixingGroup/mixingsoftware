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

calibrate('p','p','l.5')
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

data.T=data.T/head.coef.T(5);
calibrate('t','t');
data.C=data.C/head.coef.C(5);
calibrate('c','c');

calc_salt('sal','c','t','p');
calc_theta('theta','sal','t','p');
calc_sigma('sigth','sal','t','p');

inds=calc_order('sigth','P');

q.fspd=mean(cal.FALLSPD);

calibrate('s1','s',{'h0.3'})
%calibrate('wp','wp',{'l30'})
calibrate('wp','wp',{'h0.3'})

% Determine the cutoff frequency for w:
% this should be a cutoff frequency at 3m.
freq=num2str(3*q.fspd/100/3) ;
%calibrate('w','w',{['h' freq]})
spd=q.fspd;
sp=1/head.coef.W(2);
rho=1.024;
calibrate('w','volts',{['h' freq]});
cal.W=cal.W./(2*rho*spd.*sp);

%**************************
% correct for body motion
	index=1:length(cal.P);
   sr=head.slow_samp_rate; % slow SR
	fn=sr/2; % Nyquist
	g=9.81;
	hpc=.2; % highpass cutoff for w
	lpc=15; % lowpass cutoff for w
	lpcaz=15; % lowpass cutoff for az
	irep_w=head.irep.W;
	irep_az=head.irep.AZ;
	irep_fs=head.irep.FALLSPD;
	% This is set up for cali_w...
	mini=min(index);
	maxi=max(index);
	% 	Make sure that ww matches fallspd.
	% index=mini:maxi; % find(abs(p)>10 & fallspd>50)
	index_az=irep_az*mini:irep_az*maxi;
	index_w=irep_w*mini:irep_w*maxi;
	os=mean(abs(cal.FALLSPD(index)))-mean(cal.W(index_w));
	ww=(cal.W(index_w)+os)/100; %  Pitot in m/s
	az_g=-cal.AZ(index_az)*g; % Body acceleration in m/s^2

% do correction over limited depth range
% lowpass w,az
[bl,al]=butter(8,lpc*irep_w/fn);%lpf chebyshev coeffs.
		wlpf=filtfilt(bl,al,ww);
[bl,al]=butter(8,lpcaz*irep_az/fn);%lpf chebyshev coeffs.
		azlpf=filtfilt(bl,al,az_g);

%highpass s1,w,az
%		[bh,ah]=cheby2(5,40,hpc/fn/irep_s1,'high');%chebyshev coeffs.
%		s1f=filtfilt(bh,ah,s1lpf);
		[bh,ah]=cheby2(5,40,hpc*irep_az/fn,'high');%chebyshev coeffs.
		azf=filtfilt(bh,ah,azlpf);
		[bh,ah]=cheby2(5,40,hpc*irep_w/fn,'high');%chebyshev coeffs.
		wf=filtfilt(bh,ah,wlpf);
		
%correct for body motion
		vaz=cumsum(azf-mean(azf))/(irep_az*sr); %velocity of vehicle
		temp=wf(1:irep_w:length(wf))-(vaz(1:irep_az:length(az_g))-mean(vaz)); % subtract vehicle velocity from w
% highpass 1 more time

temp=filtfilt(bh,ah,temp);
w1=NaN*ones(size(cal.P));
w1(index)=temp;
%*************************************************************
