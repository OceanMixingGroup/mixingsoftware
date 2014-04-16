function [bX,bY,bZ]=TdsGetUnitVectors(phi,azi,pitch,roll);
% function [bX,bY,bZ]=TdsGetUnitVectors(phi,azi,pitch,roll);
% 
% Get the three unit vectors of a beam that has the attitude given by
% phi, azi, pitch and roll.
%
% All angles are in radians...
% phi: the angle the beam makes from the horizontal plane.  Positive is
%   upwards.  Nominal is -pi/3;    
% azi: the angle the beam makes from the starboard of the ship.
%   Positive is counter clockwies.  nominal is (3 1 7 5)*pi/2.  
% pitch: the angle the bow of the ship is rotated about the x axis.
%   Positive is bow upwards. 
% roll: the angle the bow of the ship is rotated about the y axis.
%   Positive is port rail upwards.  
%
% For this the pitch is applied first and then the roll.  This is correct
% for the TSS on the Revelle.
%
% It is also correct for the PHINS on the Revelle, which has replaced the
% TSS (April 2005).

% Jody Klymak, Sep 2004
% $Id: GetUnitVectors.m,v 1.1.1.1 2008/01/31 20:22:41 aperlin Exp $

cPhi = cos(phi)*ones(size(pitch));
sPhi = sin(phi)*ones(size(pitch));
cAzi = cos(azi)*ones(size(pitch));
sAzi = sin(azi)*ones(size(pitch));
cPitch=cos(pitch);
cRoll=cos(roll);
sPitch=sin(pitch);
sRoll=sin(roll);

%% These are the elements of the matrix rotation.  They transform from a
% right-handed co-ordinate system with x pointing in the direction that beam
% 1 projects onto a horizontal plane and z pointing up, to a co-ordinate
% system defined by unit vectors pointing along each beam.

  bX=(cRoll.*cAzi.*cPhi-sRoll.*sPhi)';
  %
  bY=(-sRoll.*sPitch.*cAzi.*cPhi...
               +cPitch.*sAzi.*cPhi...
               -cRoll.*sPitch.*sPhi)';
  %
  bZ=(sRoll.*cPitch.*cAzi.*cPhi...
               +sPitch.*sAzi.*cPhi...
               +cPitch.*cRoll.*sPhi)';

% $Log: GetUnitVectors.m,v $
% Revision 1.1.1.1  2008/01/31 20:22:41  aperlin
% mixingsoftware initial input
%
% Revision 1.1  2006/10/17 19:37:00  aperlin
% *** empty log message ***
%
% Revision 1.4  2005/05/14 14:13:43  jklymak
% Added comment about the PHINS sensor
%
% Revision 1.3  2004/11/28 20:05:29  jklymak
% Fixed comment.
%
% Revision 1.2  2004/11/27 07:05:06  jklymak
% Fixed Comment somewhat
%
% Revision 1.1  2004/11/27 06:53:44  jklymak
% Initial revision
%
% Revision 1.1  2004/09/03 17:55:36  jklymak
% Initial revision
%