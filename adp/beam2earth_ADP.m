function adp=beam2earth_ADP(adp,dec);
% bm2earth.m converts SONTEK ADP data recorded in BEAM to EARTH coordinates
% dec is magnetic declination (positive if East, negative if West)
%% Prepare the angles for the rotation....
% phi = beam_declension; this is the vertical angle: the angle the beam 
% makes from the horizontal plane.  Positive is upwards.
% azi = beam_azimuth; this is the horizontal rotation the angle the beam 
% makes from the starboard of the ship. Positive is counter clockwies.
% If beam 1 is aligned with the ship looking forward, orientation of beam 1
% is +90 degrees
% pitch: the angle the bow of the ship is rotated about the x axis.
%   Positive is bow upwards. 
% roll: the angle the bow of the ship is rotated about the y axis.
%   Positive is port rail upwards.

% For theree beams, 25 degrees off vertical:
beamsToDo=1:3;
beams_up=strcmp(char(adp.profile.orientation{1}),'up');
if beams_up
    phi(1:3)=65*pi/180;
    azi=[90 -30 -150]*pi/180;
    roll=-adp.profile.meanroll*pi/180;
    pitch=adp.profile.meanpitch*pi/180;
else
    phi(1:3)=-65*pi/180;
    azi=[90 -150 -30]*pi/180;
    roll=adp.profile.meanroll*pi/180;
    pitch=adp.profile.meanpitch*pi/180;
end
%% Rotate velocities to XYZ ("ship") coordinates
% Y towards the bow
% X towards starboard 

for ibeam=1:3;
  [bX(:,ibeam),bY(:,ibeam),bZ(:,ibeam)] = GetUnitVectors(phi(ibeam),azi(ibeam), ...
                                                    pitch,roll);
end;
ensem=size(adp.profile.vel1,2);
bins=size(adp.profile.vel1,1);
shipvel = ones(min(length(beamsToDo),3),bins,ensem);
vel(1,:,:)=adp.profile.vel1;
vel(2,:,:)=adp.profile.vel2;
vel(3,:,:)=adp.profile.vel3;
for n=1:ensem
  if length(beamsToDo)==2
    B=([bX(n,beamsToDo);bY(n,beamsToDo)]);
  elseif length(beamsToDo)>=3
    B=([bX(n,beamsToDo);bY(n,beamsToDo);bZ(n,beamsToDo)]);
  end;
  % the unit vectors for each beam is pointing away from the ADP, and
  % positive beam velocity is away from the unit
  V = squeeze(vel(beamsToDo,:,n));
  V = V'/B;
  shipvel(:,:,n)=V';
end;
%% Rotate to ENU coordinates
adp.profile.trueheading=adp.profile.meanheading+dec;
envel=squeeze(shipvel(1,:,:)+sqrt(-1)*shipvel(2,:,:));
envel=envel.*repmat(exp(i*(-adp.profile.trueheading)*pi/180),size(envel,1),1);
adp.profile.u=real(envel);
adp.profile.v=imag(envel)
adp.profile.w=squeeze(shipvel(3,:,:));

