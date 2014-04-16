function [f] = sw_sathum(airtmp,press)
%C
%C  This function calculates the saturation specific humidity .
%C  The formula is from  A. Gill's book Atmosphere-Ocean Dynamics pp. 605-606
%C
%C
%C  SATPRS -----------  Saturation vapour pressure in mb
%C  SATHUM -----------  Saturation specific humidity
%C  AIRTMP -----------  Air temperature (C)
%C  PRESS ------------  Air pressure (mb)
%C

es=sw_satprs(airtmp,press);
f=0.62197./(press./es-0.37803);
