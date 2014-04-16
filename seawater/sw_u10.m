function [p] = sw_u10(uz,zz)
%C
%C  U10=sw_u10(uz,zz)
%C  This function calculates the wind speed at 10m height given the wind speed
%C  at height z. This function is based on W.G.Large and S.Pond JPO Vol. 11,
%C  No. 3, (March 1981) pp.324-336 formula 16. Note that neutral stability is
%C  assumed.
%C
%C  U10 ----------- The wind speed at 10 m height above the sea surface (m/s).
%C  UZ  ----------- The wind speed at Z m above the sea surface (m/s).
%C  ZZ   ---------- The height (m) at which the wind speed was measured.
%C  Cd  ----------- The drag coefficient calculated using function DRAG.
%C

kappa=0.4;
p=uz./(1+((sqrt(sw_drag(uz)))./kappa)*(log(zz/10.0)));
