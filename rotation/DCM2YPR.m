function [Y P R]=DCM2YPR(DCM,units)
% [Y P R]=DCM2YPR(DCM) returns [Yaw Pitch Roll] angles  
% from Direction Cosine Matrix (for same sequence of rotations)
% "DCM" is Direction Cosine Matrix  for [Yaw Pitch Roll] rotation
%
% "units" - are either 'degrees' or 'radians'
%           the default is alpha in radians
%
% "[Y P R]" are [Yaw Pitch Roll] angles
%
% A. Perlin, Sept. 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('units','var'), units = 'radians'; end

P=asin(DCM(1,3));
Y=acos(DCM(1,1)/sqrt(1-DCM(1,3)^2))*sign(-DCM(1,2));
R=acos(DCM(3,3)/sqrt(1-DCM(1,3)^2))*sign(-DCM(2,3));

% convert degrees to radians
if isequal(units,'degrees'),
    YPR = [Y P R].*180/pi;
    Y=YPR(1);P=YPR(2);R=YPR(3);
end
