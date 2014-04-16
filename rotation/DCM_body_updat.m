function [DCMbn] = DCM_body_updat(DCMb,deltaRPY,units)
% "DCMbn" is updated Direction Cosine Matrix relating the
%         current body-frame to the inertial coordinate system.  
%
% "DCMb" is initial Direction Cosine Matrix
% "deltaRPY" are INCREMENTAL bory rotations in format [r p y]
%          r - roll (around X axis)
%          p - pitch (around Y axis)
%          y - yaw (around Z axis)
% Right Hand coordinate system. Positive rotations are
% in clockwise direction when looking in the positive axis direction
% Rotation angles input in order [r p y] 
% MUST be preserved for proper calculation
% "units" - are either 'degrees' or 'radians'
%           the default is alpha in radians
%********************************************************

if ~exist('units','var'), units = 'radians'; end

% convert degrees to radians
if isequal(units,'degrees'),
    deltaRPY = deltaRPY.*pi/180;
end
r=deltaRPY(1);p=deltaRPY(2);y=deltaRPY(3);
% convert vector into skew symmetric matrix
S = [ 0 -y  p;
      y  0 -r;
     -p  r  0 ];
magn = norm(deltaRPY);
% calculate DCM that provides transformation from the body
% coordinates at time k+1 to the body coordinates at time k
if magn == 0,
   DCMbb = eye(3);
else
   DCMbb = eye(3) + (sin(magn)/magn)*S + ((1-cos(magn))/magn^2)*S*S;
end
% update DCM relating the current body-frame to the inertial coordinate system.
DCMbn = DCMb*DCMbb;
