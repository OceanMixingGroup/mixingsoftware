function tdif=sw_tdif_ctdchi(s,t,p)
% function tdif=tdif(s,t,p)
%
% Slightly modified version of sw_tdif to work with CTD_Chipod software.
% Just added .* and ./ notation to work with vectors of t,s,p.
% A. Pickering - Mar 25 2015.
%
%  temperature diffusivity  (m2 s-1)
%
%  uses functions sw_cp, sw_dens, sw_tcond
%
%                          dave hebert   15/04/86
%      tdif=sw_tcond(s,t,p)/sw_cp(s,t,p)/sw_dens(s,t,p);
 
tdif=sw_tcond_ctdchi(s,t,p)./sw_cp(s,t,p)./sw_dens(s,t,p);
