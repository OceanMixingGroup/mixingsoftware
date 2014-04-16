function [ss,ks]=unv_spec_matrix(epsilon_re,nu,fspd,f)
% function [unspec,kolmogoroff]=unv_spec_matrix(epsilon_re,nu,fspd,f)
%
% Universal spectrum for a given epsilon (epsilon_re).  f2 is the
% universal spectrum and kks is the wavenumbers at which the
% spectrum was evaluated.  fspd is the profiler fall speed and nu
% the viscocity of water. 
  
  
% function to calculate the universal spectrum corresponding to this epsilon...
% note that ks is defined in terms of radian wavenumber


% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $
  
 if length(fspd)==1
   fspd = fspd+0*epsilon_re;
 end;
 if length(nu)==1
   nu = nu+0*epsilon_re;
 end;
 
  k = f*(1./fspd);
  toreshape =ones(length(f),1); 
  
  % need normalized spectra....
  ks=(epsilon_re./(nu.^3)).^.25;
  % dimensionles wave number....
  k1 = k./(toreshape*ks);
  % dimensionless Nasmyth spectrum....
  alpha=58.8276*k1;
  a1=alpha.^4 - 45*alpha.^2 + 105;
  a2=-10*alpha.^2. + 105;
  sp=855.17*(k1.^0.333)./sqrt(a1.^2. + (alpha.^2).*(a2.^2)) ;% [rad^-2]  
  
  % dimensional spectrum...
  ss=sp.*(toreshape*((epsilon_re.*nu.^5).^0.25.*ks.^2./fspd));
    
    