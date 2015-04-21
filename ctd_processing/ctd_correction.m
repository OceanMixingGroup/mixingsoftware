function data = ctd_correction(data)

% Calculates and applies a correction to the 24Hz temperature data in
% the structure data. The correction aims to make temperature and 
% conductivity be in phase. The raw and corrected series of temperature, 
% conductivity, pressure, salinity, fluorescense, transmissivity and 
% dissolved oxygen are stored in a structure and output.
% 
% Robert Todd, 2006-12-5
% Updates:
%  2006-12-19 (Robert Todd): changed to use entire length of time series;
%                            changed to overwrite uncorrected series;
%                            remove some extra plotting/comparison; include
%                            trans, fl, oxygen in LP filter; change function
%                            name from salinity_correction to ctd_correction;
%                            output structure instead of saving to .mat file

figures = 0; % 0 for no figures, 1 for figures

% remove spikes
ib=find(abs(diff(data.t1))>.5); data.t1(ib)=NaN;
ib=find(abs(diff(data.c1))>.5); data.c1(ib)=NaN;
ib=find(abs(diff(data.t2))>.5); data.t2(ib)=NaN;
ib=find(abs(diff(data.c2))>.5); data.c2(ib)=NaN;

% Spectral Analysis of Raw Data---------------------------------------------%
%disp('   ctd_correction: spectra')
dt = 1/24; % 24Hz data.
N = 2^9; % number of points per segment
i1 = find(data.p > 5,1,'first'); % Start when fish first below 5db
i2 = find(data.p > 5,1,'last'); % End when fish last below 5db
%ii=find(data.p>200&data.p<500); i1=ii(1); i2=ii(end);
n = i2-i1+1;
n = floor(n/N)*N;
i2 = i1+n-1; % Truncate to be multiple of N elements long
m = n/N; % number of segments = dof/2
%
% truncate 1 Hz time vector
%
%nt = length(data.time);
%it2 = floor(i2*dt);    % loss from truncation of CTD data to m segments
%it1 = floor(N/4*dt);         % and from truncation of CTD data ends by N/4
%it2 = it2 - it1;
%nt_new = it2 - it1 + 1;
%nctd_new = N*m - N/2;
%ndiff = nctd_new/24 - nt_new;
%if ndiff < 1.5 & ndiff >= 0.5
%  it2 = it2 + 1;
%elseif ndiff >= -1.5 & ndiff <= -0.5
%  it2 = it2 - 1;
%elseif ndiff < 2.5 & ndiff >= 1.5
%  it2 = it2 + 1;
%  it1 = it1 - 1;
%elseif ndiff >= -2.5 & ndiff < -1.5
%  it2 = it2 - 1;
%  it1 = it1 + 1;
%else
%  disp(['   ctd_correction: [nctd_new nt_new] = [' num2str(nctd_new) ' ' num2str(nt_new) '] '])
%end
%
dof = 2*m; % Number of degrees of freedom (power of 2)
df = 1/(N*dt); % Frequency resolution at dof degrees of freedom.
At1 = fft(detrend(reshape(data.t1(i1:i2),N,m)).*...% FFT of each column (segment)
  (window(@triang,N)*ones(1,m)));                  % Data are detrended then
At2 = fft(detrend(reshape(data.t2(i1:i2),N,m)).*...% windowed.
  (window(@triang,N)*ones(1,m))); 
Ac1 = fft(detrend(reshape(data.c1(i1:i2),N,m)).*...
  (window(@triang,N)*ones(1,m)));
Ac2 = fft(detrend(reshape(data.c2(i1:i2),N,m)).*...
  (window(@triang,N)*ones(1,m)));

At1 = At1(1:N/2,:); % Positive frequencies only
At2 = At2(1:N/2,:);
Ac1 = Ac1(1:N/2,:);
Ac2 = Ac2(1:N/2,:);

% Frequency 
f = ifftshift(linspace(-N/2,N/2-1,N)/(N)/dt); % +/- frequencies
f = f(:);
f = f(1:N/2); % Positive frequencies only

% Spectral Estimates
Et1 = 2*nanmean(At1.*conj(At1)/df/N^2,2);
Et2 = 2*nanmean(At2.*conj(At2)/df/N^2,2);
Ec1 = 2*nanmean(Ac1.*conj(Ac1)/df/N^2,2);
Ec2 = 2*nanmean(Ac2.*conj(Ac2)/df/N^2,2);

