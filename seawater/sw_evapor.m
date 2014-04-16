function [l] = sw_evapor(airtmp,press,relhum,sfctmp,u10)
%C 
%C  This function calculates the evaporation rate at the sea surface
%C  
%C  EVAPOR ---------  Evaporation rate (kg/m^2/sec)
%C  PRESS ----------  Barometric pressure (mb)
%C  RELHUM ---------  Relative humidity defined as W/Ws*100, where W is
%C                    the mixing ratio and Ws the saturation mixing ratio
%C  SFCTMP ---------  Sea surface temperature (C)
%C  AIRTMP ---------  The air temperature at 10 m (C)
%C  U10 ------------  Wind speed at 10 m above sea level (m/sec)
%C  Cd -------------  The drag coefficient (depends on wind speed)
%C  q0 -------------  The specific humidity at the sea surface (assumed
%C                    to be the saturation value of the specific humidity
%C                    at the sea surface temperature)
%C  q10 ------------  The specific humidity at 10 m
%C  Rhoair ---------  Air density (kg/m^3)
%C

rhoair=sw_airden(airtmp,press,relhum);
cd=sw_drag(u10);
q10=sw_spchum(airtmp,press,relhum);
q0=sw_sathum(sfctmp,press);
l=rhoair.*cd.*u10.*(q0-q10);
