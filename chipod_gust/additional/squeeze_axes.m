function [] = squeeze_axes(ax, fx, fy)
%% function [] = squeeze_axes(ax , fx, fy)
%        this function squeezes a given set of axes ax 
%        by factor fx in the horizintal  and fy in the vertical 

ox = 1;
oy = 1;
ex = 1;
ey = 1;


for i = 1:prod(size(ax))
   tmp = get(ax(i), 'Position');
      ox = min(ox, tmp(1));
      oy = min(oy, tmp(2));
   set(ax(i), 'Position', get(ax(i), 'Position').*[fx fy fx fy] );
   tmp = get(ax(i), 'Position');
      ex = min(ex, tmp(1));
      ey = min(ey, tmp(2));
end

% remove off-set  
ep = get(ax(1), 'Position');
shift_axes(ax, ox-ex, oy-ey);
