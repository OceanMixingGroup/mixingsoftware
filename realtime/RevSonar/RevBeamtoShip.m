function V=beamstoship(V);
% function sonar=beamstoship(sonar);
% Translates the beam velocities into Ship co-ordinates.  
%
% Ship co-ordinates means x is stbd, y is bow forward, and z is towards
% the mast.  It also means that ship's pitch and roll have been
% subtracted.
%
% Heading, pitch, and roll are corrected and set in the routine.  Ship
% speed is also calculated by first differencing the ships pcode
% location.  This appears less noisy that the sog calculation.
  
  
  
% correction angles for Revelle from Glenn...
correction = [1;2;-1;1.5;0.2945;1.6365;0.1836;1.3825]/180*pi;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Azimuthal and depression angles for the beams %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
omega(1) = (3*45) * pi/180 + correction(1);
omega(2) = (1*45) * pi/180 + correction(2);
omega(3) = (7*45) * pi/180 + correction(3);
omega(4) = (5*45) * pi/180 + correction(4);

gamma(1) = (-60) * pi/180 + correction(5);
gamma(2) = (-60) * pi/180 + correction(6);
gamma(3) = (-60) * pi/180 + correction(7);
gamma(4) = (-60) * pi/180 + correction(8);

% Get pitch and roll...
pitch_offset = 0.4*pi/180;
roll_offset = -0.8*pi/180;

V.pitch = V.head.pitch*pi/180 -pitch_offset;
V.roll = V.head.roll*pi/180-roll_offset;
V.heading = atan2(V.head.heading_cos,V.head.heading_sin);
roll = V.roll;
pitch=V.pitch;

V.sog = V.head.pcode_sog/100;
V.cog = atan2(V.head.pcode_cogT_sin,V.head.pcode_cogT_cos);
phi = pi/2-V.cog;
fra = V.head.pcode_lon_fraction;
bad = find(fra>0.5);fra(bad)=fra(bad)-1;
V.pcode_lon = -round(V.head.pcode_lon)-fra;
fra = V.head.pcode_lat_fraction;
bad = find(fra>0.5);
fra(bad)=fra(bad)-1;
V.pcode_lat = round(V.head.pcode_lat)+fra;

% this ship speed is noisy, so recalc...
V.shipSOG = V.sog.*exp(sqrt(-1)*phi);
% redo using pcode.
[dist,ang]=sw_dist([V.pcode_lat],[V.pcode_lon],'km');
time = V.time(1:end-1)+diff(V.time)/2;
dt=nanmean(diff(time))*3600*24;
% center properly...
good = find(time>datenum(1950,1,1));
dt=round(nanmean(diff(time(good)))*3600*24);
V.shipPCODE = interp1(time(good),dist(good)*1000.*exp(sqrt(-1)*ang(good)*pi/ ...
                                                 180)./dt,V.time);
V.ship = V.shipSOG;

[x,y] = j_ll2xy(V.pcode_lon,V.pcode_lat,median(V.pcode_lat));
V.x = x+sqrt(-1)*y;

