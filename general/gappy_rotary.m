function [out,f,spec,n]=gappy_rotary(x,nfft,fs,maxgap);
%function [out,f,spec,n]=gappy_rotary(x,nfft,fs,maxgap);
% IT slices IT dices.  All purpose power spectra program.  It is based upon
% Jonathan's fast_psd.m (using his normalization and hanning routines) and 
% Jody's gappy series of programs (allowing a gappy time series to be
% inputed).
%--------------------------------------------------------------------------
% x is the input timeseries.  It can be either real, imaginary, or complex.
% nfft is the number of points to be used in each psd estimate
% fs is the sample frequency
% maxgap is the length of the maximum gap to be interped over in
% calculating a psd.
%--------------------------------------------------------------------------
%the program will split the data into ensembles based upon the record
%length, the nfft length, and the position of any large gaps.  Matlab's FFT
% is run on each ensemble and the results are averaged.  
%--------------------------------------------------------------------------
%outputs:
%out is a structure containg nfft/2 data points.
%   Gxx is the PSD of the real part of x
%   Gyy is the PSD of the imag part of x
%   Gxy is the total PSD of x (equivalent to Gxx + Gyy)
%   CW is the Clockwise PSD of x
%   CCW is counterclockwise PSD of x
%---
%f contains the frequencies (nfft/2 points)
%---
%spec is a strcture containing data nfft points.  These data are the
%full length PSD (nfft data points).
%   Gxx is the PSD of the real part of x
%   Gyy is the PSD of the imag part of y
%   Gxy (imaginary) is the PSD of x
%   Cxy is the co-spectra of x (note Cxy is symmetric)
%   Qxy is the quad-spectra of x (note Qxy is anti-symmetric).
%---------
%n is an estimate of the degrees of freedom in the output spectral data
%(for use in calculating confidence limits).  
%--------------------------------------------------------------------------
%see page 318 of Bendat and Piersol for a start on co/quad/rotary spectra.
%-greg
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $


y=imag(x);
x=real(x);

nfft=floor(nfft);
if nfft/2~=floor(nfft/2)
    nfft=nfft-1;
end

[m,n]=size(x);
if m>n
    x=x';
    y=y';
end
  
% save the real x...
xx=[x;y];
% make x the way that we find good/bad data....
x = sum([xx]);


% trim bad data off the front and back....
start = min(find(~isnan(x)));
stop = max(find(~isnan(x)));
x=x(start:stop);
xx=xx(:,start:stop);
xorig=x;
good=find(~isnan(x));
t=1:length(x);
gapx = xx(:,good);
gapt=t(good);
% interpolate across the gaps....
if size(gapt,1)*size(gapt,2)>1
  xx = interp1(gapt,gapx',t)';
end;

% now find biggaps
dt = diff(gapt);
bad = [find(dt>maxgap) length(gapt)];
goodstart = 1;
 
f = NaN;
fftd=[];

fnom =linspace(fs/nfft,fs/2,nfft/2)';

wind=hanning(nfft)';
W1=2/norm(wind)^2 ;
count=0;

Gxx(1:nfft)=0;
Gyy(1:nfft)=0;
Cxy(1:nfft)=0;
Qxy(1:nfft)=0;
Gxy(1:nfft)=0;
lencount=0;
for n=1:length(bad)
    goodint = goodstart:gapt(bad(n));
    len = length(goodint);
    if len>=nfft
        lencount=lencount+len;

        xdat = xx(1,goodint)+i*xx(2,goodint);
        repeats=fix(2*length(xdat)/nfft);
        if length(xdat)==nfft
            repeats=1;
        end
        X=fft(detrend(real(xdat(1:nfft)),0).*wind);
        Y=fft(detrend(imag(xdat(1:nfft)),0).*wind);
        Z=fft(detrend(real(xdat(1:nfft))+i.*imag(xdat(1:nfft)),0).*wind);
        Gxx=Gxx+X.*conj(X);
        Gyy=Gyy+Y.*conj(Y);
        Gxy=Gxy+Z.*conj(Z);
        Cxy=Cxy+real(X).*real(Y)+imag(X).*imag(Y);
        Qxy=Qxy+real(X).*imag(Y)-imag(X).*real(Y);
        
        count=count+1;
        if (repeats-1)
            step=fix((length(xdat)-nfft)/(repeats-1));
            for m=step:step:(length(xdat)-nfft);
                X=fft(detrend(real(xdat(m:(m+nfft-1))),0).*wind);
                Y=fft(detrend(imag(xdat(m:(m+nfft-1))),0).*wind);
                Z=fft(detrend(real(xdat(m:(m+nfft-1)))+i.*imag(xdat(m:(m+nfft-1))),0).*wind);
                Gxx=Gxx+X.*conj(X);
                Gyy=Gyy+Y.*conj(Y);
                Gxy=Gxy+Z.*conj(Z);
                Cxy=Cxy+real(X).*real(Y)+imag(X).*imag(Y);
                Qxy=Qxy+real(X).*imag(Y)-imag(X).*real(Y);
                
                count=count+1;
            end;
        end;
        goodstart = gapt(min(bad(n)+1,length(gapt)));
    end;
end
    % get the cw and acw components....
    
    Gxx=W1.*Gxx./count./fs;
    Gyy=W1.*Gyy./count./fs;
    Gxy=W1.*Gxy./count./fs;
    Cxy=2.*W1.*Cxy./count./fs;
    Qxy=2.*W1.*Qxy./count./fs;
    Gxx(1:nfft/2)=Gxx(2:nfft/2+1);
    Gyy(1:nfft/2)=Gyy(2:nfft/2+1);
    Gxy(1:nfft/2)=Gxy(2:nfft/2+1);
    Cxy(1:nfft/2)=Cxy(2:nfft/2+1);
    Qxy(1:nfft/2)=Qxy(2:nfft/2+1);
    
    f=linspace(fs/nfft,fs/2,nfft/2)';
    
    indx=find(Gxx==0);
    if length(indx)==nfft
        Gxx(1:end)=NaN;
    end
    indy=find(Gyy==0);
    if length(indy)==nfft
        Gyy(1:end)=NaN;
    end
    if (length(indx)==nfft|length(indy)==nfft)
        Gxy(1:end)=NaN;
        Cxy(1:end)=NaN;
        Qxy(1:end)=NaN;
    end
    
    spec.Gxx=Gxx;
    spec.Gyy=Gyy;
    spec.Gxy=Gxy;
    spec.Cxy=Cxy;
    spec.Qxy=Qxy;
    
    out.Gxx=Gxx(1:nfft/2);
    out.Gyy=Gyy(1:nfft/2);
    out.Gxy=sqrt(Cxy(1:nfft/2).^2+Qxy(1:nfft/2).^2);
    out.CW=.5.*(Gxx(1:nfft/2)+Gyy(1:nfft/2)+Qxy(1:nfft/2));
    out.CCW=.5.*(Gxx(1:nfft/2)+Gyy(1:nfft/2)-Qxy(1:nfft/2));
    n=2.*lencount./nfft;
    
    
    



  
