function [j] = sw_cpair(airtmp,press,relhum)
%C
%C  This function calculates the specific heat of moist air at constant 
%C  pressure as function of air temperature, pressure and humidity.
%C  Based on A. Gill's book Atmosphere-Ocean Dynamics p 43.
%C
%C  CPair ------------- Specific heat at constant pressure for moist 
%C                      air (J/kg/K)
%C  SPCHUM ------------ Specific humidity (the mass of vapour per unit
%C                      mass of moist air
%C  AIRTMP ------------ Air temperature (C)
%C  PRESS ------------- Barometric pressure (mb)
%C  RELHUM ------------ Relative humidity defined as 100%*W/Ws, where W is
%C                      the mixing ratio and Ws the saturation mixing ratio
%C
j=1004.64.*(1.0+0.83748.*sw_spchum(airtmp,press,relhum));

