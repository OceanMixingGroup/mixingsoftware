function [n] = sw_rlngwv(sfctmp,airtmp,vapp,cldfrc,nfrml)
%C
%C  This function calculates the net longwave radiation at the ocean 
%C  surface, including correction for clouds.
%C  One can choose (via the variable NFRML) different formulas to calculate
%C  the net longwave radiation flux.
%C
%C  RLNGWV --------------  Net longawve radiation corrected for clouds (W/m^2)
%C  SFCTMP --------------  Sea surface temperature (C)
%C  AIRTMP --------------  Air temperature (C)
%C  VAPP   --------------  Atmospheric vapour pressure (mb)
%C  SIGMA ---------------  Stefan-Boltzmann constant=5.6696E-8 W/m^2/K^4
%C  EMISS ---------------  Sea surface emissivity=0.97
%C  CLDFRC --------------  Cloud cover (fractions)
%C  NFRML ---------------  The number of the formula to be used
%C  
%C  The following formulae are all given in the paper by J.J. Simpson
%C  and A. Paulson's paper in Quart. J. R. Met. Soc. (1979), 105 pp.487-502
%C
%C   							December 1989

sigma=5.6696E-8;
emiss=0.97;

sfct=sfctmp+273.15;
airt=airtmp+273.15;

%C  Anderson's (1952) formula 
%C  Berliand's (1960) formula
%C  Brunt's (1932) formula
%C  Efimova's (1974) formula
%C  Swinbank's (1963) formula

if (nfrml==1)
	n=emiss*sigma*(sfct.^4.0-(airt.^4.0).*(0.74+0.0049.*vapp));
	n=n.*(1.0-0.8*cldfrc);
elseif (nfrml==2)
	n=emiss*sigma*(sfct.^4.0).*(0.39-0.05.*sqrt(vapp))+4.0*emiss*sigma*(sfct.^3.0).*(sfct-airt);
	n=n.*(1.0-0.8*cldfrc);
elseif (nfrml==3)
	n=emiss*sigma*(sfct.^4.0).*(0.39-0.05.*sqrt(vapp));
	n=n.*(1.0-0.8*cldfrc);
elseif (nfrml==4)
	n=emiss*sigma*(sfct.^4.0).*(0.254-0.00495.*vapp);
	n=n.*(1.0-0.8*cldfrc);
elseif (nfrml==5)
	n=emiss*sigma*(sfct.^4.0).*(1.0-9.35E-6.*sfct.^2.0);
	n=n.*(1.0-0.8*cldfrc);
end;

