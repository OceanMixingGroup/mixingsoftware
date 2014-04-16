function cal=remove_gravitation(cal,head,g)
% Removes gravitational part of acceleration from acceleration measurements
% Input accelerations are calibrated in m/s^2.
% Body rotations in Earth coordinate system should be known
% Right Hand coordinate system. Positive rotations are
% in clockwise direction when looking in the positive axis direction
% Rotation about X is ROLL (cal.roll), about Y is PITCH (cal.pitch), 
% and about Z is YAW (cal.yaw). Angle YAW has zero at mean Chipod
% orientation (that would make mean(YAW)=0).
% g is gravitational acceleration
% Measured accelerations are renamed to cal.AX_old, cal.AY_old, cal.AZ_old
% A. Perlin, September 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3
    g=nanmean(cal.AZ./cosd(cal.pitch).*cosd(cal.roll));
end
cal.AX_old=cal.AX;
cal.AY_old=cal.AY;
cal.AZ_old=cal.AZ;


cal.AX=cal.AX+g.*sind(cal.pitch).*cosd(cal.roll);
cal.AY=cal.AY-g.*sind(cal.roll);
cal.AZ=cal.AZ-g.*cosd(cal.pitch).*cosd(cal.roll);

