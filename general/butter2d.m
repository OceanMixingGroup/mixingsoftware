function [out]=butter2d(in,vsf,hsf,vcut,hcut,order)
%[out]=butter2d(in,vsf,hsf,vcut,hcut,order)
%
%
%2-D butterworth filter coded by G. Avicola Feb 4, 2004
%>in should be an array of data - such as a time/space series of ADCP data
%>vsf is the vertical (first index) sampling frequency (or wavenumber) 
%>hsf is the horizontal (second index) sampling frequency (or wavenumber)
%>vcut is the vertical cutoff frequency (or wavenumber)
%>hcut is the horizontal cutoff frequency (or wavenumber)
%>order is the order of the butterworth filter
%
%vcut and hcut may be arrays - in which case each filter is calculated and then
%convoluted with the previous - in order to created bandpass and notch
%filters
%
%positive values of hcut indicate low pass filters, negative
%values indicate highpass filters - currently hcut and vcut must both be
%lowpass or highpass filters in pairs (to produce eliptical filter
%regions).  Thus negative values of vcut are ignored.  
%
%thus, hsf=[1/20 -1/1000] would indicate that the horizontal dimension
%should be low pass filtered with a cutoff wavelength of 20m, and high
%pass filtered with a cutoff wavelength of 1000m.  This produces a bandpass
%filter.  similarly, hsf=[-1/20 1/1000] would create a notch filter.  
%
%Gappy data is handled by first using a nearest neighbor interp (with
%griddata- and therefore slowly) to fill in bad points with estimates-
%Because nearest neighbor is used, this fills in bad data on the edges of
%the region as well as in the center.  Once the filtering has been applied,
%the bad data points are returned to NaN's.  
%
%the Base of this program was derived from:
%----------------------------------------
%Katie Streit   kstreit@rice.edu
% ELEC 301
% Rice University
%
% December 2001
%
% Much of this code was based on Peter Kovesi's  (pk@cs.uwa.edu.au)
% Matlab function for a lowpass Butterworth filter.
%---------------------------------------





[Lv,Lh]=size(in);

%pad NaNs so we can transform
ind=find(isnan(in));
bad=find(isnan(in));
good=find(~isnan(in));

if length(bad)~=0
    xi=[1:Lv];
    yi=[1:Lh];
    [xi,yi]=meshgrid(xi,yi);
    xi=xi';
    yi=yi';

    temp=griddata(xi(good),yi(good),in(good),xi(bad),yi(bad),'nearest');
    in(bad)=temp;
end

Lf=length(hcut);
if length(vcut)~=Lf
    return;
end

for n=1:Lf
    %perform a 2d fft on signal and shift data so that low frequency is in the
    %center
    infft = fftshift(fft2(in));
    f(1:Lh,1:Lv)=0;
    
    if hcut(n)<0
        temp=1;
    else
        temp=0;
    end
    
    hc=abs(hcut(n));
    vc=abs(vcut(n));
    
    x =  ((((ones(Lh,1) * [1:Lv]))  - (fix(Lv/2)+1))/Lv);
    y =  ((([1:Lh]' * ones(1,Lv))) - (fix(Lh/2)+1))/Lh;

    b = 2*hc/hsf;
    a = 2*vc/vsf;

    f = 1./(1+((x/(a)).^2 + (y/(b)).^2).^order);

    filtfft=infft.*f';
    
    tempout = (ifft2(ifftshift(filtfft)));
    
    if temp
        in=in-tempout;
    else
        in=tempout;
    end
end

out=in;

%perform the inverse fft

out(ind)=NaN;


  
