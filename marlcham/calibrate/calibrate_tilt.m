function out=calibrate_tilt(in,coeff)
% function OUT=calibrate_tilt(IN,COEFF)
% TO CALIBRATE acceleration in degrees.
% This function does a polynomial calibration on the
% vector IN with polynomial coefficients given by the
% vector COEFF.
if size(in,2)==2
  in=ch(in);
end
% add a gain step if coeff(5) is non-zero
if coeff(5), in=in/coeff(5);, end

out=real(180/pi*asin(coeff(1)+coeff(2)*in+coeff(3)*in.^2+coeff(4)*in.^3));