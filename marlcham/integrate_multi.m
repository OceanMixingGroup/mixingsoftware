function [int_multi]=integrate_multi(range,freqs,spec,flg)
% function integrate_multi(range,freqs,spec) integrates the power
% spectrum SPEC between the limits range(1) and range(2), and adds
% this to the power spectrum, integrated between range(3) and
% range(4), and ... until we run out of the ranges...
% freqs and spec are both column vectors.
% NOTE: may be used to integrate any function spec(freqs)
% 
% The form:
% [...]=integrate_multi(...,'inclusive') may be used to include the freqs
% that fall on the ends of the ranges.

if nargin==3
  flg='exclusive';
end

n=length(range)/2; % this is the number of distinct integrations to perform
	   

if (round(n)-n)
  int_multi=NaN; % we have the wrong number of inputs
  warning('OSUmix:integrate_multi:WrongInputs','Wrong number of inputs to integrate_multi.m')
  return
elseif ~n
  int_multi=NaN; % No ranges.
  warning('OSUmix:integrate_multi:NoRange','No ranges specified to integrate_multi.m!')
%  keyboard
  return
else
  for ii=1:n
    fmin=range(ii*2-1);
    fmax=range(ii*2);
    region(ii)=integrate(fmin,fmax,freqs,spec,flg);
  end  
  int_multi=nansum(region);
end


