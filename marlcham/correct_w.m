function correct_w(wser,azser,fpdser,woutser,varargin)
% function CORRECT_W called with no arguments corrects cal.W
% for vehicle motion over all indices (by default it uses cal.AZ and 
% cal.FALLSPD for correction and produces a variable cal.WC).
%
% function CORRECT_W('W','AZ','FALLSPD','WC','property1','value1',...)
% This function was converted from Jim's script to remove vehicle 
% motion (AZ) from the already calibrated W signal to get a WC which 
% can be used for TKE computation. 
% possible property values are:
% 'index', range of slow_sampled indices over which to do the calculation
% hpc  high pass cutoff
% lpc  low pass cutoff
% lpcaz  low pass cutoff for az

% index is the optional range over which the calculations are to be made.
global head cal

% first assign the appropriate series:
if nargin<3
  fallspd=cal.FALLSPD;
  irep_fs=head.irep.FALLSPD;
else
  eval(['fallspd=cal.' fpdser ';'])
  eval(['irep_fs=head.irep.' fpdser ';'])
end
if nargin<2
  az=cal.AZ;
  irep_az=head.irep.AZ;
else
  eval(['az=cal.' azser ';'])
  eval(['irep_az=head.irep.' azser ';'])
end
if nargin==0
  w=cal.W;
  irep_w=head.irep.W;
else
  eval(['w=cal.' wser ';'])
  eval(['irep_w=head.irep.' wser ';'])
end
index=1:length(fallspd);
sr=head.slow_samp_rate; % slow SR
fn=sr/2; % Nyquist
g=9.81;
hpc=.2; % highpass cutoff for w
lpc=15; % lowpass cutoff for w
lpcaz=15; % lowpass cutoff for az

% Now any of the above parameters can be overidden in the following:
a=length(varargin)/2;
if a~=floor(a)
  error('must have matching number of property-pairs')
  return
end
for i=1:2:a*2
  tmp=varargin(i+1);
  eval([lower(char(varargin(i))) '=' num2str(tmp{:}) ';' ])
end

if irep_fs~=1
  error('I''m STUMPED: FALLSPEED MUST BE AT SLOW_SAMP_RATE')
end

% first we'll subsample  w and az if they need to be:
irep_w=length(w)/length(fallspd);
irep_az=length(az)/length(fallspd);
w=w(1:irep_w:length(w));
az=az(1:irep_az:length(az));
os=mean(abs(fallspd(index)))-mean(w(index));
ww=(w(index)+os)/100; %  Pitot in m/s
az_g=-az(index)*g; % Body acceleration in m/s^2

% do correction over limited depth range
% lowpass w,az
[bl,al]=butter(8,lpc/fn);% lpf butter coeffs.
		wlpf=filtfilt(bl,al,ww);
[bl,al]=butter(8,lpcaz/fn);% lpf butter coeffs.
		azlpf=filtfilt(bl,al,az_g);

% highpass s1,w,az
%		[bh,ah]=cheby2(5,40,hpc/fn/irep_s1,'high');%chebyshev coeffs.
%		s1f=filtfilt(bh,ah,s1lpf);
		[bh,ah]=cheby2(5,40,hpc/fn,'high');% chebyshev coeffs.
		azf=filtfilt(bh,ah,azlpf);
		[bh,ah]=cheby2(5,40,hpc/fn,'high');% chebyshev coeffs.
		wf=filtfilt(bh,ah,wlpf);
% correct for body motion
		vaz=cumsum(azf-mean(azf))/sr; % velocity of vehicle
		temp=wf-(vaz-mean(vaz)); % subtract vehicle velocity from w
% highpass 1 more time
temp=filtfilt(bh,ah,temp);
w1=NaN*ones(size(w));
w1(index)=temp;
	% 		this is the quantity of interest
if nargin<4
  cal.WC=w1;
  head.irep.WC=1;
else
  eval(['cal.' woutser '=w1;']);
  eval(['head.irep.' woutser '=1;']);
end