% Cross Spectral Estimates
Ct1c1 = 2*nanmean(At1.*conj(Ac1)/df/N^2,2);
Ct2c2 = 2*nanmean(At2.*conj(Ac2)/df/N^2,2);
Ct1c1 = 2*nanmean(At1.*conj(Ac1)/df/N^2,2);
Ct2c2 = 2*nanmean(At2.*conj(Ac2)/df/N^2,2);

% Squared Coherence Estimates
Coht1c1 = Ct1c1.*conj(Ct1c1)./(Et1.*Ec1);
Coht2c2 = Ct2c2.*conj(Ct2c2)./(Et2.*Ec2);
%epsCoht1c1 = sqrt(2)*(1-Coht1c1)./sqrt(Coht1c1)/sqrt(m); % 95% confidence bound
%epsCoht2c2 = sqrt(2)*(1-Coht2c2)./sqrt(Coht1c1)/sqrt(m);
%beta = 1-.05^(1/(m-1)); % 95% significance level for coherence from Gille notes

% Cross-spectral Phase Estimates
Phit1c1 = atan2(imag(Ct1c1),real(Ct1c1));
Phit2c2 = atan2(imag(Ct2c2),real(Ct2c2));
%epsPhit1c1 = asin(tinv(.05,dof)*sqrt((1-Coht1c1)./(dof*Coht1c1))); % 95% error bound
%epsPhit2c2 = asin(tinv(.05,dof)*sqrt((1-Coht2c2)./(dof*Coht2c2)));

% Determine tau and L--------------------------------------------------%
% tau is the thermistor time constant (sec), and 
% L is the lag of t behind c due to sensor separation (sec)
%
%disp('   ctd_correction: finding tau, L')
W1 = diag(Coht1c1); % Matrix of weights based on squared coherence.
W2 = diag(Coht2c2);
[x1 fval1] = fminsearch(@atanfit,[0 0],[],f,Phit1c1,W1); % Nonlinear fit
[x2 fval2] = fminsearch(@atanfit,[0 0],[],f,Phit2c2,W2);
tau1 = x1(1);
tau2 = x2(1);
L1 = x1(2);
L2 = x2(2);
%tau1=0.017926; L1=-0.0029106;
%tau1= 0.0033797; L1=0.015266;
%tau1=0.026338; L1=-0.0064903;
%tau1=0.0076908; L1= 0.0073246;
data.tau1=tau; data.tau2=tau; data.L1=L1; data.L2=L2;

disp(['1: tau = ' num2str(tau1) ', lag = ' num2str(L1) ' s'])
disp(['2: tau = ' num2str(tau2) ', lag = ' num2str(L2) ' s'])

% Plots of Spectral Quantities for Uncorrected Data--------------------%

if figures
  % Temperature Spectra
  fig1 = figure;
  subplot(211)
  semilogy(f,Et1,'b',f,Et2,'r')
  hold on
  semilogy([f(50) f(50)],[dof*Et1(100)/chi2inv(.05/2,dof) dof*Et1(100)/chi2inv(1-.05/2,dof)],'k')
  xlabel('Frequency (Hz)')
  ylabel('Spectral Density (^{\circ}C^2/Hz)')
  legend('1','2')

  % Conductivity Spectra
  fig2 = figure;
  subplot(211)
  semilogy(f,Ec1,'b',f,Ec2,'r')
  hold on
  semilogy([f(50) f(50)],[dof*Ec1(100)/chi2inv(.05/2,dof) dof*Ec1(100)/chi2inv(1-.05/2,dof)],'k')
  xlabel('Frequency (Hz)')
  ylabel('Spectral Density (mmho^2/cm^2/Hz)')
  legend('1','2')

  % Coherence between Temperature and Conductivity
  fig3 = figure;
  subplot(211)
  plot(f,Coht1c1,'b')
  hold on
  plot(f,Coht2c2,'r')
  legend('1','2')
  %plot(f,Coht1c1./(1+2*epsCoht1c1),'b:')
  %plot(f,Coht1c1./(1-2*epsCoht1c1),'b:')
  %plot(f,Coht2c2./(1+2*epsCoht2c2),'r:')
  %plot(f,Coht2c2./(1-2*epsCoht2c2),'r:')
  %plot(f,beta*ones(size(f)),'k--')
  xlabel('Frequency (Hz)')
  ylabel('Squared Coherence')

  % Phase between Temperature and Conductivity
  fig4 = figure;
  subplot(211)
  plot(f,Phit1c1,'b')
  hold on
  plot(f,Phit2c2,'r')
  legend('1','2')
  %plot(f,Phit1c1./(1+2*epsPhit1c1),'b:')
  %plot(f,Phit1c1./(1-2*epsPhit1c1),'b:')
  %plot(f,Phit2c2./(1+2*epsPhit2c2),'r:')
  %plot(f,Phit2c2./(1-2*epsPhit2c2),'r:')
  xlabel('Frequency (Hz)')
  ylabel('Phase (rad)')
  plot(f,-atan(2*pi*f*x1(1))-2*pi*f*x1(2),'g--')
  plot(f,-atan(2*pi*f*x2(1))-2*pi*f*x2(2),'g--')
  drawnow
