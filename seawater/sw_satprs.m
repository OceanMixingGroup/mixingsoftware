function [d] = satprs(airtmp,press)
%C
%C  This function calculates the saturation vapour pressure in mb.
%C  The formula is from  A. Gill's book Atmosphere-Ocean Dynamics, p 606,
%C  and is correct to 1 part in 500 for temperatures between -40 to
%C  +40 degrees Celsius
%C
%C
%C  SATPRS -----------  Saturation vapour pressure in mb
%C  AIRTMP -----------  Air temperature (C)
%c  PRESS ------------  Air pressure (mb)
%C  Fw ---------------  Correction factor for the saturation vapour
%C                      pressure in air (Fw lies between 1 and 1.006
%C                      for observed atmospheric conditions)

d=10.0.^((0.7859+0.03477.*airtmp)./(1.0+0.00412.*airtmp));
fw=1.0+1.0E-6*press.*(4.5+0.0006.*airtmp.^2.0);
d=fw.*d;
