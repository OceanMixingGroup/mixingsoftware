function tdif=sw_tdif(s,t,p)
% function tdif=tdif(s,t,p)
%  temperature diffusivity  (m2 s-1)
%
%  uses functions sw_cp, sw_dens, sw_tcond
%
%                          dave hebert   15/04/86
      tdif=sw_tcond(s,t,p)/sw_cp(s,t,p)/sw_dens(s,t,p);