end

% Apply Phase Correction and LP Filter----------------------------------------%
%disp('   ctd_correction: corrected data')

% Transfer function
f = ifftshift(linspace(-N/2,N/2-1,N)/(N)/dt); % +/- frequencies
f = f(:);
H1 = (1+i*2*pi*f*tau1).*exp(i*2*pi*f*L1);
H2 = (1+i*2*pi*f*tau2).*exp(i*2*pi*f*L2);

% Low Pass Filter
f0 = 4; % Cutoff frequency


LP = 1./(1+(f/f0).^6);

% Restructure data with overlapping segments.

% Staggered segments
clear t1 t2 c1 c2 s1 s2 p
t1(:,1:2:2*m-1) = reshape(data.t1(i1:i2),N,m);
t2(:,1:2:2*m-1) = reshape(data.t2(i1:i2),N,m);
c1(:,1:2:2*m-1) = reshape(data.c1(i1:i2),N,m);
c2(:,1:2:2*m-1) = reshape(data.c2(i1:i2),N,m);
p(:,1:2:2*m-1) = reshape(data.p(i1:i2),N,m);
trans(:,1:2:2*m-1) = reshape(data.trans(i1:i2),N,m);
fl(:,1:2:2*m-1) = reshape(data.fl(i1:i2),N,m);
oxygen(:,1:2:2*m-1) = reshape(data.oxygen(i1:i2),N,m);
% 24 Hz time, lon, lat
time = data.time(i1:i2); 
lon = data.lon(i1:i2);
lat = data.lat(i1:i2);

t1(:,2:2:end) = reshape(data.t1(i1+N/2:i2-N/2),N,m-1);
t2(:,2:2:end) = reshape(data.t2(i1+N/2:i2-N/2),N,m-1);
c1(:,2:2:end) = reshape(data.c1(i1+N/2:i2-N/2),N,m-1);
c2(:,2:2:end) = reshape(data.c2(i1+N/2:i2-N/2),N,m-1);
p(:,2:2:end) = reshape(data.p(i1+N/2:i2-N/2),N,m-1);
trans(:,2:2:end) = reshape(data.trans(i1+N/2:i2-N/2),N,m-1);
fl(:,2:2:end) = reshape(data.fl(i1+N/2:i2-N/2),N,m-1);
oxygen(:,2:2:end) = reshape(data.oxygen(i1+N/2:i2-N/2),N,m-1);

% FFTs of staggered segments
%disp('   ctd_correction: corrected spectra')
At1 = fft(t1); % FFT of each column (segment)
At2 = fft(t2);
Ac1 = fft(c1);
Ac2 = fft(c2);
Ap = fft(p);
Atrans = fft(trans);
Afl = fft(fl);
Aoxygen = fft(oxygen);

% Corrected Fourier transforms of temperature.
%disp('   ctd_correction: lag, filter')
At1 = At1.*((H1.*LP)*ones(1,2*m-1));
At2 = At2.*((H2.*LP)*ones(1,2*m-1));

% LP filter pressure and conductivity.
Ac1 = Ac1.*(LP*ones(1,2*m-1));
Ac2 = Ac2.*(LP*ones(1,2*m-1));
Ap = Ap.*(LP*ones(1,2*m-1));
Atrans = Atrans.*(LP*ones(1,2*m-1));
Afl = Afl.*(LP*ones(1,2*m-1));
Aoxygen = Aoxygen.*(LP*ones(1,2*m-1));

