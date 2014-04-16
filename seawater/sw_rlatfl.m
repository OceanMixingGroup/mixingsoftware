function [m] = sw_rlatfl(airtmp,press,relhum,sfctmp,u10)
%C
%C  This function calculates the upward latent heat flux at the sea surface.
%C  It uses the evaporation rate calculated by function EVAPOR  
%C
%C  RLATFL ---------  Upward flux of latent heat (W/m^2)
%C  EVAPOR ---------  Evaporation rate (kg/m^2/sec)
%C  L --------------  Latent heat of vaporization as function of temperature
%C                    (see Gill p 607) (J/kg)
%C  PRESS ----------  Barometric pressure (mb)
%C  RELHUM ---------  Relative humidity defined as W/Ws*100, where W is
%C                    the mixing ratio and Ws the saturation mixing ratio
%C  SFCTMP ---------  Sea surface temperature (C)
%C  AIRTMP ---------  The air temperature at 10 m (C)
%C  U10 ------------  Wind speed at 10 m above sea level (m/sec)
%C

ll=2.5008E6-2.3E3.*sfctmp;
m=ll.*sw_evapor(airtmp,press,relhum,sfctmp,u10);

