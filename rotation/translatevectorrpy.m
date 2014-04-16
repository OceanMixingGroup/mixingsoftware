function [AXout AYout AZout] = translatevectorrpy(RPY,AXAYAZ,units)
% Rotates vector XYZ, which originates in (0,0,0)
% on RPY around 3D Cartesian coordinates
% AXAYAZ is a 3D vector [AX AY AZ] 
% RPY are rotation angles {R P Y]
%          R - roll (around X axis)
%          P - pitch (around Y axis)
%          Y - yaw (around Z axis)
% Right Hand coordinate system. Positive rotations are
% in clockwise direction when looking in the positive axis direction
% All components X,Y,Z and R,P,Y could be vectors (Nx1)
% in this case size(RPY)=size(XYZ)=10x3
% "units" - are either 'degrees' or 'radians'
%           radians are default
%
% A. Perlin, September 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('units','var'), units = 'radians'; end

% convert degrees to radians
if isequal(units,'degrees'),
    RPY = RPY.*pi/180;
end
if size(RPY,2)~=3;RPY=RPY';end
if size(AXAYAZ,2)~=3;AXAYAZ=AXAYAZ';end
R=RPY(:,1);P=RPY(:,2);Y=RPY(:,3);
AX=AXAYAZ(:,1);AY=AXAYAZ(:,2);AZ=AXAYAZ(:,3);
AXout=cos(Y).*cos(P).*AX+(cos(Y).*sin(P).*sin(R)-sin(Y).*cos(R)).*AY+...
    (cos(Y).*sin(P).*cos(R)+sin(Y).*sin(R)).*AZ;
AYout=sin(Y).*cos(P).*AX+(sin(Y).*sin(P).*sin(R)+cos(Y).*cos(R)).*AY+...
    (sin(Y).*sin(P).*cos(R)-cos(Y).*sin(R)).*AZ;
AZout=-sin(P).*AX+cos(P).*sin(R).*AY+cos(P).*cos(R).*AZ;
if size(AXAYAZ,2)~=3;AXout=AXout';AYout=AYout';AZout=AZout';end
return
