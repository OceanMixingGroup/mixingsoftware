function [p,f,N]=gappy_psd(x,nfft,fs,maxgap);
% function [p,f]=gappy_psd(x,nfft,fs,maxgap);
% Computes the psd for x, but is able to "handle" data gaps.  Gaps
% smaller than maxgap (in # of samples) are interpolated over.
% Gaps larger than maxgap are made into separate time-series so
% that no fft is run over a gap in the data.
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
% Originally J. Klymak 

% trim bad data off the front and back....
start = min(find(~isnan(x)));
stop = max(find(~isnan(x)));
x=x(start:stop);
xorig=x;

t=1:length(x);
good =find(~isnan(x));
gapx = x(good);
gapt=t(good);
% interpolate across the gaps....
x = interp1(gapt,gapx,t);
% now find biggaps
dt = diff(gapt);
bad = [find(dt>maxgap) length(gapt)];
goodstart = 1;
% these are the good blocks of data.  For each one run fast_psd,
% and then average the results...
P = 0;
N = 0;
f = NaN;
fnom =linspace(fs/nfft,fs/2,nfft/2)';
for i=1:length(bad)
  goodint = goodstart:gapt(bad(i));
  if length(goodint)>=nfft
    [p,f,n]= fast_psd_jmk(x(goodint),nfft,fs);
    n = length(goodint)./nfft;
    P = P+n*p;
    N=N+n;
  end;
  goodstart = gapt(min(bad(i)+1,length(gapt)));
end;
P=P./N;
p=P;

%gapx([badind:
  
function [powe,fre,repeats]=fast_psd_jmk(x,nfft_in,fs);
% function [Power,Fre,repeats]=fast_psd(x,nfft,Fs) computes the properly 
% normalized psd for a series x.  Just like matlab's.  nfft is the
% desired fourier transform length, and Fs is the sampling
% frequency.  This routine detrends the data and applies a hanning
% window before transforming.  A minium of 50% overlap is used;
% segments are fit so that all of the data is used.

max_ind=length(x);
nfft=min([nfft_in max_ind]);
repeats=fix(2*max_ind/nfft);
if max_ind==nfft
   repeats=1;
   if nfft~=nfft_in
      warning(['Only ' num2str(nfft) ' points are being used for this spectra']); 
   end
end
wind=hanning(nfft);
if size(x,1)==1
  wind=wind';
end


    % I believe the following is the correct normalization for the PSD.
    W1=2/norm(wind)^2 ;
    % jonathan's psd routine which is about twice the speed of the canned
    % one.... 
    total=fft(detrend(x(1:nfft)).*wind);
    powe=total(2:floor(nfft/2+1)).*conj(total(2:floor(nfft/2+1)));
    if (repeats-1)
      step=fix((max_ind-nfft)/(repeats-1));
      for i=step:step:(max_ind-nfft);
         total=fft(detrend(x(i:(i+nfft-1))).*wind);
         powe=powe+total(2:nfft/2+1).*conj(total(2:nfft/2+1));
      end;
    end;
    powe=W1*powe/repeats/fs;
    fre=linspace(fs/nfft,fs/2,nfft/2)';
      if size(x,1)==1
        fre=fre';
    end

%  elseif 0
%    % length(goodint)>0.2*nfft
%    [p,f,n]= fast_psd_jmk(x(goodint),nfft,fs);
%    n= length(p)*2/nfft;
%    if n>0.2
%      p = interp1(f,p,fnom);
%      keyboard;
%      badd=find(isnan(p));p(badd)=0;
%      P = P+n*p;
%      N=N+n;    
%    end;
%  end;