function [data,loop_inds] = ctd_rmdepthloops(data,extra_z,wthresh)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [data,loop_inds] = ctd_rmdepthloops(data,extra_z,wthresh)
%
% Eliminate depth loops in CTD data.
%
% INPUT
% data    : Structure with ctd data
% extra_z : # of extra m to get rid of due to CTD pressure loops.
% wthresh : Threshold vertical velocity (data bad if w less than this
% value)
%
% OUTPUT
% data      : CTD data with data during loops (loop_inds) removed.
% loop_inds : Indices of data with loops
%
% Additional comments added by AP 24 Mar 2015
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

tsmooth = 1; % seconds
fs = 24; % Hz
[pmax, ipmax] = max(data.p);
np = length(data.p);
data.w = wsink(data.p, tsmooth, fs); % down/up +/-ve

% downcast
fup = find(data.w < wthresh & [1:np]' <= ipmax);
iup = findsegments(fup);
nup = length(iup.start);
iloop = [];
for ii = 1:nup
    pm = max(data.p(1:iup.stop(ii)))+extra_z;
    icont = find(data.p > pm & [1:np]' > iup.stop(ii), 1, 'first');
    iloop = [iloop; [iup.start(ii):icont]'];
end

% upcast
fdn = find(data.w > -wthresh & [1:np]' > ipmax);
idn = findsegments(fdn);
ndn = length(idn.start);
for ii = 1:ndn
    %  pm = min(data.p(ipmax + 1:idn.stop(ii)));
    pm = min(data.p(ipmax + 1:idn.stop(ii)))-extra_z;
    icont = find(data.p < pm & [1:np]' > idn.stop(ii), 1, 'first');
    iloop = [iloop; [idn.start(ii):icont]'];
end

loop_inds=iloop;

% loop data = NaN
data.t1(iloop) = NaN;
data.t2(iloop) = NaN;
data.c1(iloop) = NaN;
data.c2(iloop) = NaN;
data.s1(iloop) = NaN;
data.s2(iloop) = NaN;
data.theta1(iloop) = NaN;
data.theta2(iloop) = NaN;
data.sigma1(iloop) = NaN;
data.sigma2(iloop) = NaN;
data.oxygen(iloop) = NaN;
data.trans(iloop) = NaN;
data.fl(iloop) = NaN;

return

%%