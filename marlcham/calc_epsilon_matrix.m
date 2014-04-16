function [epsilon,unspec] = calc_epsilon_matrix(f,ss,fallspd,nu);
% function [epsilon,unspec] = calc_epsilon_matrix(f,ss,fallspd,nu);
% Calculate a bunch of epsilons based on spectral estimates in ss.
%
% ss is a number of spectral estimates m x n
% f is the frequencies m x 1
% fallspd and nu are the fallspeeds and viscocity for each estimate
%   1 x n
%
% $Revision: 1.2 $ $Date: 2011/05/17 17:11:05 $ $Author: aperlin $	
% Originally, JKlymak May,2002
  k_start = 0;
  k_stop = 10;
  kstop_coef = 0.5;
% get the dfreq for the integrations..
df = median(diff(f));
dk = df*ones(size(f,1),1)*fallspd;
% get the wavenumber (whic is where we do our cut-offs...
k = f*fallspd;
mask = ss*0+1;
bad = find(k<k_start);
mask(bad)=NaN;
bad = find(k>k_stop);
mask(bad)=NaN;
epsilon_unv = 0*fallspd;
epsilon = 7.5*nu.*nansum(ss.*df);
epsilon_real = epsilon;
num = 0;
niterations=5;
while (max(abs(epsilon_unv./epsilon-1))>.01 && num<=niterations)
  num = num+1;
  [unspec,ks]=unv_spec_matrix2(epsilon_real,nu,fallspd,f);
  % figure the high wavenumber to integrate to...
  k_end = ks*kstop_coef;
  % don't go above 10 cpm;
  in = find(k_end>10);
  k_end(in) = 10;
  % convert to a frequency.
  % f_stop = k_end.*fallsp;
  bad = find(k>k_stop);
  mask = 0*ss;
  mask(bad) = NaN;
  epsilon=7.5*nu.*nansum(ss+mask)*df;
  epsilon_unv=7.5*nu.*nansum(unspec+mask)*df;
  epsilon_real=epsilon_real.*epsilon./epsilon_unv;  
end;
if num>niterations
  bad = find(abs(epsilon_unv./epsilon-1)>.01);
  epsilon_real(bad) = NaN;
  warning('Epsilon didn''t converge very nicely');
end;
epsilon = epsilon_real;
% keyboard;
doplot=0;
if doplot
  loglog(f,unspec,f,ss)
end;









