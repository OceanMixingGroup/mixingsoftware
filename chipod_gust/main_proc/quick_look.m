function [data, head, figs] = quick_look(ddir, rfid)
%% [data, head, figs] = quick_look(ddir, rfid)
%
%         This function is meant to quickly look a given raw-file (chipod
%         or gust)   
%
%         INPUT (if nothing input via gui)
%           ddir     : directory to rawe file
%           rfid     : raw-file name
%
%        OUTPUT
%           figs     : cell array containing handles to all figures           
%           
%   created by: 
%        Johannes Becherer
%        Tue Nov 15 13:11:44 PST 2016


%_____________________read data______________________
 if nargin<2
   [data, head] = quick_calibrate;
 else
   [data, head] = quick_calibrate(ddir, rfid);
 end

 is_chipod = isfield(data, 'T1');

%_____________________plotting parametres______________________
 xl = data.time([1 end]);
 col = get(groot,'DefaultAxesColorOrder');
 


%_____________________fig for T,P______________________

 fig = figure('Color',[1 1 1],'visible','on','Paperunits','centimeters',...
         'Papersize',[30 20],'PaperPosition',[0 0 30 20]);
 
         [ax, ~] = create_axes(fig, 3, 1, 0);

         a = 1;
         if is_chipod
            pj = 1; p(pj) = plot(ax(a), data.time, data.T1, 'color', [col(pj,:) .3], 'Linewidth', 1);
            pj = 2; p(pj) = plot(ax(a), data.time, data.T2, 'color', [col(pj,:) .3], 'Linewidth', 1);
            pj = 1; p(pj) = plot(ax(a), data.time, qbutter( data.T1, .0001), 'color', [col(pj,:) .8], 'Linewidth', 2);
            pj = 2; p(pj) = plot(ax(a), data.time, qbutter( data.T2, .0001), 'color', [col(pj,:) .8], 'Linewidth', 2);
            legend(p, 'T1', 'T2');
         else
            pj = 1; p(pj) = plot(ax(a), data.time, data.T, 'color', [col(pj,:) .3], 'Linewidth', 1);
            pj = 1; p(pj) = plot(ax(a), data.time, qbutter( data.T, .0001), 'color', [col(pj,:) .8], 'Linewidth', 2);
         end
         xlim(ax(a), xl);
         ylabel(ax(a), ['^\circ C'])

         a = 2;
         pj = 1; p1(pj) = plot(ax(a), data.time, data.depth, 'color', [col(pj,:) .3], 'Linewidth', 1);
         pj = 1; p1(pj) = plot(ax(a), data.time, qbutter( data.depth, .0001), 'color', [col(pj,:) .8], 'Linewidth', 2);
            legend(p1, 'P');
         xlim(ax(a), xl);
         ylabel(ax(a), ['dbar'])

         a = 3;
         pj = 1; p1(pj) = plot(ax(a), data.time, data.W, 'color', [col(pj,:) .3], 'Linewidth', 1);
         pj = 1; p1(pj) = plot(ax(a), data.time, qbutter( data.W, .0001), 'color', [col(pj,:) .8], 'Linewidth', 2);
            legend(p1, 'W');
         xlim(ax(a), xl);
         ylabel(ax(a), ['volt'])

         datetick(ax(a), 'keeplimits');
         
         ax1 = ax; 
         linkaxes(ax1, 'x');
         clear ax;
         figs{1} = fig;
            

