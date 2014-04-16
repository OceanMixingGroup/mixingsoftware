function [B,b2,D1,D2,f]=gappy_bispectra(a,b,c,nfft,fs,maxgap);
%
%Function computes the bispectrum of input time series a, b, c.  The
%autobispectrum is calculated by simply making a, b, and c the same time
%series.  nfft is the length of the transform to be used, fs is the sample
%frequency, and maxgap is the maximum length of gaps to be interpolated
%over.
%Data is partioned such that the ensemble averaging skips large gaps.  For
%an unbroken time series of length L, with a fft length of size L./n, then
%2n-1 ffts will be performed.
%Output data is the Bispectrum, B, the bicoherence, b2, and the
%normalizations, D1 and D2.  
%For more information on bispectra and biocoherence, see Kim and Powers,
%1979, in IEE Translations on Plasma Science. 
%Program written by Greg Avicola, 2005, based upon the earlier series of
%programs gappy_psd and gappy_rotary.

% trim bad data off the front and back....

findgap=a+b+c;

start = min(find(~isnan(findgap)));
stop = max(find(~isnan(findgap)));
a=a(start:stop);
b=b(start:stop);
c=c(start:stop);

t=1:length(a);
good =find(~isnan(a));
gapa = a(good);
gapb = b(good);
gapc = c(good);
gapt=t(good);
% interpolate across the gaps....
a = interp1(gapt,gapa,t);
b = interp1(gapt,gapb,t);
c = interp1(gapt,gapc,t);

% now find biggaps
dt = diff(gapt);
bad = [find(dt>maxgap) length(gapt)];
goodstart = 1;

% Other pre-FFT details:


f = NaN;
fftd=[];

fx=linspace(fs/nfft,fs/2,nfft/2)';

f=[-fx' fx'];f=sort(f);

wind=hanning(nfft)';
%wind=1.*ones(1,nfft);
W1=2/norm(wind)^2 ;
count=0;

% Using good blocks of data, compute bispectra and
% then average results

B(1:nfft,1:nfft)=0;
D1(1:nfft,1:nfft)=0;
D2(1:nfft,1:nfft)=0;
diaga(1:nfft,1:nfft)=0;
diagb(1:nfft,1:nfft)=0;
diagc(1:nfft,1:nfft)=0;

diaga=1:nfft;diaga=repmat(diaga,nfft,1);
diagb=[1:nfft]';diagb=repmat(diagb,1,nfft);

% for ni=1:nfft
%     diagc(:,ni)=interp1(f,1:nfft,f(diaga(:,ni))+f(diagb(:,ni)));
% end

diagc=interp1(f,1:nfft,f(diaga)+f(diagb));

 
 ind=find(isnan(diagc));
 diagc(ind)=1;diagc=round(diagc);
 
for n=1:length(bad)
    goodint = goodstart:gapt(bad(n));
    len = length(goodint);
    if len>=nfft
 
              
        adat = a(1,goodint);
        bdat = b(1,goodint);
        cdat = c(1,goodint);
        
        repeats=fix(2*length(adat)/nfft);
        
        
        if length(adat)==nfft
            repeats=1;
        end
        
        FA=fft(detrend(real(adat(1:nfft)),0).*wind)';FA=fftshift(FA);
        FB=fft(detrend(real(bdat(1:nfft)),0).*wind)';FB=fftshift(FB);
        FC=fft(detrend(real(cdat(1:nfft)),0).*wind)';FC=fftshift(FC);
        
  %      [angle(FA(142)) angle(FB(164)) angle(FC(176)) exp(i.*(angle(FA(142))+angle(FB(164))-angle(FC(176))))]
        
                    
        FA=FA(diaga);
        FB=FB(diagb);
        FC(1,1)=NaN;
        FC=FC(diagc);
        
              
        FAm=abs(FA);FAp=angle(FA);
        FBm=abs(FB);FBp=angle(FB);
        FCm=abs(FC);FCp=angle(FC);
                
        B=B+FAm.*FBm.*FCm.*exp(i.*(FAp+FBp-FCp));
        D1=D1+abs(FAm.*FBm).^2;
        D2=D2+abs(FC).^2;
        
        count=count+1
        if (repeats-1)
            step=fix((length(adat)-nfft)/(repeats-1));
            
            for m=step:step:(length(adat)-nfft);
               
                FA=fft(detrend(real(adat(m:(m+nfft-1))),0).*wind)';FA=fftshift(FA);
                FB=fft(detrend(real(bdat(m:(m+nfft-1))),0).*wind)';FB=fftshift(FB);
                FC=fft(detrend(real(cdat(m:(m+nfft-1))),0).*wind)';FC=fftshift(FC);
                                
%                [angle(FA(142)) angle(FB(164)) angle(FC(176)) exp(i.*(angle(FA(142))+angle(FB(164))-angle(FC(176))))]
               
                FA=FA(diaga);
                FB=FB(diagb);
                FC(1,1)=NaN;
                FC=FC(diagc);
        
                FAm=abs(FA);FAp=angle(FA);
                FBm=abs(FB);FBp=angle(FB);
                FCm=abs(FC);FCp=angle(FC);
                
                B=B+FAm.*FBm.*FCm.*exp(i.*(FAp+FBp-FCp));
                D1=D1+abs(FAm.*FBm).^2;
                D2=D2+abs(FC).^2;
                
                count=count+1
            end
        end
        
        goodstart = gapt(min(bad(n)+1,length(gapt)));
     
    end
end
                
b2=abs(B).^2./D1./D2;

B=W1.*B./fs./count;
