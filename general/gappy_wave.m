function [f,wave,E,scale]=gappy_wave(in,sf,lowf,highf,bins);%function [f,wave,E,scale]=gappy_wave(in,sf,lowf,highf,bins);%%returns a m x n matrix (wave) which is the associated wavelet of the time%series in, where m is the length of the timeseries and n is the number%of wavelet steps performed.  The n x 1 array periods lists the periods for%which each wavelet step corresponds.%lowf is the lowest frequency you wish to be transformed.  Beware, making%this frequency too low lengthens the calculation greatly.%highf is the highest frequency you wish to be transformed.  Frequencies%higher than sf/2 are set to sf/2, the nyquest frequency of the time%series.%bins is the number of bins to be included between highf and lowf.%%f returns the frequency bins,%wave returns the wavelet matrix%E returns the energy in the wavelet scalogram%scale returns the wavelet scales that correspond to the frequencies given in f.%the wave matrix has not been altered from the matlab cwt function, but the wavelet Energy has been properly scaled by%N.*sf./2./pi, where N is the length of "in".  The average energy in E will%have the same functional form as a the properly normalized power spectral%density function.N=length(in);bad=find(isnan(in));good=find(~isnan(in));start=min(good);stop=max(good);gaps=diff(good);in=fillgap(in);ind=find(~isnan(in));avg=mean(in(ind));ind=find(isnan(in));in(ind)=avg;in=in-avg;bins=bins-1;%figure out scale factorF=scal2frq(1,'morl',1/sf);scale=F/sf;l=log2(sf/lowf);h=log2(sf/highf);if h<1    h=1;endstep=(l-h)/bins;int=2.^[h:step:l];%multiply by scaleint=int*scale;outy=cwt(in,int,'morl');freqs=scal2frq(int,'morl',1/sf);for n=1:length(freqs)    f=freqs(n);    maxinterp=floor(f/sf/4);    if maxinterp<1        maxinterp=1;    end    front=1:start+maxinterp;    back=stop-maxinterp:N;    outy(n,front)=NaN;    outy(n,back)=NaN;        ind=find(gaps>maxinterp);        for m=1:length(ind);        pos=start+sum(gaps(1:ind(m)-1));        outy(n,pos-maxinterp:pos+gaps(ind(m))+maxinterp)=NaN;    endend            E=(abs(outy.*conj(outy)+eps))';for n=1:length(freqs);                   f=freqs(n);    ff=sprintf('l%10f',f/2);    E(:,n)=gappy_filt(sf,ff,2,E(:,n),sf/f/2,1,0);endE=E';E=E.*N.*sf./2./pi;wave=outy;f=freqs;
 