spd=q.fspd;
sp=1/(head.coef.W(2));
rho=1.024;
head.irep.W=length(data.W)/length(data.P);

sr=head.irep.W*head.slow_samp_rate; % SR
fn=sr/2; % Nyquist

% filter series
filt_lngth=2.2; % highpass filter length [m]
lpc=10; % lowpass filter cutoff [Hz]
hpc=(spd/100)/filt_lngth; % highpass filter cutoff [Hz]
x=data.W;	% define series

% lowpass
[bl,al]=cheby2(9,40,lpc/fn);% lpf butter coeffs.
xlpf=filtfilt(bl,al,x);
      
% highpass
[bh,ah]=cheby2(7,40,hpc/fn,'high');% chebyshev coeffs.
xhpf=filtfilt(bh,ah,xlpf);

% calibrate in cgs units
clear cal.W
data.W=xhpf;
calibrate('w','volts');
cal.W=cal.W./(2*rho*spd.*sp);
data.W=x;

%correct_w
