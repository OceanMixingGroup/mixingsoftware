function [out,fx,fy,spec]=psd2d_rotary(in,hsf,vsf)
%[out,fx,fy,spec]=psd2d_rotary(in,hsf,vsf)
%
%2 dimensional rotary power spectrum program:
%Input your signal and the horizontal and vertical sampling frequencies,
%using the normal matlab convention of in(vert,horiz).  The input file
%should have no NaNs or Infs in it, or you will get arrays of NaNs back for
%your trouble.  Use whatever fill routine you think is best to pad bad
%data.  
%The psd can only be performed on data structures that are even in both
%directions: if the input file is odd in either or both direction,
%columns/rows will be truncated as neccesary.  
%Data is multiplied by a 2d-hanning window, and the 2dfft is computed on
%the real, imaginary, and complex signal.
%outputs: 
%fx and fy are the frequencies in the x and y directions
%spec is a structure containing the PSD estimates Gxx, Gxy, and Gyy, along
%with rotary 1/2(Gxx+Gyy)+Qxy, in which each quadrent is the PSD of each
%rotary component.
%out is a structure in which the total PSD powers of Gxx, Gxy, and Gyy are
%given (in one quadrant form) along with the PSD power spectra of each
%quadrant.  
%Given a signal IN(x,y)
%Quadrant 1: includes power from signals rotating CCW in x and CCW in y
%Quadrant 2: includes power from signals rotating CW in x and CCW in y
%Qudarant 3: includes power from signals rotating CW in x and CW in y
%Quadrant 4: includes power from signals rotating CCW in x and CW in y
%CW=clockwise
%CCW=counterclockwise
%use these quadrants and the dimensional structure of your input file to
%determine which quadrant means what for your signal.
%
%-Greg A., Dec 2004
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $



%find dimensions of input structure, truncate odd row if size is odd
[Lv,Lh]=size(in);
if (Lv./2~=floor(Lv./2))
    in=in(1:end-1,:);
end
if (Lh./2~=floor(Lh./2))
    in=in(:,1:end-1);
end
[Lv,Lh]=size(in);

%build hanning window
hann(1:Lv,1:Lh)=1;
for n=1:Lv;
    hann(n,:)=hann(n,:).*hanning(Lh)';
end
for n=1:Lh
    hann(:,n)=hann(:,n).*hanning(Lv);
end

%this is the correct normalization for the PSD given the hanning window
% W1=4./sum(sum(hann)).^2.*125.^2;
W1=4./norm(hann).^4;



%perform a 2d fft on signal and shift data so that low frequency is in the
%center
X=fftshift(fft2(real(in)));
Y=fftshift(fft2(imag(in)));
Z=fftshift(fft2(in));

%compute the frequencies of the fft
fx=flipud(linspace(hsf/Lh,hsf/2,Lh/2)');
fx(Lh./2+1:Lh)=flipud(fx);

fy=flipud(linspace(vsf/Lv,vsf/2,Lv/2)');
fy(Lv./2+1:Lv)=flipud(fy);


%compute power spectra
Gxx=(X.*conj(X)).*W1./hsf./vsf;
Gyy=(Y.*conj(Y)).*W1./hsf./vsf;
Gxy=(Z.*conj(Z)).*W1./hsf./vsf;
Qxy=(real(X).*imag(Y)-imag(X).*real(Y))*W1./hsf./vsf;

%output full spectra
spec.rotary=.5.*(Gxx+Gyy)+Qxy;
spec.Gxx=Gxx;
spec.Gyy=Gyy;
spec.Gxy=Gxy;

%truncate spectra to single quadrant spectra
fx=fx(1:end./2);
fy=fy(1:end./2);
out.Gxx=(Gxx(1:Lv./2,1:Lh./2)+Gxx(1:Lv./2,Lh:-1:Lh./2+1)+Gxx(Lv:-1:Lv./2+1,Lh:-1:Lh./2+1)+Gxx(Lv:-1:Lv./2+1,1:Lh./2));
out.Gyy=(Gyy(1:Lv./2,1:Lh./2)+Gyy(1:Lv./2,Lh:-1:Lh./2+1)+Gyy(Lv:-1:Lv./2+1,Lh:-1:Lh./2+1)+Gyy(Lv:-1:Lv./2+1,1:Lh./2));
out.Gxy=(Gxy(1:Lv./2,1:Lh./2)+Gxy(1:Lv./2,Lh:-1:Lh./2+1)+Gxy(Lv:-1:Lv./2+1,Lh:-1:Lh./2+1)+Gxy(Lv:-1:Lv./2+1,1:Lh./2));
out.Quad1=spec.rotary(Lv:-1:Lv./2+1,Lh:-1:Lh./2+1);
out.Quad2=spec.rotary(Lv:-1:Lv./2+1,1:Lh./2);
out.Quad3=spec.rotary(1:Lv./2,1:Lh./2);
out.Quad4=spec.rotary(1:Lv./2,Lh:-1:Lh./2+1);

%wasn't that simple? 

  
