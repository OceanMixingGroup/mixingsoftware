  function data = ctd_rmdepthloops(data)
% function data = ctd_rmdepthloops(data)  
% eliminate depth loops in CTD data
  
tsmooth = 1; % seconds
fs = 24; % Hz
[pmax, ipmax] = max(data.p);
np = length(data.p);
data.w = wsink(data.p, tsmooth, fs); % down/up +/-ve
wthresh = 0.1; 

% downcast
fup = find(data.w < wthresh & [1:np]' <= ipmax);
iup = findsegments(fup);
nup = length(iup.start);
iloop = [];
for ii = 1:nup
  pm = max(data.p(1:iup.stop(ii)));
  icont = find(data.p > pm & [1:np]' > iup.stop(ii), 1, 'first');
  iloop = [iloop; [iup.start(ii):icont]'];
end

% upcast
fdn = find(data.w > -wthresh & [1:np]' > ipmax);
idn = findsegments(fdn);
ndn = length(idn.start);
for ii = 1:ndn
  pm = min(data.p(ipmax + 1:idn.stop(ii)));
  icont = find(data.p < pm & [1:np]' > idn.stop(ii), 1, 'first');
  iloop = [iloop; [idn.start(ii):icont]'];
end

figure
ax(1) = subplot(211); plot(data.w); hold on; 
plot(fup, data.w(fup), 'rx'); 
plot(fdn, data.w(fdn), 'rx'); 
plot(iloop, data.w(iloop), 'yo'); hold off
ylabel('w'); title(['w < ' num2str(wthresh) ' m/s'])
ax(2) = subplot(212); plot(data.p, 'bx'); hold on; 
plot(fup, data.p(fup), 'rx'); 
plot(fdn, data.p(fdn), 'rx');
hold off; ylabel('p')
linkaxes(ax, 'x')
subplot(211); hold on; 
subplot(212); hold on; plot(iloop, data.p(iloop), 'yo'); hold off

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


