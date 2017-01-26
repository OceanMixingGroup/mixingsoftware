function [] = shift_axes(ax, dx, dy)
%% function [] = shift_axes(ax , dx, dy)
%        this function shifts a given set of axes ax 
%        by dx and dy 


for i = 1:prod(size(ax)) 
   set(ax(i), 'Position', get(ax(i), 'Position') + [dx dy 0 0] );
end