% Inverse transforms of corrected temperature and low passed conductivity and pressure.
%disp('   ctd_correction: inverse fft')
t1 = real(ifft(At1)); % fft should be symmetric since it's for a real time series
t2 = real(ifft(At2)); % asymmetries result from roundoff
c1 = real(ifft(Ac1));
c2 = real(ifft(Ac2));
p = real(ifft(Ap));
trans = real(ifft(Atrans));
fl = real(ifft(Afl));
oxygen = real(ifft(Aoxygen));

% Take middle portion of segments and reconstruct time series.
%disp('   ctd_correction: time series')
t1 = reshape(t1(N/4+1:3*N/4,:),[],1);
t2 = reshape(t2(N/4+1:3*N/4,:),[],1);
p = reshape(p(N/4+1:3*N/4,:),[],1);
c1 = reshape(c1(N/4+1:3*N/4,:),[],1);
c2 = reshape(c2(N/4+1:3*N/4,:),[],1);
trans = reshape(trans(N/4+1:3*N/4,:),[],1);
fl = reshape(fl(N/4+1:3*N/4,:),[],1);
oxygen = reshape(oxygen(N/4+1:3*N/4,:),[],1);
% 24 Hz time, lon, lat
time = time(N/4 + 1:end - N/4,:); 
lon = lon(N/4 + 1:end - N/4,:);
lat = lat(N/4 + 1:end - N/4,:);

% Corrected Salinity
%s1 = sw_salt(10*c1/sw_c3515,t1,p); % Corrected salinities
%s2 = sw_salt(10*c2/sw_c3515,t2,p); % Multiply c by 10 based on allread.m

% Store corrected time series in structure for output-------------------------------%
%disp('   ctd_correction: make structure')
%data.time = data.time(it1:it2); % 1 Hz time
data.time = time; % 24 Hz time
data.lat = lat;
data.lon = lon;
data.t1 = t1;
data.t2 = t2;
data.p = p;
data.c1 = c1;
data.c2 = c2;
data.trans = trans;
data.fl = fl;
data.oxygen = oxygen;
%data.s1 = s1;
%data.s2 = s2;
data.tau1 = tau1;
data.tau2 = tau2;
data.L1 = L1;
data.L2 = L2;

% Recalculate and replot spectra, coherence and phase----------------------%
%disp('   ctd_correction: corrected fft')
t1 = t1(1+N/4:end-N/4); % Now N elements shorter
t2 = t2(1+N/4:end-N/4);
p = p(1+N/4:end-N/4);
c1 = c1(1+N/4:end-N/4);
c2 = c2(1+N/4:end-N/4);

m = (i2-N)/N; % number of segments = dof/2
dof = 2*m; % Number of degrees of freedom (power of 2)
df = 1/(N*dt); % Frequency resolution at dof degrees of freedom.
At1 = fft(detrend(reshape(t1,N,m)).*...% FFT of each column (segment)
  (window(@triang,N)*ones(1,m)));      % Data are detrended then
At2 = fft(detrend(reshape(t2,N,m)).*...% windowed.
  (window(@triang,N)*ones(1,m))); 
Ac1 = fft(detrend(reshape(c1,N,m)).*...
  (window(@triang,N)*ones(1,m)));
Ac2 = fft(detrend(reshape(c2,N,m)).*...
  (window(@triang,N)*ones(1,m)));
At1 = At1(1:N/2,:); % Positive frequencies only
At2 = At2(1:N/2,:);
Ac1 = Ac1(1:N/2,:);
Ac2 = Ac2(1:N/2,:);

f = f(1:N/2); % Positive frequencies only

% Spectral Estimates
%disp('   ctd_correction: corrected spectra')
Et1 = 2*nanmean(abs(At1(1:N/2,:)).^2,2)/df/N^2;
Et2 = 2*nanmean(abs(At2(1:N/2,:)).^2,2)/df/N^2;
Ec1 = 2*nanmean(abs(Ac1(1:N/2,:)).^2,2)/df/N^2;
Ec2 = 2*nanmean(abs(Ac2(1:N/2,:)).^2,2)/df/N^2;

% Cross Spectral Estimates
Ct1c1 = 2*nanmean(At1.*conj(Ac1)/df/N^2,2);
Ct2c2 = 2*nanmean(At2.*conj(Ac2)/df/N^2,2);

