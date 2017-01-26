function [] = mooring_sketch(ax, depth, z, L, col, fs)
%% [] = mooring_sketch(ax, depth, z, L, col, fs)
%     paints a mooring sketch in axis ax
%        with water depth (positive)
%        z = negative 0 at surface
%        L = labels (cell size z)
%        col = colors (size z,3)
%        fs = font sizes (size z)


 if(length(fs==1))
    fs = ones(size(z))*fs;
 end


 hold(ax,'on');
 
 set(ax, 'visible', 'off', 'color', 'none')
 %patch( [.7 .3 .3 .7], [-1 -1 0 0]*depth,  [.7 .7 1] , 'facealpha', .5, 'parent', ax);
 yl = [(-1-.1)*depth .1*depth];
 ylim(ax, yl);
 xl = [.3 .7];
 xlim(ax, xl);
 
 plot(ax, [.5 .5], [-depth 0], 'color', [.5 .5 .5], 'Linewidth', 3);
 plot(ax, [.3 .7], [-depth -depth], 'color', [0 0 0], 'Linewidth', 4);
 plot(ax, [.3 .7], [0 0], 'color', [.5 .5 1], 'Linewidth', 3);
 
 for i=1:length(z)
   plot(ax, [.45 .55], [1 1]*z(i), 'color', [col(i,:)], 'Linewidth', 2);
   text(.45,z(i), [ num2str(z(i)) ' m '] ,'verticalalignment', 'middle' ,'horizontalalignment','right',...
      'Fontsize', min(fs), 'color', [0 0 0], 'parent', ax)
   text(.56,z(i), L{i} ,'verticalalignment', 'middle' ,'horizontalalignment','left',...
      'Fontsize', fs(i), 'color', col(i,:), 'parent', ax)
 end
   text(.5,-depth, ['depth = ' num2str(depth) ' m '] ,'verticalalignment', 'top' ,'horizontalalignment','center',...
      'Fontsize', max(fs), 'color', [0 0 0], 'parent', ax)
 
 
