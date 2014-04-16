function [epsilon,unfreq,unspec,intervals]=fit_epsilon(fre,ss,fallspd,nu,intervals,kstart,kstop);
% function [epsilon,freun,specuniv,intervals]=...
%              fit_epsilon(fre,ss,fallspd,nu,intervals,kstart,kstop);
%
% fre is the frequency of the spectrum [Hz]. 
% ss  is the power spoectrum [s^{-1}^2 / Hz]
% fallspd is the fallspeed [m/s]
% nu is the water viscocity [m^2/s]
% intervals is a list of intervals to ignore in the fit to the
% universal spectra.
% frequencies in Hz.  i.e. to ignore data between 7 and 8 Hz:
%  > intervals = [7 8];
% to ignore all data lower than 5 Hz:
%  > intervals = [-Inf 5];
% to do both:
%  > intervals = [-Inf 5 7 8];
%
% outputs:
%  epsilon is the turbulent dissipation rate corresponding to the
%  universal spectrum fit to this data [m^2/s^3].
%  freun is the frequency of the universal spectrum associated we
%  fit [Hz].
%  unspec is the corresponding universal spectrum [s^{-1}^2 / Hz].
%  intervals is the intervals of data over which the fits were made
%  [Hz]
  
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:46 $ $Author: aperlin $

  
% get the basic Nasmyth spectra..
[specun,kun]=nasmyth(1000,20);

% convert fit ends to frequencies...
if exist('kstart')
  k_start=kstart;
else
    k_start = 2;
end;
if exist('kstop');
  k_end=kstop;
else
  k_end = 10;
end;

f_start= k_start * fallspd;
f_stop = max(2,k_end * fallspd);

% now lets get the intervals over which to integrate.  
if ~exist('intervals')
  intervals=[];
end;

if mod(length(intervals),2)
  error('Argument ''intervals'' must be an even length');
end;

% intervals should be an ordered set of start/stop pairs.  However
% we should be careful to catch overlaps and subsets...
intervals = fixintervals(intervals);  % see below...

irange=select_int_range(f_start,f_stop,intervals);

epsilon_unv=0;
epsilon = 7.5*nu*integrate_multi(irange,fre,ss);
epsilon_real=epsilon;

%  Do the following until our desired precision is reached:
while (abs(epsilon_unv/epsilon-1)>.01 & ~isnan(epsilon)) 
  [unfreq,unspec]=unv_spec(epsilon_real,nu,kun,specun,fallspd);
  epsilon_real=7.5*nu*integrate(unfreq(1),unfreq(end),unfreq,unspec);
  ks = ((epsilon_real/(nu^3))^.25 )/2/pi;
  if (ks>90)
    k_end = 45;
  elseif ((0.5 * ks) < 10 )
    k_end = 10;
  else 
    k_end = 0.5 * ks;
  end 
  f_stop = k_end * fallspd;
  irange=select_int_range(f_start,f_stop,intervals);
  epsilon=7.5*nu*integrate_multi(irange,fre,ss);
  % compute epsilon for the universal spectrum based on the limits above.
  epsilon_unv=7.5*nu*integrate_multi(irange,unfreq,unspec);
  epsilon_real=epsilon_real*epsilon/epsilon_unv;
end
% clean up some stuff at the end:
epsilon = epsilon_real;
k=fre/fallspd;
spec=ss*fallspd;
k_nas=unfreq/fallspd;
spec_nas=unspec*fallspd;
intervals = irange;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function intervals=fixintervals(intervals);
  % This fixes overlaps in the intervals so that they are monotonic
  % and all inclusive...
  start = intervals(1:2:end);
  stop = intervals(2:2:end);
  [start,ind]=sort(start);stop=stop(ind);
  bad = find(start(2:end)<stop(1:end-1));
  start(bad+1)=NaN;
  ind = find(stop(bad)<stop(bad+1));
  stop(bad(ind))=NaN;
  ind = find(stop(bad)>stop(bad+1));
  stop(bad(ind)+1)=NaN;
  good = find(~isnan(start));
  start=start(good);
  good = find(~isnan(stop));
  stop=stop(good);
  
  intervals = [start;stop];
  [m,n]=size(intervals);
  intervals=reshape(intervals,1,m*n);

  return;

% this replaces any cutfrequencies which start before or end after
% the f_start and f_stop frequencies.
function   therange=select_int_range(f_start,f_stop,cutfreq)
  
therange=[f_start cutfreq f_stop];
therange=therange(find(therange<=f_stop)); 
if rem(length(therange),2)
  therange=therange(1:end-1);
end
therange=therange(find(therange>=f_start)); 
if rem(length(therange),2)
  therange=therange(2:end);
end

  