function gout=gammest(gin)
% GAMMEST - used by AR1 to compute
% a function for minimization by fzero.
% CEE_ZERO, CEE_ONE, and NPOINTS are globals.
%
% Written by Eric Breitenberger.      Version 1/21/96
% Please send comments and suggestions to eric@gi.alaska.edu       
%
 
global CEE_ZERO CEE_ONE NPOINTS

N=NPOINTS;
g0=CEE_ONE/CEE_ZERO;

gk=1:N-1;
gk=gin.^gk;
mu2=(1/N)+(2/N^2)*sum((N-1:-1:1).*gk);
gout=(1-g0)*mu2+g0-gin;

%disp(['Iterating in gammest: dg=' num2str(gout)])
