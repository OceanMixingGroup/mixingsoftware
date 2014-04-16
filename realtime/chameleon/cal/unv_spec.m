function [unfreq,unspec]=unv_spec2(epsilon_re,nu,kks,f2,fspd)
    % function to calculate the universal spectrum corresponding to this epsilon...
    % note that ks is defined in terms of radian wavenumber
    ks=(epsilon_re/(nu^3))^.25;
    unfreq=ks*kks*fspd;
    unspec=(epsilon_re*nu^5)^0.25*ks^2/fspd*f2;
  