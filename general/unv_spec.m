function [unfreq,unspec]=unv_spec(epsilon_re,nu,kks,f2,fspd)
% function [unfreq,unspec]=unv_spec(epsilon_re,nu,kks,f2,fspd)
%
% Universal spectrum for a given epsilon (epsilon_re).  f2 is the
% universal spectrum and kks is the wavenumbers at which the
% spectrum was evaluated.  fspd is the profiler fall speed and nu
% the viscocity of water. 
  
  
% function to calculate the universal spectrum corresponding to this epsilon...
% note that ks is defined in terms of radian wavenumber


% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $
  
    ks=(epsilon_re/(nu^3))^.25;
    unfreq=ks*kks*fspd;
    unspec=(epsilon_re*nu^5)^0.25*ks^2/fspd*f2;
    
    