function cal=calc_lp_rotations(cal,number)
% calulates low-passed rotations in right-hand Earth (inertial) coordinate
% system.
% "number" is a length of flip size on both ends of the record for proper
% filtering
%
% Yaw angle is a low-passed compass output translated to right-hand
% coordinate system (compass signal is in left-hand coordinate system) and
% offset to have zero at mean Chipod orientation
% Roll and Pitch angles are computed from gravitational part of  
% acceleration signal and derived from multiplication of rotation matrix on
% gravitational acceleration vector.
% A. Perlin, September 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<2
  number=36000; % 5 minutes
end
len=length(cal.AX);
flipsize=min(len,number);
temp=cal;
% temp.CMPy=unwrap(-(temp.CMP-temp.CMP(1))*pi/180)*180/pi;
% temp.CMPy(2:end-1)=deglitch(temp.CMPy(2:end-1),30,2);temp.CMPy=fillgap(temp.CMPy);
% if size(temp.CMPy,2)>1;temp.CMPy=temp.CMPy';end
% unwrap does not always work, so we will do it the other way:
temp.CMPy=interp1(1:120:len,temp.CMP,1:len);
cmp=exp(sqrt(-1)*temp.CMPy*pi/180);
temp.cmpu=real(cmp); temp.cmpv=imag(cmp); 
names1={'AZ','AX','AY','cmpu','cmpv'};
names2={'AZlp','AXlp','AYlp','cmp_u','cmp_v'};
for i=1:length(names1)
    in=temp.(char(names1(i)));
    if size(in,1)>1
        in=in';
    end
    fin=fliplr(in(1:flipsize)); fin=fin(1:end-1);
    bin=fliplr(in(end-flipsize+1:end)); bin=bin(2:end);
    in=[fin in  bin];
    in=gappy_filt(120,{'l0.01'},4,in,1,1,20);
    in=gappy_filt(120,{'l0.01'},4,in,1,1,20);
    cal.(char(names2(i)))=in(flipsize:flipsize+len-1);
    if size(temp.(char(names1(1))),1)>1
        cal.(char(names2(i)))=cal.(char(names2(i)))';
    end
end
cal.ylp=atan2(cal.cmp_v,cal.cmp_u)*180/pi;
% Compass and yaw are positive in opposite directions (compass is in
% left-hand and yaw is in right-hand coordinate system)
cal.ylp=-cal.ylp;
cal.ylp(cal.ylp<0)=cal.ylp(cal.ylp<0)+360;
% g=mean(cal.AZlp);
g=9.81;
cal.rlp=asin(cal.AYlp/g)*180/pi;
cal.plp=asin(cal.AXlp./cosd(cal.rlp)/(-g))*180/pi;

