function [c] = vapprs(airtmp,press,relhum)
%C
%C  This function calculates water vapour pressure as function of air 
%C  temperature, pressure and humidity. Based on A. Gill's book 
%C  Atmosphere-Ocean Dynamics p 605.
%C
%C  AIRTMP ------------ Air temperature (C)
%C  PRESS ------------- Barometric pressure (mb)
%C  RELHUM ------------ Relative humidity defined as 100%*W/Ws, where W is
%C                      the mixing ratio and Ws the saturation mixing ratio
%C  VAPPRS ------------ Water vapour pressure in moist air (mb)
%C  RMIXRT ------------ The mixing ratio
%C
w=sw_rmixrt(airtmp,press,relhum);
c=press.*w./(w+0.62197);
