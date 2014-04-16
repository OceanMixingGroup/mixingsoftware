 function p=matrix_cohere(t,x,y,nfft,ntoaverage,detrendit);

% function p=matrix_cohere(t,x,y,nfft,ntoaverage,detrendit);
% 
% t, x, and y are a time-series, evenly spaced.   nfft is the
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
% p.yy - powerspectrum of y.
% p.xy - cross-spectrum of x and y.
% p.coh - coherence-spectrum of x and y.
% p.pha - phase spectrum between x and y.
% p.twind  - is the min and max time of each estimate. 
  
  
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	

  
  if nargin<6
    detrendit=[1 1];
  end;
  if length(detrendit)<2
    detrendit = detrendit*[1 1];
  end;  
 
  good = find(~isnan(x));
  if isempty(good)
    p = [];
    return;
  end;
  
  x(good) = detrend(x(good),detrendit(1));
  good = find(~isnan(y));
  y(good) = detrend(y(good),detrendit(1));
  
  fs = 1/median(diff(t));
  
  % make the window...
  wind=hanning(nfft)';
  
  % because of the 50% overlap, double ntoaverage...
  ntoaverage=floor(ntoaverage*2);
  %  ntoaverage = ceil(nblock/nfft);
  % make row matrices.
 
  if size(x,1)>size(x,2)
    x=x';
  end;
  if size(y,1)>size(y,2)
    y=y';
  end;
  if size(t,1)>size(t,2)
    t=t';
  end;
  % pad the end of the series to make an even multiple of nfft...
  extra = (floor(length(x)/nfft)+1)*nfft -length(x);
  if extra~=nfft;
    x=[x zeros(1,extra)];
    y=[y zeros(1,extra)];
    t=[t mean(t(nfft-extra+1:end))*ones(1,extra)];
  end;
  L = length(x);
  %
  noverlap=2;
  repeats=fix(noverlap*L/nfft)-1;
  if repeats>1
    step=(L-nfft)/(repeats-1);
    starts =round(1:step:L-nfft+1);
    starts(end) = L-nfft+1;
  else
    step = 1e12;
    starts =1;
  end;  
  % reshape the matrices to give a 50% overlap.... 
  % this makes a matrix: 1:256; 129:384; 257:512;   etc....
  %X = [1:nfft]'*ones(1,2*L/nfft-1);  
  %X = X+ones(nfft,1)*[0:(2*L/nfft-2)]*nfft/2;
  X = [1:nfft]'*ones(1,repeats);  
  X = ceil(X+ones(nfft,1)*(starts-1));

  x = x(X);
  y = y(X);
  t = t(X);
  
  % single columns should now column matrices not rows.   
  if size(x,1)~=size(X,1)
      x=x';y=y';t=t';
  end;
  
  % detrend the matrices....
  x = detrend(x,detrendit(1));
  y = detrend(y,detrendit(2));
  % window them
  x = x.*(wind'*ones(1,size(x,2)));
  y = y.*(wind'*ones(1,size(x,2)));
  
  % take the ffts...
  X = fft(x);
  Y = fft(y);
  t = mean(t);
  twind = [min(t) max(t)];
  % Normalization for the window.
  W1=2/norm(wind)^2 ;
  
  % calculate the spectrum and co-spectrum....
  XX = X.*conj(X)*W1/fs;
  YY = Y.*conj(Y)*W1/fs;
  XY = X.*conj(Y)*W1/fs;
  % there can be NaNs in here.  How to deal with them?
  
  % now smooth...
  if size(XX,2)>ntoaverage
    a = 1; b=ones(1,ntoaverage);b=b/sum(b);
    XX = Nanfilter(b,a,XX')';  % see below for Nanfilter
    YY = Nanfilter(b,a,YY')';
    XY = Nanfilter(b,a,XY')';
    t = filter(b,a,t);
    % remove the stuff at the beginning that did not filter well....
    ind= ntoaverage:size(XX,2);
    if isempty(ind)
      ind=size(XX,2);
    end;
  else;
    XX = nanmean(XX')';
    YY = nanmean(YY')';
    XY = nanmean(XY')';
    t = mean(t);    
    ind = 1;
  end;
  if size(XX,1)==nfft
   XX=XX(2:nfft/2+1,ind);
   YY=YY(2:nfft/2+1,ind);
   XY=XY(2:nfft/2+1,ind);
   % t is the central time of each spectral estimate....
   t = t(ind);
  
   fre=linspace(fs/nfft,fs/2,nfft/2)';

   p.t = t;
   p.f = fre;
   p.xx = real(XX);
   p.yy = real(YY); % this fixes NaN=NaN+i*NaN which is silly
   p.xy = XY;
   p.coh = abs(XY).^2./XX./YY;
   p.pha = atan2(imag(XY),real(XY));
   p.twind = twind;
else
%    keyboard;
    p=[];
end;
return;

%%%%%%%%%%%%%%%%%%%%%  

function XX=Nanfilter(b,a,XX);

  if length(find(isnan(XX(:))))>0
    for i=1:size(XX,2)
      good = find(~isnan(XX(:,i)));
      if length(good)>2
        x=interp1(good,XX(good,i),[1:size(XX,1)]','linear','extrap');
        x = filter(b,a,x);
        XX(good,i)=x(good);
      end;
      
    end;
  else
    XX = filter(b,a,XX);
    % no bad data, don't do all this....
  end;
  
  
return
  