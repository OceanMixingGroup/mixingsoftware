function [tnew] = combine_ttc(t,tp,Omc,Fs,doplot);
% function tnew = combine_ttc(t,tp,Omc,Fs);
% 
% Implements the pre-emphasis routine of Mudge and Lueck '94
% (Jtech).  t is a temperatures signal and tp is a temperature
% derivative signal in the same units divided by s.  Omc is the
% cross-over frequency in radians/s.  Fs is the sampling frequency in
% Hz.   
%
% It can also be called with a plotting option to see where the
% cross-over frequency Omc should be:
%  tnew = combine_ttc(t,tp,Omc,Fs,doplot);

% $Author: aperlin $ $Revision: 1.2 $ $Date%
% originally: jklymak  April 29, 2002

  alpha=1;
  if nargin<5
    doplot=0;
  end;
  [mm,nn] = size(t);
  [m,n] = size(tp);
  if mm>nn
    t=t';
  end;
  if m>n
    tp=tp';
  end;
Fn = Fs/2;
4*Fn/Omc;

a = 1./(4*Fn/Omc + 1);
b = 1-2*a;

% into Matlab filters...
aa=[1 -b];
bb = [a a];
% initial condition
% take the mean of the first Fn/Omc samples
nsamps = max(1,floor(Fn/Omc));
t(1:10);
nadded = 1000;
%nadded=0;
tdat = [t+alpha*tp/Omc];
Zi = mean(tdat(1));
tdat = [fliplr(tdat(1:nadded)) tdat];
tnew = filter(bb,aa,tdat,tdat(1));
tnew = tnew(nadded+1:end);
%tnew = tnew(10001:end);
if doplot
  nfft = min([length(t) 1024]);
  time = (1:length(t))/Fs;
  pold = matrix_cohere(time,t,tp,nfft,1000);
  pnew = matrix_cohere(time,t,tnew,nfft,1000);
  figure(1);clf;
  subplot(3,1,1);
  loglog(pold.f,pold.xx,pold.f,pold.yy,pold.f,pold.yy./(2*pi* ...
						  pold.f).^2,pold.f,pnew.yy);
  set(gca,'xlim',[min(pold.f) max(pold.f)]);
  set(gca,'ylim',[min(pold.yy./(2*pi*pold.f).^2) max(pold.yy)])
  a=axis;
  line([1 1]*Omc/2/pi,a(3:4),'linewidth',2);
  ylabel('\Phi[T] [(^oC)^2 Hz^{-1}]');
  legend('T','TP','TP/\omega^2','Tnew',3);  
  grid on;
  subplot(3,1,2);
  loglog(pold.f,pold.coh,pnew.f,pnew.coh);
  ylabel('COH');
  set(gca,'ylim',[1e-2 1.2]);
  grid on;
  set(gca,'xlim',[min(pold.f) max(pold.f)]);
  legend('T with Tp','T with Tnew',3);
  subplot(3,1,3);
  semilogx(pold.f,pold.pha,pnew.f,pnew.pha);
  ylabel('PAH [rad.]');
  set(gca,'ytick',[-1:0.5:1]*pi)
  grid on;
  set(gca,'xlim',[min(pold.f) max(pold.f)]);
  xlabel('F [Hz]');
  legend('T with Tp','T with Tnew',3);

  figure(2);clf;
  plot(time,detrend(t,0),time,detrend(tnew,0));
  xlabel('TIME [s]');
  ylabel('TEMP. [^oC]');
end;



