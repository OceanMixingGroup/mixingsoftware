function p=gappy_fast_cohere(x,y,nfft,fs,maxgap)
% function p=gappy_fast_cohere(x,y,nfft,fs,maxgap)
% performs the coherence between x an y.  Returns a structure p that
% should have self-explanatory fields.
% It is able to "handle" data gaps.  Gaps
% smaller than maxgap (in # of samples) are interpolated over.
% Gaps larger than maxgap are made into separate time-series so
% that no fft is run over a gap in the data.
% $Revision: 1.2 $ $Date: 2012/04/04 22:53:53 $ $Author: aperlin $	
% Originally J. Klymak 

% trim bad data off the front and back....
  
if size(x,1)~=1;x=x';end
if size(y,1)~=1;y=y';end
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
N = 0;
f = NaN;
fnom =linspace(fs/nfft,fs/2,nfft/2)';
P.xx=0;
P.xy=0;
P.yy=0;
for i=1:length(bad)
  goodint = goodstart:gapt(bad(i));
  if length(goodint)>=nfft
    detrendit=[1 1];
    p= fast_cohere(x(goodint),y(goodint),nfft,fs,detrendit);
    n = length(goodint)./nfft;
    P.xx = P.xx+n*p.xx;
    P.xy = P.xy+n*p.xy;
    P.yy = P.yy+n*p.yy;
    N=N+n;
  end;
  goodstart = gapt(min(bad(i)+1,length(gapt)));
end;
P.xx=P.xx./N;
P.xy=P.xy./N;
P.yy=P.yy./N;
p.xx=P.xx;
p.xy=P.xy;
p.yy=P.yy;


function p=fast_cohere(x,y,nfft_in,fs,detrendit)
% function p=fast_cohere(x,y,nfft,Fs) 
% 
% performs the coherence between x an y.  Returns a structure p that
% should have self-explanatory fields.
%
% See Also: fast_psd

% $Id: gappy_fast_cohere.m,v 1.2 2012/04/04 22:53:53 aperlin Exp $
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



