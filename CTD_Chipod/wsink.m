function w = wsink(p,Ts,Fs);
% WSINK Compute sinking velocity from pressure record.
%
% w = wsink(p)
% Computes the sinking (or rising) velocity from the pressure signal p
% by first differencing. The pressure signal is smoothed with a low-pass
% filter for differentiation. 
%
% w = wsink(p,Ts)
% w = wsink(p,Ts,Fs)
% These forms can be used to specify the sampling rate and
% the time contant of the low-pass filter used for averaging.
% If the input signal is shorter than smoothing time scale, 
% w is taken as the slope of the linear regression of p. 
%
% Input parameters:
%    p  pressure [dbar].
%    Ts smoothing time scale [s, default 10]
%    Fs sampling frequency [Hz, default from parameter_list.m]
%
% Output parameters:
%    w  sinking velocity [dbar/s]

% (C) 2002 Rockland Oceanographic Services Inc.
% Author: Fabian Wolk
% Revision: 2002/08/01

error(nargchk(1,3,nargin));
DEFAULTTS = 10;
if nargin<3 Fs = parameter_list('mss','Fs'); end
if nargin<2 Ts = DEFAULTTS; end
if isempty(Fs) Fs = parameter_list('mss','Fs'); end
if isempty(Ts) Ts = DEFAULTTS; end

FORDER = 1; % order of the single pole filter applied to the signal

% low pass filter coefficients
[b,a] = butter(FORDER,1/Ts*2/Fs);

N = length(p);
if N<=Fs*Ts*FORDER
   pol = polyfit((1:N)',p,1);
   w = pol(1)*Fs*ones(N,1);
else
   % pad the pressure vector front and back
   % to reduce filter transients
   nPad = FORDER*Ts*Fs;
   if nPad > N
      warning(sprintf('Length of pressure vector is smaller than padding length.\nFilter transients may occur.'));
   end
   p0 = p(1);
   p = p-p0;
   p = p0+[-flipud(p(1:nPad));p];
   
   p0 = p(end);
   p = p-p0;
   p = p0+[p;-flipud(p(end-nPad+1:end))];
   
   % compute the sinking velocity from first difference
   w = gradient(Fs*filtfilt(b,a,p));
   w = w(nPad+1:end-nPad);   
end
