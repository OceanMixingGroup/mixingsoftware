function tdif=tdif(s,t,p)
% function tdif=tdif(s,t,p)
%  temperature diffusivity  (m2 s-1)
%
%  uses functions cp, rho, tcond
%
%                          dave hebert   15/04/86
      tdif=tcond(s,t,p)/cp(s,t,p)/sw_dens(s,t,p);
