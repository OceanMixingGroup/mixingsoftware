function [g,a,mu2]=ar1(x)
% AR1 - Allen and Smith AR(1) model estimation. 
% Syntax: [g,a,mu2]=ar1(x);
%
% Input:  x - time series (univariate).
%
% Output: g - estimate of the lag-one autocorrelation.
%         a - estimate of the noise variance.
%         mu2 - estimated square on the mean.
%
% AR1 uses the algorithm described by Allen and Smith 1995, except
% that Matlab's 'fzero' is used rather than Newton-Raphson.
%
% Fzero in general can be rather picky - although
% I haven't had any problem with its implementation
% here, I recommend occasionally checking the output
% against the simple estimators in AR1NV.
%
% Written by Eric Breitenberger.      Version 1/21/96
% Please send comments and suggestions to eric@gi.alaska.edu       
%

global CEE_ZERO CEE_ONE NPOINTS

x=x(:);
N=length(x);
NPOINTS=N;
m=mean(x);
x=x-m;

% Lag zero and one covariance estimates:
c0=x'*x/N;
CEE_ZERO=c0;
c1=x(1:N-1)'*x(2:N)/(N-1);
CEE_ONE=c1;

g0=c1/c0; % Initial estimate for gamma

% Find g by getting zero of 'gammest':
g=fzero(@gammest, g0,optimset('tolx',.000001)); %-updated to accomodate newer versions of matlab

gk=1:N-1;
gk=g.^gk;
mu2=(1/N)+(1/N^2)*2*sum((N-1:-1:1).*gk);

c0est=c0/(1-mu2);
a=sqrt((1-g^2)*c0est);

