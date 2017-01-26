function [axb, axf] = copy_axes(ax)  
%% function [axb, axf] = copy_axes(ax)  
%     this function copies a given set of axes (ax) 
%     generating a second set (axb) in the back 
%     and a third set (axf) above of the original axes
%     those axis than can be used for labeling or
%     highlighting patches

for i = 1:prod(size(ax))
   % remove background color of original axes
   set(ax(i), 'Color','none');

   % generate background axes
   axb(i) = axes( 'Position', get(ax(i), 'Position'),...
            'Color', 'none', 'Xtick', [], 'Ytick', []);
       hold(axb(i), 'on');     
       set(axb(i), 'Xlim', get(ax(i), 'Xlim'), 'Ylim', get(ax(i), 'Ylim'));
   uistack(axb(i),'bottom');   % move axes under original axes
   hold(axb(i), 'on');
      
   % generate forground axes
   axf(i) = axes( 'Position', get(ax(i), 'Position'),...
            'Color', 'none', 'Xtick', [], 'Ytick', []);
       hold(axf(i), 'on');     
       set(axf(i), 'Xlim', get(ax(i), 'Xlim'), 'Ylim', get(ax(i), 'Ylim'));
   uistack(axf(i),'top');   % move axes above original axes
   hold(axf(i), 'on');
end
