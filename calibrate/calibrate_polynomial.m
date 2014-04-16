function [out]=calibrate_polynomial(in,coef)
% function [out]=calibrate_poly(in)
%   in - input data structure
%   calibrates using polynomial coefficients in head.coef
%   $Revision: 1.1.1.1 $  $Date: 2011/05/17 18:08:05 $

out=coef(1)+coef(2).*in+coef(3).*(in.^2)+coef(4).*(in.^3);