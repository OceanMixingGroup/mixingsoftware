function [R P Y]=DCM2RPY(DCM,units)
% [R P Y]=DCM2RPY(DCM) returns [Roll Pitch Yaw] angles  
% from Direction Cosine Matrix (for same sequence of rotations)
% "DCM" is Direction Cosine Matrix  for [Roll Pitch Yaw] rotation
%
% "units" - are either 'degrees' or 'radians'
%           the default is alpha in radians
%
% "[R P Y]" are [Roll Pitch Yaw] angles
%
% A. Perlin, Sept 2008

if ~exist('units','var'), units = 'radians'; end

P=asin(-DCM(3,1));
R=acos(DCM(3,3)/sqrt(1-DCM(3,1)^2))*sign(DCM(3,2));
Y=acos(DCM(1,1)/sqrt(1-DCM(3,1)^2))*sign(DCM(2,1));

% convert degrees to radians
if isequal(units,'degrees'),
    RPY = [R P Y].*180/pi;
    R=RPY(1);P=RPY(2);Y=RPY(3);
end
