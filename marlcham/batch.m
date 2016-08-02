function [spec_vals]=batch(nu,k,kb,D,chi,qq)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [spec_vals]=batch(nu,k,kb,D,chi,q)
%
% INPUT
%   nu :
%   k  : Wavenumber(s)
%   kb : Batchelor wavenumber
%   D  : Diffusivity
%   chi: \chi
%   qq : q (default = 3.7)
%
% OUTPUT
%   spec_vals : Values of spectra at wavenumber(s) k
%
% B_SPEC determines the Batchelor Spectra at a given wavenumber k
% this requires chi, kb (the batchelor wavenumber) and the diffusivity D.
% q could be set to 2.42
% q=2.42;
% but instead I have it at q=3.7
% C_star is from Dillon and Caldwell 1980 0.024 \pm 0.008
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if nargin~=6
    % q=10;
    % q=2;
    q=3.7;
else
    q=qq;
end
test=size(k,2);
if test==1
    k=k';
end
% C-star=0.024
C_star=0.04;
% The value of c*=0.04 is consistent with C_theta=0.4 and q=3.7, which is
% what I have been using....
k_cut=C_star*kb*sqrt(D/nu);
a=max(find(k<k_cut));
if length(a)==0
    a=0;
end
b=length(k);
alpha=sqrt(q*2)*[k_cut k(a+1:b)]/kb;
falpha=alpha.*(exp(-alpha.*alpha/2)-sqrt(2*pi)*alpha.*normcdf(-alpha));
spec_vals2=chi*sqrt(q/2)/D/kb*falpha;
spec_vals1=spec_vals2(1)*(k(1:a)/k_cut).^(1/3);
spec_vals=[spec_vals1 spec_vals2(2:b-a+1)];
if test==1
    spec_vals=spec_vals';
end
