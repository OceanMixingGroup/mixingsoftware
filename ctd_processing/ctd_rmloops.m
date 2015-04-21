  function data = ctd_rmloops(data, wthresh, updn)
% function data = ctd_rmloops(data, wthresh, updn)  
% eliminate depth loops in CTD data
% wthresh > 0 always
% updn = 1/0 for down/up where w is +/-

tsmooth = .25; % seconds
fs = 24; % Hz
np = length(data.p);
% :(  for ttide, package carrying LOTS of water with it, when it slows down
% water rushes past it, making apparent spike, seems to last for ~1.5
% meters :(  
%overshoot_depth=1.6; 
data.w = wsink(data.p, tsmooth, fs); % down/up +/-ve
iloop = [];

if updn
  % downcast
  flp = find(data.w < wthresh); 
  if length(flp)>=1
    ilp = findsegments(flp);
    nlp = length(ilp.start);
    for ii = 1:nlp
      pm = max(data.p(1:ilp.stop(ii)));
      pmi(ii) = min(find(data.p == pm));
      tmp = find(data.p(pmi(ii):end) < pm);
      wmin=min(data.w(ilp.start(ii):ilp.stop(ii)));
      % jen's totally ad-hoc line fit to crappy data, the lower the ctd
      % speed drops, the bigger a depth range is affected. 
%      overshoot_depth=-1.4*wmin+1.7; % this now in ctd_rmloops2
      overshoot_depth=-1.4*wmin+1;
      if pmi(ii) == length(data.p)
	iloop = [iloop; [pmi(ii)]];
      else
%	iloop = [iloop; [pmi(ii)+1; pmi(ii)+tmp-1]];
% new for ttide, 
       icont = find(data.p > (pm+overshoot_depth) & [1:np]' > ilp.stop(ii), 1, 'first');
%       iloop = [iloop; [ilp.start(ii):(icont+max(tmp)) - 1]'];
       iloop = [iloop; [ilp.start(ii):(icont) - 1]'];
      end
    end
  else
    nlp=[]; iloop=[];
  end
else 
  % upcast
  flp = find(data.w > -wthresh); 
  if length(flp)>1
    ilp = findsegments(flp);
    nlp = length(ilp.start);
    for ii = 1:nlp
      pm = min(data.p(1:ilp.stop(ii)));
%      pm = max(data.p(1:ilp.stop(ii)));
      pmi(ii) = find(data.p == pm);
      tmp = find(data.p(1:pmi(ii)) < pm);
      wmin=min(-data.w(ilp.start(ii):ilp.stop(ii)));
      overshoot_depth=-1.4*wmin+1.7+1.5; % 1.5 meter more on way up because ctd at bottom of rosette!
      if pmi(ii) == length(data.p)
	iloop = [iloop; [pmi(ii)]]
      else
       icont = find(data.p < (pm-overshoot_depth) & [1:np]' > ilp.stop(ii), 1, 'first');
%       iloop = [iloop; [ilp.start(ii):(icont+max(tmp)) - 1]'];
       iloop = [iloop; [ilp.start(ii):(icont) - 1]'];
      % iloop = [iloop; [pmi(ii); pmi(ii)-tmp]];
      end
%       icont = find(data.p < pm & [1:np]' > ilp.stop(ii), 1, 'first');
%       iloop = [iloop; [ilp.start(ii):icont - 1]'];
    end
  else
    nlp=[]; iloop=[];
  end
end

disp(['n loops = ' num2str(nlp)])
disp(['n data in loops = ' num2str(length(iloop))])

% close all
% plot(data.t1,data.p,'b')
% hold on
% scatter(data.t1(flp),data.p(flp),'k')
% hold on
% scatter(data.t1(iloop),data.p(iloop),'g')
% hold on
% scatter(data.t1(pmi),data.p(pmi),'k','filled')


% loop data = NaN
data.t1(iloop) = NaN;

%hold on
% plot(data.t1,data.p,'r')
% pause
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

figures = 0;

if figures
  figure
  ax(1) = subplot(211); plot(data.w); hold on; 
  plot(flp, data.w(flp), 'rx'); 
  plot(iloop, data.w(iloop), 'yo'); hold off
  ylabel('w'); title(['w < ' num2str(wthresh) ' m/s'])
  ax(2) = subplot(212); plot(data.p, 'bx'); hold on; 
  plot(flp, data.p(flp), 'rx'); 
  hold off; ylabel('p')
  linkaxes(ax, 'x')
  subplot(211); hold on; 
  subplot(212); hold on; plot(iloop, data.p(iloop), 'yo'); hold off
end  
