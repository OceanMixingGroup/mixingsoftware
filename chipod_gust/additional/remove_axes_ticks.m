function  remove_axes_ticks(ax)
%%  remove_axes_ticks(ax)
% removes the Ticklabels form all plot that are not in the left colum and/or bottom row

   n_rows = size(ax,1);
   n_colums = size(ax,2);
    for i = 1:n_rows
      ia = n_rows-i+1;  % axis index count from top to bottom 
       for j = 1:n_colums
          if( i ~= 1 )
            set(ax(ia,j),'Xticklabel',[], 'Xlabel', []);
          end
          if( j ~= 1 )
            set(ax(ia,j),'Yticklabel',[], 'Ylabel', []);
          end
       end
    end
