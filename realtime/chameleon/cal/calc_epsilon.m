function [epsilon_real,k,spec,k_nas,spec_nas]=calc_epsilon(s1,fallspd,nfft,nu,head_index_num)
% function calc_epsilon(S1,FSPD,NFFT,NU,SENSOR_INDEX) calculates epsilon
% from shear data.  S1 and FSPD are required; NFFT, NU and SENSOR_INDEX are
% optional and default to 256, 1.2e-6 and  head.sensor_index.S1
% the output arguments are [EPSILON, K, SPEC, K_NAS, SPEC_NAS] where 
% K and SPEC are the wavenumber and power of the shear spectra, and 
% K_NAS and SPEC_NAS are the values of the universal Nasmyth spectra.
% All of the spectral outputs are optional.
% $Revision: 1.3 $ $Date: 2010/04/28 17:55:20 $ $Author: aperlin $

if any(isnan(s1)) || any(isinf(s1))
  epsilon_real=NaN;
  k=NaN;
  spec=NaN;
  k_nas=NaN;
  spec_nas=NaN;
  return
end
global head
% slow_sample_rate=head.samplerate/32; THIS IS NOT CORRECT FOR MARLIN DATA, but calculated
% head.slow_samp_rate in raw_load routine is correct, though it could be used directly
% and not calculate it again
slow_sample_rate=head.slow_samp_rate;
filt_ord=4;
fspd=.01*mean(fallspd);
if nargin==2
  nu=1.1898e-06;
  nfft=256;
  head_index_num=head.sensor_index.S1;
elseif nargin==3 
   nu=1.1898e-06;
  head_index_num=head.sensor_index.S1;
end
  irep_s1=head.modulas(head_index_num);
  fcutoff=head.filter_freq(head_index_num);
[f2,kks]=nasmyth(1000,20);
if isnan(nu)
    nu=1.1898e-06;
end
% first perform the power spectral density calculation
[s1_power, fre]=fast_psd(s1,nfft,slow_sample_rate*irep_s1);
% the following is the filter cutoff for marlin, but is different for 
% calculate epsilon(s1)
  k_start = 2;
  k_end = 10;
  f_start= k_start * fspd;
  f_stop = max(2,k_end * fspd);
  sss=invert_filt(fre,spa_cor(s1_power,fre,fspd),filt_ord,fcutoff);
  %sss=s1_power;
%  loglog(fre,sss,'r');
%  hold on
  % first calculate the integral of our real data.	  
  epsilon_unv=0;
  epsilon=7.5*nu*integrate(f_start,f_stop,fre,sss);
  % make a first guess of the real epsilon...
  epsilon_real=epsilon;
  %  Do the following until our desired precision is reached:
  while (abs(epsilon_unv/epsilon-1)>.01 & ~isnan(epsilon)) 
     [unfreq,unspec]=unv_spec(epsilon_real,nu,kks,f2,fspd);
  %   loglog(unfreq,unspec)
    epsilon_real=7.5*nu*integrate(unfreq(1),unfreq(length(unfreq)),unfreq,unspec);
    ks = ((epsilon_real/(nu^3))^.25 )/2/pi;
    if (ks>90)
      k_end = 45;
    elseif ((0.5 * ks) < 10 )
      k_end = 10;
    else 
      k_end = 0.5 * ks;
    end 
    f_stop = k_end * fspd;
    epsilon=7.5*nu*integrate(f_start,f_stop,fre,sss);
    % compute epsilon for the universal spectrum based on the limits above.
    epsilon_unv=7.5*nu*integrate(f_start,f_stop,unfreq,unspec);
    epsilon_real=epsilon_real*epsilon/epsilon_unv;
  end
  k=fre/fspd;
  spec=sss*fspd;
  if exist('unfreq','var')
      k_nas=unfreq/fspd;
  else
      k_nas=NaN;
  end
   if exist('unspec','var')
      spec_nas=unspec*fspd;
  else
      spec_nas=NaN;
  end

