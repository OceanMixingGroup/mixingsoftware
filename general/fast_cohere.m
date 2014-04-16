function p=fast_cohere(x,y,nfft_in,fs,detrendit);
% function p=fast_cohere(x,y,nfft,Fs) 
% 
% performs the coherence between x an y.  Returns a structure p that
% should have self-explanatory fields.
% p returns: 
% p.xx - powerspectrum of x.
% p.yy - powerspectrum of y.
% p.xy - cross-spectrum of x and y.
% p.coh - coherence-spectrum of x and y.
% p.pha - phase spectrum between x and y.
% See Also: fast_psd
%
% $Id: fast_cohere.m,v 1.2 2008/02/13 18:58:27 aperlin Exp $
  if nargin<5
    detrendit=[1 1];
  end;
  
  
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
total=fft(detrend(x(1:nfft),detrendit(1)).*wind);
powe_x=total(2:floor(nfft/2+1)).*conj(total(2:floor(nfft/2+1)));
xx=total;

total=fft(detrend(y(1:nfft),detrendit(2)).*wind);
powe_y=total(2:floor(nfft/2+1)).*conj(total(2:floor(nfft/2+1)));
powe_xy = total(2:floor(nfft/2+1)).*conj(xx(2:floor(nfft/2+1)));

if (repeats-1)
  step=fix((max_ind-nfft)/(repeats-1));
  for i=step:step:(max_ind-nfft);
    total=fft(detrend(x(i:(i+nfft-1)),detrendit(1)).*wind);
    powe_x=powe_x+total(2:nfft/2+1).*conj(total(2:nfft/2+1));
    xx=total;
    
    total=fft(detrend(y(i:(i+nfft-1)),detrendit(2)).*wind);
    powe_y=powe_y+total(2:nfft/2+1).*conj(total(2:nfft/2+1));
    powe_xy = powe_xy+total(2:floor(nfft/2+1)).*conj(xx(2:floor(nfft/2+1)));
  end;
end;
powe_x=W1*powe_x/repeats/fs;
powe_y=W1*powe_y/repeats/fs;
powe_xy=W1*powe_xy/repeats/fs;
fre=linspace(fs/nfft,fs/2,nfft/2)';
if size(x,1)==1
  fre=fre';
end
p.f = fre;
p.xx = powe_x;p.yy = powe_y;p.xy = powe_xy;

p.pha = atan2(imag(p.xy),real(p.xy));

p.coh = (abs(p.xy).^2)./(p.xx.*p.yy);



