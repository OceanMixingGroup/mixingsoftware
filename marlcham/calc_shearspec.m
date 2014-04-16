function [fre,ss,ssraw]=calc_shearspec(S,samprate,nfft,fallspd,filtord,fcutoff);
% function [f,ss]=calc_shearspec(S,samprate,nfft,fallspd,filtord,fcutoff);
%
% Calculates the "raw" shear spectrum, correcting for the
% anti-aliasing butterworth filter and the spatial resolution of
% the probes.
% S        is the shear signal in s^-1 (??)
% samprate is the sampling rate in Hz.
% nfft     is the length of fft to compute.
% fallspd  is the instrument fallspeed in m/s.
% filtord  is the filter order (i.e. 4).  
% fcutoff  is the butterworth filter cutoff in Hz.
%
% f        is frequency of the spectral bins (Hz).
% ss       is the shear spectrum in (s^-1)^2/Hz.
%
% see also FAST_PSD, INVERT_FILT, and FIT_EPSILON
  
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:46 $ $Author: aperlin $
  
% get the power spectrum
[ssraw,fre]=fast_psd(S,nfft,samprate);
% Correct for filters
ss=invert_filt(fre,spa_cor(ssraw,fre,fallspd),filtord,fcutoff);

