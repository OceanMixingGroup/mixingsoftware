function [epsilon_real,k,spec,k_nas,spec_nas]=calc_epsilon_filt_gen(s1,fallspd,nfft,nu,head_index_num,filters,k_start,k_stop,kstop_coef)
%CALC_EPSILON calculates epsilon from shear data.  
% function CALC_EPSILON(S1,FSPD,NFFT,NU,SENSOR_INDEX,FILTERS) calculates epsilon
% from shear data.  S1 and FSPD are required; NFFT, NU and SENSOR_INDEX are
% optional and default to 256, 1.2e-6 and  head.sensor_index.S1
% the output arguments are [EPSILON, K, SPEC, K_NAS, SPEC_NAS] where 
% K and SPEC are the wavenumber and power of the shear spectra, and 
% K_NAS and SPEC_NAS are the values of the universal Nasmyth spectra.
% All of the spectral outputs are optional.
%
% Optional argument FILTERS uses the specified filter spectrally
% (ie., with ideal filter properties) on both the data series and
% on the universal form.  It is better to filter S1 and S2 in this
% way as compared to filtering in the time domain, because variance
% is properly conserved using this routine when calculating
% EPSILON.
%  
% If the cell argument FILTERS is included, all preceding inputs must
% be included.  FILTERS is a string or cell like {'n20-22','l40'}
% FILTERS could be set equal to empty cell argument: {}.
% See CALIBRATE for filter details.
% No real fiters are applied!!! Selected frequencies are simply excluded 
% from the range on which universal spectra is fitted to shear spectra. 
% NOTE: FILTERS frequencies must be in [Hz] and in ascending order!!!! 
%
% K_START defines low frequency cutoff for fitting universal spectra
% to real shear spectra, input in [cpm]!! Default value 2 cpm.
% K_STOP*KSTOP_COEF defines maximum high frequency cutoff for fitting
% universal spectra to real shear spectra, input in [cpm]!!
% If maximum wavenumber KS for calculated EPSILON_REAL < K_STOP, 
% then KS*KSTOP_COEF defines high frequency cutoff for fitting
% universal spectra to real shear spectra.
% Arguments K_START, K_STOP and KSTOP_COEF are also optional, but if 
% K_START is used, all preceding to K_START inputs must be included, 
% if K_STOP is used, all preceding to K_STOP inputs must be included, etc.
% Default values: K_START=2 [cpm], K_STOP=90 [cpm], KSTOP_COEF=0.5

if any(isnan(s1)) || any(isinf(s1))
  epsilon_real=NaN;
  fre=NaN;
  sss=NaN;
  unfreq=NaN;
  unspec=NaN;
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

% The following sets up the values of cutfreq1 and cutfreq2, which
% are the bounds on any spectral filter which will be applied to
% the data and universal spectrum. 
if nargin<6
  filters={};
end
if nargin<7
   kstop_coef=0.5;
end
if nargin<7
   k_start=2;
end
if nargin<8
   k_stop=90;
end
if nargin<9
   kstop_coef=0.5;
end
  if ~iscell(filters);, filters=cellstr(filters);  end
  nfilts=length(filters);
  for j=1:nfilts
    filts=lower(char(filters(j)));
    type=filts(1);
    if type=='l'
      % LOWPASS
      cutfreq(j*2-1)=str2num(filts(2:length(filts)));
      cutfreq(j*2)=Inf;
    elseif type=='h'
      % HIGHPASS
      cutfreq(j*2-1)=0;
      cutfreq(j*2)=str2num(filts(2:length(filts)));
    elseif type=='n'
      % NOTCH
      position=find(filts=='-');
      cutfreq(j*2-1)=str2num(filts(2:(position-1)));
      cutfreq(j*2)=str2num(filts((position+1):length(filts)));
    end
  end
irep_s1=head.modulas(head_index_num);
fcutoff=head.filter_freq(head_index_num);
[f2,kks]=nasmyth(1000,20);

% first perform the power spectral density calculation
[s1_power, fre]=fast_psd(s1,nfft,slow_sample_rate*irep_s1);
% the following is the filter cutoff for marlin, but is different for 
% calculate epsilon(s1)
  k_end = 10;
  f_start= k_start * fspd;
  if f_start<fre(1); f_start=fre(1); end
  f_stop = max(2,k_end * fspd);
  irange=select_int_range(f_start,f_stop,cutfreq);
  sss=invert_filt(fre,spa_cor(s1_power,fre,fspd),filt_ord,fcutoff);
%  sss=s1_power;
%  loglog(fre,sss,'r');
%  hold on
  % first calculate the integral of our real data.	  
  epsilon_unv=0;
  epsilon=7.5*nu*integrate_multi(irange,fre,sss);
  % make a first guess of the real epsilon...
  epsilon_real=epsilon;
  %  Do the following until our desired precision is reached:
  iii=0;
  while (abs(epsilon_unv/epsilon-1)>.01 & ~isnan(epsilon))
     [unfreq,unspec]=unv_spec(epsilon_real,nu,kks,f2,fspd);
  %   loglog(unfreq,unspec)
    epsilon_real=7.5*nu*integrate(unfreq(1),unfreq(length(unfreq)),unfreq,unspec);
    ks = ((epsilon_real/(nu^3))^.25 )/2/pi;
    if (ks>k_stop)
      k_end = k_stop*kstop_coef;
    elseif ((kstop_coef * ks) < 10 )
      k_end = 10;
    else 
      k_end = kstop_coef * ks;
    end 
    f_stop = k_end * fspd;
    irange=select_int_range(f_start,f_stop,cutfreq);
    epsilon=7.5*nu*integrate_multi(irange,fre,sss);
    % compute epsilon for the universal spectrum based on the limits above.
    epsilon_unv=7.5*nu*integrate_multi(irange,unfreq,unspec);
    epsilon_real=epsilon_real*epsilon/epsilon_unv;
     iii=iii+1;
     if iii==200
         break;
     end
  end
  if nargout>1
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
  end


function   therange=select_int_range(f_start,f_stop,cutfreq)
therange=[f_start cutfreq f_stop];
therange=therange(find(therange<=f_stop)); 
if rem(length(therange),2)
  therange=therange(1:end-1);
end
therange=therange(find(therange>=f_start)); 
if rem(length(therange),2)
  therange=therange(2:end);
end
%therange


