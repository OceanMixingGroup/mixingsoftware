function [corrected]=spa_cor(spec,freqs,fallspeed)
% function [corrected]=spa_cor(spec,freqs,fallspeed)
% Function to correct for spatial response of shear probe gives the
% corrected values for spec at frequencies freqs.
% probe spatial transfer function according to ninnis' thesis 1984.
% k0=170 cycles/meter for osborn's probe.

k0=170;
f0=fallspeed*k0;
% redefine coefficients (dimensionally) in terms of f0
a=[1.0,-0.164/f0,-4.537/f0/f0,5.503/f0^3,-1.804/f0^4];
corrected=spec;
inds=find(freqs<(.9*f0));
corrected(inds)=corrected(inds)./(a(1)+freqs(inds).*(a(2)+freqs(inds).*(a(3)+freqs(inds).*(a(4)+freqs(inds)*a(5)))));