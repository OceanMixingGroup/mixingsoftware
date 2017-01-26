function [ax, axc] = create_axes(fig, n_rows, n_colums, colorb)
%%[ax, axc] = create_axes(fig, n_rows, n_colums, colorb)
%     this function generates for a given figure "fig" 
%     a matrix of subplots "ax" with n_rows and n_colums
%         colorb = 0 for no colorbars
%         colorb = 1 colum of colorbars on the right
%         colorb = 2 for row of colorbars at the top

dx  = .02;  % lateral distance between plots
dy  = .02;  % vertical sitance between plots
cbw = .02;  % colorbar width


% generate the frame inside the figure
Fx = [.1 .97]; % xdimension of frame
Fy = [.1 .97]; % xdimension of frame   
               if(n_rows==1 & colorb~=0)
                   Fy = [.15 .9];
               end
   xw = (diff(Fx) - (n_colums-1)*dx)/n_colums;  % width of each subplot
   yw = (diff(Fy) - (n_rows-1)*dy)/n_rows;  % width of each subplot
   
   % colorbars 
     switch colorb 
        case 0
            axc = {};

        case 1
           Fx(2) = Fx(2) - dx  - .1; % make inner frame smaller
               xw = (diff(Fx) - (n_colums-1)*dx)/n_colums;  % width of each subplot
           for i = 1:n_rows
               ia = n_rows-i+1;  % axis index count from top to bottom 
               axc(ia) = axes('Position', [(Fx(2) + dx) ( Fy(1) + (i-1)*(dy+yw) + dy ) cbw (yw-2*dy)]);  
                  set(axc(ia),'Xticklabel',[],'Yaxislocation','right');
           end

        case 2
           Fy(2) = Fy(2) - dy - .1; % make inner frame smaller
               yw = (diff(Fy) - (n_rows-1)*dy)/n_rows;  % width of each subplot
           for i = 1:n_colums
               axc(i) = axes('Position', [(Fx(1) + (i-1)*(dx+xw) +dx) (Fy(2) + dy) (xw-2*dx) cbw]);  
                  set(axc(i),'Yticklabel',[],'Xaxislocation','top');
           end
        otherwise
            disp('colorb must be between 0 1 or 2');
     end

   ax = zeros(n_rows, n_colums);
   % main axix
    for i = 1:n_rows
      ia = n_rows-i+1;  % axis index count from top to bottom 
       for j = 1:n_colums
          ax(ia,j) = axes('Position', [(Fx(1) + (j-1)*(dx+xw)) (Fy(1) + (i-1)*(dy+yw)) xw yw]);  
          hold(ax(ia,j),'on');
       end
    end

    % remove wrong ticks
    remove_axes_ticks(ax);