for i=1:4
  % transfor so beam velocities are away from the ship...
  % beam1 = squeeze(V.vel(1,:,:));
  eval([sprintf('beam%d',i) '=-squeeze(V.vel(i,:,:));']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% In terms of the ship coordinate system, the unit vectors for the four               %%
%% beams are given by r = R_y(roll)*R_x(pitch)*R_z(omega)*[cos(gamma); 0; sin(gamma)], %%
%% where R_f is the clockwise rotation matrix around the f axis.                       %%
%% Remember to mormalise these vectors.                                                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r1 = [cos(roll).*cos(omega(1)).*cos(gamma(1)) + ...
        -sin(roll).*sin(pitch).*sin(omega(1)).*cos(gamma(1)) + ...
        sin(roll).*cos(pitch).*sin(gamma(1));
      cos(pitch).*sin(omega(1)).*cos(gamma(1)) + sin(pitch).*sin(gamma(1));
      -sin(roll).*cos(omega(1)).*cos(gamma(1)) + ...
          -cos(roll).*sin(pitch).*sin(omega(1)).*cos(gamma(1)) + ...
          cos(roll).*cos(pitch).*sin(gamma(1))];
r2 = [cos(roll).*cos(omega(2)).*cos(gamma(2)) + ...
        -sin(roll).*sin(pitch).*sin(omega(2)).*cos(gamma(2)) + ...
        sin(roll).*cos(pitch).*sin(gamma(2));
      cos(pitch).*sin(omega(2)).*cos(gamma(2)) + sin(pitch).*sin(gamma(2));
      -sin(roll).*cos(omega(2)).*cos(gamma(2)) + ...
          -cos(roll).*sin(pitch).*sin(omega(2)).*cos(gamma(2)) + ...
          cos(roll).*cos(pitch).*sin(gamma(2))];
r3 = [cos(roll).*cos(omega(3)).*cos(gamma(3)) + ...
        -sin(roll).*sin(pitch).*sin(omega(3)).*cos(gamma(3)) + ...
        sin(roll).*cos(pitch).*sin(gamma(3));
      cos(pitch).*sin(omega(3)).*cos(gamma(3)) + sin(pitch).*sin(gamma(3));
      -sin(roll).*cos(omega(3)).*cos(gamma(3)) + ...
          -cos(roll).*sin(pitch).*sin(omega(3)).*cos(gamma(3)) + ...
          cos(roll).*cos(pitch).*sin(gamma(3))];
r4 = [cos(roll).*cos(omega(4)).*cos(gamma(4)) + ...
        -sin(roll).*sin(pitch).*sin(omega(4)).*cos(gamma(4)) + ...
        sin(roll).*cos(pitch).*sin(gamma(4));
      cos(pitch).*sin(omega(4)).*cos(gamma(4)) + sin(pitch).*sin(gamma(4));
      -sin(roll).*cos(omega(4)).*cos(gamma(4)) + ...
          -cos(roll).*sin(pitch).*sin(omega(4)).*cos(gamma(4)) + ...
          cos(roll).*cos(pitch).*sin(gamma(4))];
    
r1 = r1 ./(ones(size(r1,1),1)*sum(r1.^2));
r2 = r2 ./(ones(size(r2,1),1)*sum(r2.^2));
r3 = r3 ./(ones(size(r3,1),1)*sum(r3.^2));
r4 = r4 ./(ones(size(r4,1),1)*sum(r4.^2));
% preallocate...
across_ship = nan*ones(size(beam1)); 
along_ship = nan*ones(size(beam1)); 
vertical = nan*ones(size(beam1));
Vel123.x = nan*ones(size(beam1)); 
Vel123.y = nan*ones(size(beam1));
Vel123.z = nan*ones(size(beam1)); 
Vel234 = Vel123; Vel341 = Vel123; Vel412 ...
    = Vel123;
[nbins,nensem] =size(beam1); 
% do the transforms and get the velocities...
for ido = 1:nensem
  B = [r1(:,ido) r2(:,ido) r3(:,ido)];
  Vel1 = [beam1(:,ido) beam2(:,ido) beam3(:,ido)] * inv(B);
  Vel123.x(:,ido) = Vel1(:,1); Vel123.y(:,ido) = Vel1(:,2); Vel123.z(:,ido) = Vel1(:,3);
  
  B = [r2(:,ido) r3(:,ido) r4(:,ido)];
  Vel2 = [beam2(:,ido) beam3(:,ido) beam4(:,ido)] * inv(B);
  Vel234.x(:,ido) = Vel2(:,1); Vel234.y(:,ido) = Vel2(:,2); Vel234.z(:,ido) = Vel2(:,3);
  
  B = [r3(:,ido) r4(:,ido) r1(:,ido)];
  Vel3 = [beam3(:,ido) beam4(:,ido) beam1(:,ido)] * inv(B);
  Vel341.x(:,ido) = Vel3(:,1); Vel341.y(:,ido) = Vel3(:,2); Vel341.z(:,ido) = Vel3(:,3);
  
  B = [r4(:,ido) r1(:,ido) r2(:,ido)];
  Vel4 = [beam4(:,ido) beam1(:,ido) beam2(:,ido)] * inv(B);
  Vel412.x(:,ido) = Vel4(:,1); Vel412.y(:,ido) = Vel4(:,2); Vel412.z(:,ido) = Vel4(:,3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Velocity in ship coordinates are the average of the three-beam solutions %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
across_ship = 0.25*(Vel123.x + Vel234.x + Vel341.x + Vel412.x);
along_ship = 0.25*(Vel123.y + Vel234.y + Vel341.y + Vel412.y);
vertical = 0.25*(Vel123.z + Vel234.z + Vel341.z + Vel412.z);
V.Uship = sqrt(-1)*along_ship + across_ship;
V.Uz = vertical;
V.head.heading=atan2(V.head.heading_sin,V.head.heading_cos);
% for the heading I've decided that the ADU heading is the best...
heading = atan2(V.head.ADU2_heading_sin,V.head.ADU2_heading_cos)+3*pi/180;
% except it is glitchy...
heading = despike(heading,5,0.02);

good = find(~isnan(heading) & abs(heading-V.head.heading)<10*pi/180);
bad = find(~(~isnan(heading) & abs(heading-V.head.heading)<10*pi/180));
% get the mean offset between the ADU and the gyro.
os = nanmean(heading(good)'-V.head.heading(good)');
% fill in bad ADU data with this data...
heading(bad) = V.head.heading(bad)+os;
% and then the ADU appears to have a 2 degree offset...
V.heading = heading+2*pi/180;

% roatate into earth co-ordinates...
phi = V.heading;
V.u = V.Uship.*repmat(exp(-sqrt(-1)*phi),size(V.Uship,1),1);
V.w = vertical;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outy]=despike(iny,despikelen,limit,doplot);
% function [outy]=despike(iny,despikelen,limit,itter,doplot);

if nargin<4
  doplot=0;
end;


outy=iny;
good = find(~isnan(iny) & ~isinf(iny));
if length(good)>3*despikelen
  b=ones(1,despikelen)./despikelen;a=1;
  lowy = filtfilt(b,a,iny(good));
  dif = abs(lowy-iny(good));
else
  % this is too short to despike....
  %    warning('Time-series too short to despike'); 
  outy=iny;
  return;
end;

  
 
bad = find(dif>limit);
outy(good(bad))=NaN;
if doplot
  subplot(2,1,1);
  plot(iny);
  hold on;
  plot(lowy,'b');
  plot(outy,'r');
  subplot(2,1,2);
  hist(lowy-iny(good),100)
end;
%keyboard
