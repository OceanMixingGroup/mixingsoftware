function [k] = sw_snhtfl(airtmp,press,relhum,sfctmp,uz10)
%C
%C  This function calculates the upward sensible heat flux at the sea surface
%C  
%C  SNHTFL ---------  Upward sensible heat flux from the sea surface (W/m^2)
%C  PRESS ----------  Barometric pressure (mb)
%C  RELHUM ---------  Relative humidity defined as W/Ws*100, where W is
%C                    the mixing ratio and Ws the saturation mixing ratio
%C  SFCTMP ---------  Sea surface temperature (C)
%C  AIRTMP ---------  The air temperature at 10 m (C)
%C  UZ10 -----------  Wind speed at 10 m above sea level (m/sec)
%C  Cd -------------  The drag coefficient (depends on wind speed)
%C  GAMMA ----------  Adiabatic lapse rate, g/Cp (K/m)
%C  THET0 ----------  Potential temperature at the surface (C)
%C  THET10 ---------  Potential temperature at the 10 m above sea level (C)
%C  Rhoair ---------  Air density (kg/m^3)
%C  grav -----------  Gravitational acceleration (m/s^2)
%C

grav=9.8;
rhoair=sw_airden(airtmp,press,relhum);
cp=sw_cpair(airtmp,press,relhum);
cd=sw_drag(uz10);
gamma=grav./cp;
%C	WRITE (*,*) 'GAMMA=',GAMMA
thet10=airtmp+gamma.*10.0;
thet0=sfctmp;
k=rhoair.*cp.*cd.*uz10.*(thet0-thet10);
