function [fig, ax] = time_plot(P, tl, Title, visib, dateT ) 
%% function [fig, ax] = timeseries2(P, tl, Title, visib, dateT ) 
%    generates a time series plot abitary number of time series
%     P{i}        : structure containing all information for a pannel (i) is panale
%     P{i}.X{j}   :  time arrays
%     P{i}.Y{j}   :  data arrays
%     P{i}.LL{j}  :  legend labels
%     P{i}.YL     :  Y-labels
%     P{i}.yl     :  Y-lims
%     tl          :  X-lims
%     Title       :  Title of the entire plot
%     visib       :  visibility of the figure
%     dateT       :  =0 no datetick , =1 datetick (default)

if(nargin<5)
    dateT = 1;
end

   % define colors
   cc = get(groot, 'DefaultAxesColorOrder');

   % check size of variables
   N = length(P);

   PaperY = 10*N
  fig = figure('Color',[1 1 1],'visible',visib,'Paperunits','centimeters',...
          'Papersize',[30 PaperY],'PaperPosition',[0 0 30 PaperY])

   % generate axes
   [ax, ~] = create_axes( fig, N, 1, 0 );


   abc = 'abcdefghijklmn';
   % plot graphs
   for i = 1:N

      hold(ax(i), 'on');
      for j = 1:length(P{i}.X)
         plot(ax(i), P{i}.X{j}, P{i}.Y{j}, 'color', cc(j,:), 'Linewidth', 1 );
      end
            plot(ax(i), tl, [0 0], '--k', 'Linewidth', 1);
            xlim(ax(i), tl);
            if(~isempty(P{i}.yl))
              ylim(ax(i), P{i}.yl);
            end
            ylabel(ax(i), P{i}.YL);
            %% legend   
            if isfield(P{i}, 'LL')
            switch length(P{i}.LL);
               case 1
                  legend(ax(i), P{i}.LL{1}, 'Location', 'south', 'orientation', 'horizontal');
               case 2
                  legend(ax(i), P{i}.LL{1}, P{i}.LL{2}, 'Location', 'south', 'orientation', 'horizontal');
               case 3
                  legend(ax(i), P{i}.LL{1}, P{i}.LL{2}, P{i}.LL{3}, ...
                     'Location', 'south', 'orientation', 'horizontal');
               case 4
                  legend(ax(i), P{i}.LL{1}, P{i}.LL{2}, P{i}.LL{3}, P{i}.LL{4}, ...
                     'Location', 'south', 'orientation', 'horizontal');
               case 5
                  legend(ax(i), P{i}.LL{1}, P{i}.LL{2}, P{i}.LL{3}, P{i}.LL{4}, P{i}.LL{5}, ...
                     'Location', 'south', 'orientation', 'horizontal');
               case 6
                  legend(ax(i), P{i}.LL{1}, P{i}.LL{2}, P{i}.LL{3}, P{i}.LL{4}, P{i}.LL{5}, P{i}.LL{6}, ...
                     'Location', 'south', 'orientation', 'horizontal');
               otherwise
                  disp('no legend')
            end
            end

            text_corner(ax(i), abc(i), 3);
            if(dateT)
                datetick(ax(i),'x','mm/dd', 'keeplimits');
                set(ax(i), 'Xticklabel', {}, 'TickDir', 'Out' );
            else
                if(i< length(P))
                    set(ax(i), 'Xticklabel', {}, 'TickDir', 'Out' );
                else
                    set(ax(i), 'TickDir', 'Out' );
                end
            end
   end
   %datetick(ax(end), 'x','keepticks', 'keeplimits');
   if(dateT)
    datetick(ax(end),'x','mm/dd', 'keeplimits');
    xlabel(ax(end), datestr(P{1}.X{1}(1), 'yyyy'));
   end

   text_corner(ax(1), Title , 5);
