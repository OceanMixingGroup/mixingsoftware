function calibrate_w(highpass_length,lowpass_freq,varargin)
% CALIBRATE_W calibrates the pitot signal and optionally correct for body motion 
% Call as calibrate_w(HIGHPASS_LENGTH,LOWPASS_FREQ,options) 
% this both highpasses and lowpasses the signal.
%
% With no options, this requires data.W, cal.FALLSPD and produces cal.WD,
% which is a subsampled, calibrated pitot series.
% If the option 'correct' is specified, this corrects for body motion using
% cal.AZ.  
% the default series of 'w' for input, 'wd' for output, 'az' for accel and
% 'fallspd' for fallspeed can be overridden by specifying 'w','w_alt',
% 'az','az_alt' etc as options.  
% also the option 'index',[ index range] can be specified to perform the
% body motion correction over a limited  region. index refers to the 
% slow-sampled indices.
% the option 'cheby_order',ORDER may be selected to change the high
% pass cheby filter to something higher (or lower) than the default
% of 5.  If ringing occurs, it is generally from this. 

% This function calibrates raw voltages from DC-pitot
% module using sensitivity in header coeff.W(2)
% NOT CGS units anymore; note the factor of 100. 
global data cal head
correct=0;
% the following are the default series to be used: 
cheby_order=5;
az='az';
fallspd='fallspd';
w='w';
wd='wd';
% the following allows and of the above assignments to be changed.
if nargin>2
  i=1;
  while i<=(nargin-2)
    if strcmp(lower(char(varargin(i))),'correct')
      correct=1;
    elseif strcmp(lower(char(varargin(i))),'cheby_order')
      tmp=varargin(i+1);
      cheby_order=tmp{:};
      i=i+1;
    elseif strcmp(lower(char(varargin(i))),'index')
      tmp=varargin(i+1);
      index=tmp{:};
      i=i+1;
    else
      eval([lower(char(varargin(i))) '=''' lower(char(varargin(i+1)))  ''';' ])
      i=i+1;
    end
    i=i+1;
  end
end
% first some definitions:
eval(['coef=head.coef.' upper(w) ';'])
eval(['irep=head.irep.' upper(w) ';'])
eval(['irep_az=head.irep.' upper(az) ';'])
eval(['in=data.' upper(w) ';'])
eval(['spd=cal.' upper(fallspd) ';'])
eval(['azz=cal.' upper(az) ';'])
eval(['head.irep.' upper(wd) '=head.irep.' upper(fallspd) ';'])
if ~exist('index','var')
  index=1:length(spd);
end
rho=1.024;% nominal density
if size(in,2)==2
  in=ch(in);
end

mean_spd=mean(spd);
% first we must low pass and high pass the series. 

sr=irep*head.slow_samp_rate; % SR
fn_w=sr/2;  % Nyquist
% high pass cutoff in Hz is:
highpass_freq=(mean_spd/100)/highpass_length;

% lowpass
[bl,al]=cheby2(9,40,lowpass_freq/fn_w);% lpf butter coeffs.
in=filtfilt(bl,al,in);
% highpass
[bh,ah]=cheby2(cheby_order,40,highpass_freq/fn_w,'high');% chebyshev coeffs.
in=filtfilt(bh,ah,in);

in=in(1:length(in)/length(spd):length(in));

% check to make sure gain is non-zero:
if ~coef(5),coef(5)=1;, end
if ~coef(3),coef(3)=1;, end

sp=coef(5)/(coef(2)*coef(3));% probe sensitivity [volts/(dyne/cm^2)]
out=in./(2*rho*spd.*sp*100); % the 100 converts to m/s from cm/s

if ~correct
  eval(['cal.' upper(wd) '=out;'])
else

% plot(out)
% pause
% hold on
  % the following routine corrects w for acceleration of the body:
  g=9.81;
  sr=irep_az*head.slow_samp_rate;
  fn_az=sr/2; % Nyquist
  % these might be different than above if irep.az~=irep.fallspd
  [bl,al]=cheby2(9,40,lowpass_freq/fn_az);% lpf cheby coeffs.
  azz=filtfilt(bl,al,azz);
  % highpass
  [bh,ah]=cheby2(cheby_order,40,highpass_freq/fn_az,'high');% chebyshev coeffs.
  azz=filtfilt(bh,ah,azz);
  azz=azz(1:length(azz)/length(spd):length(azz));
 % plot(azz,'k')
  
  % new series has a slow_sampled irep_rate.
  sr_wd=head.slow_samp_rate;
  fn_wd=sr/2; % Nyquist
%  os=mean(abs(spd(index)))-mean(out(index));
%  ww=(out(index)+os); %  Pitot in m/s
ww=out(index);
  az_g=-azz(index)*g; % Body acceleration in m/s^2
  %   plot(az_g,'g')		
  %correct for body motion
  vaz=cumsum(az_g-mean(az_g))/sr_wd; % velocity of vehicle
% plot(az_g)
  [bh,ah]=cheby2(cheby_order,40,highpass_freq/fn_wd,'high');% chebyshev coeffs.
  vaz=filtfilt(bh,ah,vaz);
  %plot(vaz,'r')
  %hold on
  %plot(ww,'b')
temp=ww-(vaz-mean(vaz)); % subtract vehicle velocity from w
%   plot(temp,'c')
  % highpass 1 more time
  [bh,ah]=cheby2(cheby_order,40,highpass_freq/fn_wd,'high');% chebyshev coeffs.
  temp=filtfilt(bh,ah,temp);
  
  eval(['cal.' upper(wd) '=NaN*ones(size(spd));'])
  eval(['cal.' upper(wd) '(index)=temp;'])
  % 		this is the quantity of interest
  
end
