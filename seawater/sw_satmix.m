function [e] = satmix(airtmp,press)
%C
%C  This function calculates the saturation mixing ratio .
%C  The formula is from  A. Gill's book Atmosphere-Ocean Dynamics pp. 605-606
%C
%C
%C  SATPRS -----------  Saturation vapour pressure in mb
%C  SATMIX -----------  Saturation mixing ratio
%C  AIRTMP -----------  Air temperature (C)
%C  PRESS ------------  Air pressure (mb)
%C

es=sw_satprs(airtmp,press);
e=0.62197.*es./(press-es);
