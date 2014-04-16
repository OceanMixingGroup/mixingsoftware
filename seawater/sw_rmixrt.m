function [b] = rmixrt(airtmp,press,relhum)
%C
%C  This function calculates the mixing ratio as function of air 
%C  temperature, pressure and humidity. Based on A. Gill's book 
%C  Atmosphere-Ocean Dynamics p 605.
%C
%C  RMIXRT ------------ The mixing ratio (the ratio of the mass of vapour
%C                      to the mass of dry air) 
%C  AIRTMP ------------ Air temperature (C)
%C  PRESS ------------- Barometric pressure (mb)
%C  RELHUM ------------ Relative humidity defined as 100%*W/Ws, where W is
%C                      the mixing ratio and Ws the saturation mixing ratio
%C  SATMIX -----------  Saturation mixing ratio
%C
b=sw_satmix(airtmp,press).*relhum./100.0;
