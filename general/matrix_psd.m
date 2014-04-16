function p=matrix_psd(t,x,nfft,ntoaverage,detrendit);

% function p=matrix_pwd(t,x,nfft,ntoaverage,detrendit);
% 
% t, and x are a time-series, evenly spaced.   nfft is the
% length of the fft, ntoaverage is the number of fft blocks to
% include in each average spectra.  detrendit is a two-element
% matrix that determines how the detrending is done 0 - removes
% mean from each nfft block.   1 - removese the linear trend.
%
% spectral estimates are overlappwed by 50%.  Non-integer multiples of
% nfft/2 are padded to zero.  Each nfft block is windowed using a
% hanning window.
%
% p returns: p.t the mean time of each spectral estimate.
% p.fre the frequency at the spectral estimates.
% p.xx - powerspectrum of x.

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	

  if nargin<6
    detrendit=1;
  end;  
  
  fs = 1/median(diff(t));
  
  % make the window...
  wind=hanning(nfft)';
  
  ntoaverage = ntoaverage*2;
  % make row matrices.
  if size(x,1)>size(x,2)
    x=x';
  end;  
  if size(t,1)>size(t,2)
    t=t';
  end;

  % pad the end of the series to make an even multiple of nfft...
  extra = (floor(length(x)/nfft)+1)*nfft -length(x);
  if extra~=nfft;
    x=[x zeros(1,extra)];
    t=[t mean(t(nfft-extra+1:end))*ones(1,extra)];
  end;
  L = length(x);

  % reshape the matrices to give a 50% overlap.... 
  % this makes a matrix: 1:256; 129:384; 257:512;   etc....
  X = [1:nfft]'*ones(1,2*L/nfft-1);  
  X = X+ones(nfft,1)*[0:(2*L/nfft-2)]*nfft/2;
  x = x(X);
  t = t(X);
  
  % detrend the matrices....
  x = detrend(x,detrendit(1));
  % window them
  x = x.*(wind'*ones(1,size(x,2)));
  
  % take the ffts...
  X = fft(x);
  t = mean(t);
  
  % Normalization for the window.
  W1=2/norm(wind)^2 ;
  
  % calculate the spectrum and co-spectrum....
  XX = X.*conj(X)*W1/fs;
  
  % now smooth...
  if ntoaverage>1
    a = 1; b=ones(1,ntoaverage);b=b/sum(b);
    XX = filter(b,a,XX')';
    t = filter(b,a,t);
  end;
  % decimate
  ind= ntoaverage:size(XX,2);
  XX=XX(2:nfft/2+1,ind);
  % t is the central time of each spectral estimate....
  t = t(ind);
  fre=linspace(fs/nfft,fs/2,nfft/2)';

  p.t = t;
  p.f = fre;
  p.xx = XX; 