% Squared Coherence Estimates
Coht1c1 = Ct1c1.*conj(Ct1c1)./(Et1.*Ec1);
Coht2c2 = Ct2c2.*conj(Ct2c2)./(Et2.*Ec2);
%epsCoht1c1 = sqrt(2)*(1-Coht1c1)./sqrt(Coht1c1)/sqrt(m); % 95% confidence bound
%epsCoht2c2 = sqrt(2)*(1-Coht2c2)./sqrt(Coht1c1)/sqrt(m);
%beta = 1-.05^(1/(m-1)); % 95% significance level for coherence from Gille notes

% Cross-spectral Phase Estimates
Phit1c1 = atan2(imag(Ct1c1),real(Ct1c1));
Phit2c2 = atan2(imag(Ct2c2),real(Ct2c2));
%epsPhit1c1 = asin(tinv(.05,dof)*sqrt((1-Coht1c1)./(dof*Coht1c1))); % 95% error bound
%epsPhit2c2 = asin(tinv(.05,dof)*sqrt((1-Coht2c2)./(dof*Coht2c2)));

% Plots of Spectral Quantities for Corrected Data-----------------------------%

if figures
  % Temperature Spectra
  figure(fig1)
  subplot(212)
  semilogy(f(1:N/2,:),Et1,'b',f(1:N/2,:),Et2,'r')
  hold on
  semilogy([f(50) f(50)],[dof*Et1(100)/chi2inv(.05/2,dof) dof*Et1(100)/chi2inv(1-.05/2,dof)],'k')
  xlabel('Frequency (Hz)')
  ylabel('Spectral Density (^{\circ}C^2/Hz)')
  title('corrected')
  legend('1','2')

  % Conductivity Spectra
  figure(fig2)
  subplot(212)
  semilogy(f(1:N/2,:),Ec1,'b',f(1:N/2,:),Ec2,'r')
  hold on
  semilogy([f(50) f(50)],[dof*Ec1(100)/chi2inv(.05/2,dof) dof*Ec1(100)/chi2inv(1-.05/2,dof)],'k')
  xlabel('Frequency (Hz)')
  ylabel('Spectral Density (mmho^2/cm^2/100/Hz)')
  title('corrected')
  legend('1','2')

  % Coherence between Corrected Temperature and Conductivity
  figure(fig3)
  subplot(212)
  plot(f(1:N/2,:),Coht1c1,'b')
  hold on
  plot(f(1:N/2,:),Coht2c2,'r')
  legend('1','2')
  %plot(f(1:N/2,:),Coht1c1./(1+2*epsCoht1c1),'b:')
  %plot(f(1:N/2,:),Coht1c1./(1-2*epsCoht1c1),'b:')
  %plot(f(1:N/2,:),Coht2c2./(1+2*epsCoht2c2),'r:')
  %plot(f(1:N/2,:),Coht2c2./(1-2*epsCoht2c2),'r:')
  %plot(f(1:N/2,:),beta*ones(size(f(1:N/2,:))),'k--')
  set(gca,'YLim',[0 1])
  xlabel('Frequency (Hz)')
  ylabel('Squared Coherence')
  title('corrected')

  % Cross-Spectral Phase between Corrected Temperature and Conductivity
  figure(fig4)
  subplot(212)
  plot(f(1:N/2,:),Phit1c1,'b')
  hold on
  plot(f(1:N/2,:),Phit2c2,'r')
  legend('1','2')
  %plot(f(1:N/2,:),Phit1c1./(1+2*epsPhit1c1),'b:')
  %plot(f(1:N/2,:),Phit1c1./(1-2*epsPhit1c1),'b:')
  %plot(f(1:N/2,:),Phit2c2./(1+2*epsPhit2c2),'r:')
  %plot(f(1:N/2,:),Phit2c2./(1-2*epsPhit2c2),'r:')
  xlabel('Frequency (Hz)')
  ylabel('Phase (rad)')
  title('corrected')

  drawnow
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = atanfit(x,f,Phi,W)

f = (atan(2*pi*f*x(1))+2*pi*f*x(2)+Phi);
f = f'*W.^4*f; % mean square error to be minimized w.r.t tau,L
% weight by Coh^8 to emphasize low frequencies