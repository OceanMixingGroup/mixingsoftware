    function visc=sw_visc_ctdchi(s,t,p)
%
%    function visc=sw_visc_ctdchi(s,t,p)
%  
% Slightly modified version of sw_visc to work with CTD_Chipod software.
% Just added .* and ./ notation to work with vectors of t,s,p.
% A. Pickering - Mar 25 2015.
%
%  kinematic viscosity (nu) (no pressure dependence examined)
%
%  based on dan kelley's fit to knauss's table ii-8
%
%  s  salinity (ppt)
%  t  temperature (deg. c)
%  p  pressure (dbars)
%
%  visc  kinematic viscosity  (m**2 s-1)
% 
%  visc(40.,40.,1000.)=8.200167608e-7
%
%                                        dave hebert  11/04/86
%
% renamed sw_visc and added to seawater routines 9/9/98

      %visc=1e-4*(17.91-0.5381*t+0.00694*t*t+0.02305*s)/sw_dens(s,t,p);
      
      visc=1e-4*(17.91-0.5381.*t+0.00694.*t.*t+0.02305.*s)./sw_dens(s,t,p);
      
      %%