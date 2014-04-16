function[sp,kks]= nasmyth2(freq,fspd,epsilon,nu);
% [sp,kks]= nasmyth2(freq,fspd,epsilon,nu);
% program to evaluate the spectral coefficients according to
% Oakey's spline fit to the G2 form of the empirical Nasmyth spectrum 
% sp gives the spectral values at frequencies kks.  
% values are given corresponding to freq.

% where:
%       n is the number of spectral estimates you want back (it is optional,
%       th)
%       kks: k/ks, where k is radian waveno., ks is Kolmogoroff waveno.
%       sp: non-dimensional spectrum form G2(k/ks)
%               these 2 variables can now be scaled to dimensional
%               quantities ug
%              eps, nu
%       ref: Moum, May 1996
ks=(epsilon/(nu^3))^.25;
kks=freq/fspd/ks;

alpha=58.8276*kks;
a1=alpha.^4 - 45*alpha.^2 + 105;
a2=-10*alpha.^2. + 105;

sp=855.17*(kks.^0.333)./sqrt(a1.^2. + (alpha.^2).*(a2.^2)) ;    

return

	