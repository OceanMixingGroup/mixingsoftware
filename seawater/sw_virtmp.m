function [g] = virtmp(airtmp,press,relhum)
%C
%C  This function calculates the virtual temperature as function of air
%C  temperature, pressure and humidity. Based on A. Gill's book
%C  Atmosphere-Ocean Dynamics pp 39-41.
%C
%C  VIRTMP ------------ Virtual temperature (C)
%C  AIRTMP ------------ Air temperature (C)
%C  PRESS ------------- Barometric pressure (mb)
%C  RELHUM ------------ Relative humidity defined as W/Ws*100, where W is
%C                      the mixing ratio and Ws the saturation mixing ratio
%C  SPCHUM ------------ Specific humidity
%C

g=(airtmp+273.15).*(1.0+0.6078*sw_spchum(airtmp,press,relhum));
g=g-273.15;
