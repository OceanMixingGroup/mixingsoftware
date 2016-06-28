function earth=beam2earth(beam, head, HeadingOffset, pitch, roll, ssnd, ECssnd, beams_up, xfreq, convex, sensor_config, BeamAngle);
% bm2earth.m converts RDI data recorded in BEAM to earth coordinates
%
% function earth=bm2earth(beam, head, HeadingOffset, roll, ssnd, ECssnd, beams_up, xfreq, convex, sensor_config, BeamAngle);
% where 
%	beam = bins by beam matrix of data, a single ensemble, in mm/s
%	head = value for the ensemble, in degrees
%	HeadingOffset = any additional bias to apply to the heading.
%        Values entered here are added to the heading value
%        If EB command has been set in the ADCP, heading has already
%        been corrected by the value set by the EB command.
%	pitch = value for the ensemble, in degrees
%	roll = value for the ensemble, in degrees
%	earth = resultant matrix
%	ssnd = calculated speed of sound in m/s at transducer head
%	ECssnd = speed of sound assumption from the EC command
%	beams_up = 1 for upward looking (default), 0 for downward 
%	xfreq = transmit frequency in KHz, default = 300 Khz 
%	convex = 1 for convex (default) or 0 for concave xducers
%	sensor_config = sensor configuration, default = 1, fixed
%	BeamAngle = default = 20 degrees

%	Written by Marinna Martini for the 
%	U.S. Geological Survey
%	Branch of Atlantic Marine Geology
%	Thanks to Al Pluddeman at WHOI for helping to identify the 
%	tougher bugs in developing this algorithm

% check inputs
if exist('beams_up') ~= 1, beams_up = 1; end
if exist('sensor_config') ~= 1, sensor_config = 1; end
if exist('BeamAngle')~=1, BeamAngle = 20.0; end
if exist('convex')~=1, convex = 1; end
if exist('ssnd') ~= 1,
	C = 1500.0;  % guess
else
	C = ssnd;
end
if exist('ECssnd') ~= 1,
	ECssnd = 1500.0; % guess
end
if exist('xfreq')~=1, xfreq = 307.2*1000; 
else xfreq = xfreq*1000;
end

% generic instrument transformation matrix


% Step 1 - determine rotation angles from sensor readings
% fixed sensor case
% make sure everything is expressed in radians for MATLAB
d2r=pi/180;	% conversion from degrees to radians
RR=roll.*d2r;
KA=sqrt(1.0 - (sin(pitch.*d2r).*sin(roll.*d2r)).^2);
PP=asin(sin(pitch.*d2r).*cos(roll.*d2r)./KA);
% fix heading bias
% add heading bias to conform with RDI conventions
HH=(head+HeadingOffset).*d2r;

% Step 2 - calculate trig functions and scaling factors
CP=cos(PP); CR=cos(RR); CH=cos(HH); 
SP=sin(PP); SR=sin(RR); SH=sin(HH);
C30=cos(BeamAngle*d2r);
S30=sin(BeamAngle*d2r);

% fixed sensor case
M(1) = -SR.*CP;
M(2) = SP;
M(3) = CP.*CR;

if beams_up == 1,	% for upward looking
	if convex == 1,
		ZSG = [+1, -1, +1, -1];
	else
		ZSG = [-1, +1, -1, +1];
	end
else	% for downward looking
	if convex == 1,
		ZSG = [+1, -1, -1, +1];
	else
		ZSG = [-1, +1, -1, +1];
	end
end

% copmute scale factor for each beam to transform depths
% in a tilted frame to depths in a fixed frame
% RDI version of code
%SC(1) = C30./(M(3).*C30 + ZSG(1).*M(1).*S30);
%SC(2) = C30./(M(3).*C30 + ZSG(2).*M(1).*S30);
%SC(3) = C30./(M(3).*C30 + ZSG(3).*M(2).*S30);
%SC(4) = C30./(M(3).*C30 + ZSG(4).*M(2).*S30);
% Pluddeman version of code 
% changed for his difference in beam angle convention
SC(1) = (M(3).*C30 + ZSG(1).*M(1).*S30);
SC(2) = (M(3).*C30 + ZSG(2).*M(1).*S30);
SC(3) = (M(3).*C30 + ZSG(3).*M(2).*S30);
SC(4) = (M(3).*C30 + ZSG(4).*M(2).*S30);
%SC


