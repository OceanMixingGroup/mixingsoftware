function [RM] = DCM(rpy,order,units)
%
% DCM: Create Directional Cosine Matrix for rotation
% around 3D Cartesian coordinates 
%
% [RM] = DCM(rpy,order,units)
%
% "rpy" -  angles of rotation [r p y]:
%          r - roll (around X axis)
%          p - pitch (around Y axis)
%          y - yaw (around Z axis)
% Right Hand coordinate system. Positive rotations are
% in clockwise direction when looking in the positive axis direction
%
% "order" - order of rotations, 
% e.g. ['RPY'] means roll, then pitch, then yaw
%
% "units" - are either 'degrees' or 'radians'
%           radians are default
%
% A. Perlin, September 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('units','var'), units = 'radians'; end

% convert degrees to radians
if isequal(units,'degrees'),
    rpy = rpy.*pi/180;
end
r=rpy(1);p=rpy(2);y=rpy(3);
RX = [1 0 0; 0 cos(r) -sin(r); 0 sin(r) cos(r) ];
RY = [ cos(p) 0 sin(p); 0 1 0; -sin(p) 0 cos(p) ];
RZ = [ cos(y) -sin(y) 0;  sin(y) cos(y) 0;  0 0 1 ];

if isequal(lower(order),'rpy')
    RM=RZ*RY*RX;
% RM=RZ*RY*RX=[cos(y)*cos(p)  cos(y)*sin(p)*sin(r)-sin(y)*cos(r)  cos(y)*sin(p)*cos(r)+sin(y)*sin(r);
%              sin(y)*cos(p)  sin(y)*sin(p)*sin(r)+cos(y)*cos(r)  sin(y)*sin(p)*cos(r)-cos(y)*sin(r);
%              -sin(p)        cos(p)*sin(r)                       cos(p)*cos(r)                     ]
elseif isequal(lower(order),'ypr')
    RM=RX*RY*RZ;
% RM=RX*RY*RZ=[cos(p)*cos(y)                       -cos(p)*sin(y)                      sin(p);
%              cos(r)*sin(y)+sin(r)*sin(p)*cos(y)  cos(r)*cos(y)-sin(r)*sin(p)*sin(y)  -sin(r)*cos(p);
%              sin(r)*sin(y)-cos(r)*sin(p)*cos(y)  sin(r)*cos(y)+cos(r)*sin(p)*sin(y)  cos(r)*cos(p) ]
elseif isequal(lower(order),'ryp')
    RM=RY*RZ*RX;
elseif  isequal(lower(order),'yrp')
    RM=RY*RX*RZ;
elseif isequal(lower(order),'pyr')
    RM=RX*RZ*RY;
elseif isequal(lower(order),'pry')
    RM=RZ*RX*RY;
else
    error('Error: Invalid entry for ORDER OF ROTATION input string');        
end
return
