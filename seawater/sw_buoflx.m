function [o] = buoflx(sfcsal,sfctmp,precip,evap,qq,pretmp)
%C
%C  This function calculates the vertical surface buoyancy flux as
%C  induced by atmospheric factors. This function is based on Dorrestein's
%C  paper in JPO of Jan 1979 pp 229-231.
%C
%C  BUOFLX --------- surface buoyancy flux (positive if downward) (W/kg=m^2/s^3)
%C  SFCSAL --------- surface salinity (psu)
%C  SFCTMP --------- surface temperature (C)
%C  PRECIP --------- rate of precipitation (kg/m^2/s)
%C  EVAP ----------- rate of evaporation-condensation (kg/m^2/s)
%C  QQ ------------- sensible heat flux plus net radiation through
%C                   the surface (positive if upwards) (W/m^2)
%C  PRETMP --------- temperature of precipitated water (C)
%C  LL ------------- latent heat of evaporation (J/kg)
%C  CC ------------- specific heat of seawater at constant pressure
%C  ALPHA ---------- thermal expansion coefficient of seawater (1/K)
%C  BETA ----------- haline contraction coefficient (1/psu)
%C  RHO ------------ seawater density (kg/m^3)
%C
%C  NOTE: this program uses functions ALPHAP, BETAP, RHO and CP from library
%C  ====  OCEAN.
%C
%C                                                      DECEMBER 1989
grav=9.8;
ll=2.5008E6-2.3E3.*sfctmp;
alpha=sw_alphap(sfcsal,sfctmp,0.0);
beta=sw_betap(sfcsal,sfctmp,0.0);
cc=sw_cp(sfcsal,sfctmp,0.0);
deltmp=pretmp-sfctmp;
o=sfcsal.*beta.*(precip-evap)-(alpha./cc).*(ll.*evap+qq)+alpha.*deltmp.*precip;
o=-(grav./sw_dens(sfcsal,sfctmp,0.0)).*o;
