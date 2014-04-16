function[sp,k1]= nasmyth(n,shrink);
% [sp,k1]= nasmyth(n,shrink);
% program to evaluate the spectral coefficients according to
% Oakey's spline fit to the G2 form of the empirical Nasmyth spectrum 
% sp gives the spectral values at frequencies k1.  n equally spaced spectral
% values are  given up to a maximum of  (k/ks)=2pi/shrink

% where:
%       n is the number of spectral estimates you want back (it is optional,
%       th)
%       k1: k/ks, where k is the cyclic waveno., ks is Kolm. waveno [rad/m]
%       [k1]=rad^-1
%       sp: non-dimensional spectrum form G2(k/ks)
%
%               these 2 variables can now be scaled to dimensional
%               quantities ug
%              eps, nu
%       ref: Moum, May 1996

if nargin<1
  n=1000;
  shrink=1;
end

ii=(1/n/shrink):(1/n/shrink):1/shrink;
k1=2*pi*ii'; %[rad^-1]
alpha=58.8276*k1;
a1=alpha.^4 - 45*alpha.^2 + 105;
a2=-10*alpha.^2. + 105;

sp=855.17*(k1.^0.333)./sqrt(a1.^2. + (alpha.^2).*(a2.^2)) ;% [rad^-2]  

return

	