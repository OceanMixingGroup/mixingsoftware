function [h] = airden(airtmp,press,relhum)
%C
%C  [h] = airden(airtmp,press,relhum)
%C
%C  This function calculates air density as function of air temperature,
%C  pressure and humidity. Based on A. Gill's book Atmosphere-Ocean
%C  Dynamics p 41.
%C
%C  AIRDEN ------------ Air density (kg/m^3)
%C  AIRTMP ------------ Air temperature (C)
%C  PRESS ------------- Barometric pressure (mb)
%C  P ----------------- Barometric pressure in Pascal (1 mb=100 Pa)
%C  RELHUM ------------ Relative humidity defined as W/Ws*100, where W is
%C                      the mixing ratio and Ws the saturation mixing ratio
%C  R ----------------- Gas constant for dry air (287.04 J/kg/K)
%C  VIRTMP ------------ Virtual temperature (C)
%C

rgas=287.04;
p=press*100.0;
h=p./(rgas.*(273.15+sw_virtmp(airtmp,press,relhum)));
