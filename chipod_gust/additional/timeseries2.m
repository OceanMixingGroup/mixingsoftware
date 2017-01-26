function [fig, ax] = timeseries2(X1, X2, Y1, Y2, LL1, LL2, YL, Ylims, tl, Title, visib ) 
%% function [fig, ax] = timeseries2(X1, X2, Y1, Y2, LL1, LL2, YL, Ylims, tl, Title, visib ) 
%    generates a time series plot two time series
%     X1, X2   :  time arrays
%     Y1, Y2   :  data arrays
%     LL1, LL2 :  legend labels
%     YL       :  Y-labels
%     YLims    :  Y-lims
%     tl       :  X-lims
%     Title    :  Title of the entire plot
%     visib    :  visibility of the figure

   % define colors
   c1 = [.7 .3 .3];
   c2 = [.3  .3 .7];

   % check size of variables
   N = length(X1);
   if ~( size(X1)==size(X2) |  size(X1)==size(Y1) | size(X1)==size(Y2) |...
      size(X1)==size(LL1) | size(X1)==size(LL2) | size(X1)==size(YL) |...
      size(X1)==size(Ylims) )

      disp('X1, X2, Y1, Y2, LL1, LL2, YL, YLims must all have same number of cell {N}')
      
   end

   PaperY = 7*N
  fig = figure('Color',[1 1 1],'visible',visib,'Paperunits','centimeters',...
          'Papersize',[30 PaperY],'PaperPosition',[0 -1 30 PaperY])

   % generate axes
   [ax, ~] = create_axes( fig, N, 1, 0 );


   abc = 'abcdefghijklmn';
   % plot graphs
   for i = 1:N

      plot(ax(i), X1{i}, Y1{i}, 'color', c1);
         hold(ax(i), 'on');
      plot(ax(i), X2{i}, Y2{i}, 'color', c2);
         plot(ax(i), tl, [0 0], '--k', 'Linewidth', 1);
         xlim(ax(i), tl);
         ylim(ax(i), Ylims{i});
         ylabel(ax(i), YL{i});
         legend(ax(i), LL1{i}, LL2{i}, 'Location', 'south', 'orientation', 'horizontal');
         text_corner(ax(i), abc(i), 3);
         datetick(ax(i), 'x','keepticks', 'keeplimits');
         set(ax(i), 'Xticklabel', {}, 'TickDir', 'Out' );
   end
   datetick(ax(end), 'x','keepticks', 'keeplimits');

   text_corner(ax(1), Title , 5);
