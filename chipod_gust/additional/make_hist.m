function [] = make_hist(ax,X,bins, varargin)
% function [] = make_hist(ax,X,bins,XL,YL,LL, varargin)


         hold(ax,'on')
         for i = 1:length(X)
            histogram(ax, real(X{i}), bins, 'normalization', 'probability')
               set(ax, 'Yaxislocation', 'right', 'Ycolor', [1 1 1])
               xlim(ax, bins([1 end]));
         end
