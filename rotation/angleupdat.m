function [euler,deuler] = angleupdat(eulerold,rpybody,units)
% Calculation of the actual angular velocity and rotations
% referring to the initial system
%
% "eulerold" initial rotaion of the body system relative to 
% the inertial system (for example known from the previous iteration
% of this code) in format [eroll epitch eyaw]
%
% "rpybody" rotation in body coordinate system [broll bpitch byaw]
%
% "units" are either 'radians' or 'degrees'
%
% Example:
%         [rpynew,dangxyz] = angleupdat(rpynew,[dr dp dy]);
%         RM=DCM(rpynew,'rpy');
%         out=RM*in; % in is the INITIAL body position not from the
%                    % previous time step
% 
% WARNING: This code breaks down when pitch is 90 degrees
% WARNING: Does not work well for a series of calculations with big angles
% even though the matrix is perfectly correct... 
% Use DCM_body_updat.m instead...
% A. Perlin, Sept. 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('units','var'), units = 'radians'; end
% convert degrees to radians
if isequal(units,'degrees'),
    eulerold=eulerold.*pi/180;
    rpybody=rpybody.*pi/180;
end
% eulerold(eulerold==pi/2)=pi/2-0.0005;
er=eulerold(1);ep=eulerold(2);ey=eulerold(3);
br=rpybody(1);bp=rpybody(2);by=rpybody(3);
ACM=[1   sin(er)*tan(ep)  -cos(er)*tan(ep);
     0   cos(er)          sin(er);
     0  -sin(er)/cos(ep)   cos(er)/cos(ep)];
deuler=ACM*[br bp by]';
euler=[er+deuler(1);ep+deuler(2);ey+deuler(3)];
if isequal(units,'degrees'),
    euler=euler.*180/pi;
    deuler=deuler.*180/pi;
end

return
