  function y = tms_tc_glitchcorrect(x, diffx, prodx, ibefore, iafter, varargin)
% function y = tms_tc_glitchcorrect(x, diffx, prodx, ibefore, iafter, figures_on)
%
% from SeaSoar/Data/iwap/matlab/glitchcorrect.m
%
if nargin == 6
  figures_on = varargin{:};
else
  figures_on = 0;
end
%
figures_on=0;
% test
% x = SBC1; diffx = 30; prodx = 1000; ibefore = 1; iafter = 1; figures_on = 1;
% x = SBT2; diffx = 50; prodx = 3000; ibefore = 1; iafter = 1; figures_on = 1;
%
tstr = strrep(inputname(1), '_', '\_');
dx = diff(x);
nx = length(dx);
y = x;
%
dmin2 = min(abs(dx(1:nx-1)), abs(dx(2:nx)));  
dmin3 = min(abs(dx(1:nx-2)), abs(dx(3:nx)));  
%dmin4 = min(abs(dx(1:nx-3)), abs(dx(4:nx)));  
dmul2 = -dx(1:nx-1).*dx(2:nx);                   % glitch > 0
dmul3 = -dx(1:nx-2).*dx(3:nx);                   
%dmul4 = -dx(1:nx-3).*dx(4:nx);                   
%
ii2 = find(dmul2 > prodx & dmin2 > diffx);
ii3 = find(dmul3 > prodx & dmin3 > diffx);
%ii4 = find(dmul4 > prodx & dmin4 > diffx);
ii2 = unique([ii2; ii2 + 1]);
ii3 = unique([ii3; ii3 + 1; ii3 + 2]);
%ii4 = unique([ii4; ii4 + 1; ii4 + 2; ii4 + 3]);
%ii = unique([ii2; ii3; ii4]);
ii = unique([ii2; ii3]);
jj2 = inearby(ii2, ibefore, iafter, nx);
jj3 = inearby(ii3, ibefore, iafter, nx);
%jj4 = inearby(ii4, ibefore, iafter, nx);
%jj = unique([jj2; jj3; jj4]);
jj = unique([jj2; jj3]);
%
if isempty(jj)
%  disp(['tms_tc_glitchcorrect: no spikes ' inputname(1)])
  y = x;
else
%  disp(['tms_tc_glitchcorrect: despiking ' inputname(1)])
  y = interpbadsegments(x, jj + 1);
end
%
if figures_on
  dy = diff(y);
  ax(1) = subplot(211);
  plot(dx, 'b');                                % original data
  hold on; 
  plot([1 nx], [diffx diffx], 'k--')            % limits
  plot([1 nx], -[diffx diffx], 'k--')
  plot([1 nx], [prodx prodx].^0.5, 'k-.')
  plot([1 nx], -[prodx prodx].^0.5, 'k-.')
  plot(dy, 'Color', [0 0.5 0]);                 % fixed data
  plot(jj, dx(jj), 'kx', 'MarkerSize', 10);     % all nearby bad points 
  plot(jj, dy(jj), 'ko', 'MarkerSize', 10);     % all fixed nearby bad points
  plot(ii, dx(ii), 'rx', 'MarkerSize', 10);     % primary bad points
  plot(ii, dy(ii), 'ro', 'MarkerSize', 10);     % fixed primary bad points
  grid
  hold off
  title(['tms\_tc\_glitchcorrect ' tstr])
  ylabel(['\Delta ' tstr])
  ax(2) = subplot(212);
  plot(x, 'b')
  hold on
  plot(y, 'Color', [0 0.5 0]);
  plot(jj + 1, x(jj + 1), 'kx', 'MarkerSize', 10);      % all nearby bad points 
  plot(jj + 1, y(jj + 1), 'ko', 'MarkerSize', 10);      % all fixed nearby bad points
  plot(ii + 1, x(ii + 1), 'rx', 'MarkerSize', 10);      % primary bad points
  plot(ii + 1, y(ii + 1), 'ro', 'MarkerSize', 10);      % fixed primary bad points
  grid
  hold off
  ylabel(tstr)
  linkaxes(ax, 'x');
  drawnow
  %
  %histograms
  %figure 
  %subplot(211); 
  %[yhp, xhp] = hist(dmul3(find(dmul3 > 0)).^0.5, 20); semilogy(xhp, yhp, 'x'); hold on; 
  %title(['tms\_tc\_glitchcorrect ' tstr ...
  %'  hist(dmul3)   line = good, x = possible glitch'])
  %[yhm, xhm] = hist(abs(dmul3(find(dmul3 < 0))).^0.5, 20); semilogy(xhm, yhm, 'r'); hold off;
  %subplot(212); [yh, xh] = hist(dmin3, 20); semilogy(xh, yh); title('hist(dmin3)')
end
