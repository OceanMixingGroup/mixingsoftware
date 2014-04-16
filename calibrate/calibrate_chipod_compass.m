function cal=calibrate_chipod_compass(ser,data,head,cal)
% function cal=calibrate_chipod_compass(ser,data,head,cal)
% Calibrates compass assuming you have already computed the calibration
% coefficients, which should be placed into head.coef.(ser) using
% compute_compass_calibration_coefficients.m.  These coefficients can be
% any length as they simply rely on polyfit and polyval.
%   $Revision: 1.1.1.1 $  $Date: 2011/05/17 18:08:05 $
  
  coef=head.coef.(upper(ser));
  % This is pretty simple!
  cal.(ser)=polyval(coef,data.(ser));
