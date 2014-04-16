function [Tout] = pwp_Stir(rmin,T,j)
%pwp_Stir 'Stirs' (mixes) an input variable  
%    [Out]=pwp_Stir(rmin,In,j)
%    used for turbulent mixing of T,S, and UV in pwp_GradRichardson.m
%    The algorithm used in this function follows directly from the PWP paper
%    Inputs:
%    j = indices of critical cells
%    In = variable to stir
%    rmin = 0.2

Rg_prime  = .3;                % should be 0.3 as per the PWP paper
Rfac      = 1 - rmin./Rg_prime;                   
Tout      = T;                             
Tout(j)   = T(j) + Rfac.*(T(j+1) - T(j))./2;     
Tout(j+1) = T(j+1) - Rfac.*(T(j+1) - T(j))./2;