% form the transducer to instrument coordinate system
% scaling constants
% RDI version
%VXS = (C*100.0)/(xfreq*4*S30);
%VYS = (C*100.0)/(xfreq*4*S30);
%VZS = (C*100.0)/(xfreq*8*C30);
%VES = (C*100.0)/(xfreq*8);

% form the transducer to instrument coordinate system
% scaling constants
% original Al Plueddeman version where theta is the 
% beam angle from the horizontal
% sthet0=sin(d2r*(90-BeamAngle));
% cthet0=cos(d2r*(90-BeamAngle));
% VXS = VYS = SSCOR / (2.0*cthet0);
% VZS = VES = SSCOR / (2.0*sthet0);
% correct for speed of sound using ADCP sound speed
% based on thermistor measurements, where 1500 was the
% assumed sound speed.
%SSCOR = ssnd/1500;
SSCOR = ssnd/ECssnd;
%SSCOR = 1;
% my version of Al's scaling constant, using RDI's
% convention for theta as beam angle from the vertical
VXS = SSCOR/(2.0*S30);
VYS = VXS;
VZS = SSCOR/(2.0*C30);
VES = VZS;

[NBINS, n]=size(beam);
earth=zeros(size(beam));
clear n;
J=zeros(1,4);

for IB=1:NBINS,
	% Step 3:  correct depth cell index for pitch and roll
	for i=1:4, 
		J(i)=fix(IB.*SC(i)+0.5); 
	end
	% Step 4:  ADCP coordinate velocity components
	if all(J > 0) & all(J <= NBINS),
		if any(isnan(beam(IB,:))),
			earth(IB,:)=ones(size(beam(IB,:))).*NaN;
		else
			if convex == 1,
				if beams_up == 1,
					% for upward looking convex
					VX = VXS.*(-beam(J(1),1)+beam(J(2),2));
					VY = VYS.*(-beam(J(3),3)+beam(J(4),4));
					VZ = VZS.*(-beam(J(1),1)-beam(J(2),2)-beam(J(3),3)-beam(J(4),4));
					VE = VES.*(+beam(J(1),1)+beam(J(2),2)-beam(J(3),3)-beam(J(4),4));
				else
					% for downward looking convex
					VX = VXS.*(+beam(J(1),1)-beam(J(2),2));
					VY = VYS.*(-beam(J(3),3)+beam(J(4),4));
					VZ = VZS.*(+beam(J(1),1)+beam(J(2),2)+beam(J(3),3)+beam(J(4),4));
					VE = VES.*(+beam(J(1),1)+beam(J(2),2)-beam(J(3),3)-beam(J(4),4));
				end
			else,
				if beams_up == 1,
					% for upward looking concave
					VX = VXS.*(+beam(J(1),1)+beam(J(2),2));
					VY = VYS.*(+beam(J(3),3)+beam(J(4),4));
					VZ = VZS.*(-beam(J(1),1)-beam(J(2),2)-beam(J(3),3)-beam(J(4),4));
					VE = VES.*(+beam(J(1),1)+beam(J(2),2)-beam(J(3),3)-beam(J(4),4));
				else
					% for downward looking concave
					VX = VXS.*(-beam(J(1),1)+beam(J(2),2));
					VY = VYS.*(+beam(J(3),3)-beam(J(4),4));
					VZ = VZS.*(+beam(J(1),1)+beam(J(2),2)+beam(J(3),3)+beam(J(4),4));
					VE = VES.*(+beam(J(1),1)+beam(J(2),2)-beam(J(3),3)-beam(J(4),4));
				end		
			end
			% Step 5: convert to earth coodinates
			VXE =  VX.*(CH*CR + SH*SR*SP) + VY.*SH.*CP + VZ.*(CH*SR - SH*CR*SP);
			VYE = -VX.*(SH*CR - CH*SR*SP) + VY.*CH.*CP - VZ.*(SH*SR + CH*SP*CR);
			VZE = -VX.*(SR*CP)            + VY.*SP     + VZ.*(CP*CR);
			earth(IB,:) = [VXE, VYE, VZE, VE];
		end % end of if any(isnan(beam(IB,:))),
	else
		earth(IB,:)=ones(size(beam(IB,:))).*NaN;
	end % end of if all(J > 0) && all(J < NBINS),
end	% end of IB = 1:NBINS