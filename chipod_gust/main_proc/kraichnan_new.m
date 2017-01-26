function [spec_vals]=kraichnan_new(nu,k,kb,D,chi,qq)
% [spec_vals]=batch(nu,k,kb,D,chi,q)
% B_SPEC determines the Kraichnan Spectra at a given wavenumber k
% this requires chi, kb (the batchelor wavenumber) and the diffusivity D.
% q could be set to 2.42
% q=2.42;
% but instead I have it at q=3.7
% C_star is from Dillon and Caldwell 1980 0.024 \pm 0.008
%
% optimized by Johannes at 23 Jan 2017

%warning off
if nargin~=6
%   q=5.3; was used as default untill 2012, but calc_chi explicitly calls
%   with q=7 since 2008
  q=7;
else
  q=qq;
end
test=size(k,2);
if test==1
  k=k';
end
% C-star=0.024
% C_star=0.032;% 0.024
C_star=0.01366;  % Aurelie says this is the correct value
% The value of c*=0.04 is consistent with C_theta=0.4 and q=3.7, which is
% what I have been using....
k_cut=C_star*kb*sqrt(D/nu);
epsil=(2*pi*kb)^4*nu*D^2;
a=find(k<k_cut, 1,'last');
if isempty(a)
  a=0;
end
b=length(k);
const=(2*pi)^2*q*chi*sqrt(nu/epsil);
k_tmp =  [k_cut k(a+1:b)];
C2 = -sqrt(6*q);
spec_vals2=const.*k_tmp.*exp(C2*k_tmp/kb);
%vv=(5/q)*sqrt(epsil/nu);
%squig=sqrt(30.*D./vv).*[k_cut k(a+1:b)];
%spec_vals2=2*pi*5.*chi./vv.*[k_cut k(a+1:b)].*(1+squig).*exp(-squig);
spec_vals1=spec_vals2(1)*(k(1:a)/k_cut).^(1/3);
spec_vals=[spec_vals1 spec_vals2(2:b-a+1)];
if test==1
  spec_vals=spec_vals';
end
