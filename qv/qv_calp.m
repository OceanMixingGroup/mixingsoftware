function out=qv_calp(in,coeff)
% function OUT=qv_calp(IN,COEFF)
% This function does a polynomial calibration on the
% vector IN with polynomial coefficients given by the
% vector COEFF.
if size(in,2)==2
  in=ch(in);
end
out=coeff(1)+coeff(2)*in+coeff(3)*in.^2+coeff(4)*in.^3;
