function [chi,k,spec,k_batch,spec_batch]= ...
   calc_chi(tp,fallspd,epsilon,nfft,nu,thermal_diff,head_index_num)
% function calc_chi(tp,fallspd,epsilon,nfft,nu,thermal_diff,head_index_num)
% program to calculate chi from tp data once we know epsilon.
% Optional output arguments are [chi,k,spec,k_batch,spec_batch]
% requires global head.


if any(isnan(tp))
  chi=NaN;
return
end
global head
% slow_sample_rate=head.samplerate/32; THIS IS NOT CORRECT FOR MARLIN DATA, but calculated
% head.slow_samp_rate in raw_load routine is correct, though it could be used directly
% and not calculate it again
slow_sample_rate=head.slow_samp_rate;
filt_ord=4;
fspd=.01*mean(fallspd);
if nargin==3
  nu=1.1898e-06;
  thermal_diff=1.5e-07;
  nfft=256;
  head_index_num=head.sensor_index.TP;
end
irep_tp=head.modulas(head_index_num);
fcutoff=head.filter_freq(head_index_num);
temp=deblank(head.sensor_id(head_index_num,:));
% The following are the cutoff frequencies for the the
% thermistor transfer function:
if strcmp(temp,'TC97')
   f_c=100;
elseif strcmp(temp,'TP2')
   f_c=20;
   fcutoff=40;
   filt_ord=2.3;
elseif strcmp(temp,'T_prime')
   f_c=14;
   fcutoff=40;
   filt_ord=1.7;
else
   f_c=1000;
   warning(['No frequency response corrections are applied to series ' ...
         temp])
end
  % first perform the power spectral density calculation
  [tp_power, fre]=fast_psd(tp,nfft,slow_sample_rate*irep_tp);
  ks = ((epsilon/(nu^3))^.25 )/2/pi;
  k_start = 1;
  kb=(ks*sqrt(nu/thermal_diff));
  k_end = kb/2;
  f_start= k_start * fspd;
  f_stop = k_end * fspd;
  if f_stop>40;
    f_stop=40;	
  end
  if f_start<fre(1)
    f_start=fre(1);
  end
%  fre=tp_freq';
  sss=invert_filt(fre,therm_resp(tp_power,fre,f_c),filt_ord,fcutoff);	
  chi_part= 6*thermal_diff* integrate(f_start,f_stop,fre,sss);
  chi=chi_part;
  if isnan(chi)
    chi=NaN;,k=NaN;,spec=NaN;,k_batch=NaN;,spec_batch=NaN;
    return
  end
  chi_test=chi_part*2;
  b_freq=(10.^(-2:.1:3.5))';
  while abs(chi_part/chi_test-1)>.01
     b_spec= kraichnan(nu,b_freq/fspd,kb,thermal_diff,chi)/fspd;
  %   [chi 6*thermal_diff*integrate(min(b_freq),max(b_freq),b_freq,b_spec)]
    chi_test=6*thermal_diff*integrate(f_start,f_stop,b_freq,b_spec);
    chi=chi*chi_part/chi_test;
  end
  chi=6*thermal_diff*integrate(f_start,kb*fspd,b_freq,b_spec);
  k_batch=b_freq/fspd;
  spec_batch=b_spec*fspd;
  k=fre/fspd;
  spec=tp_power*fspd;
  ll=length(k);
  spec(2:ll-1)=.25*(spec(1:ll-2)+2*spec(2:ll-1)+spec(3:ll));
%  temp=find(spec<20e-7)
%  k
%  paus
%  if temp
%     k((temp(1)+1):length(k))=NaN;
%  end
  spec=sss*fspd;
return
  
  
  
  
  
