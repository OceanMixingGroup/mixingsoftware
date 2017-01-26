function [cb] = correlation_plot(ax, xbins, ybins, X, Y)
%%  [cb] = correlation_plot(ax, xbins, ybins, X, Y)
%     makes a 2d-histogram in axes ax
%     and returns the axes handels for the colorbar 
%     depends on hist2d.m, cmap.mat, text_corner.m


% load colormaps
load cmap.mat;

            % remove nans
            X = X(~isnan(Y));
            Y = Y(~isnan(Y));
            Y = Y(~isnan(X));
            X = X(~isnan(X));

           [hist,mn,mdn,md] = hist2d(xbins, ybins, X, 0, Y, 0, 3);

            hold(ax,'on');
            pcolor(ax, xbins, ybins, hist);
               shading(ax,'flat');
               colormap(ax, cmap.chi);
               cl = [0 nanmax(nanmax(hist))];
               caxis(ax, cl)
               xlim(ax, xbins([1 end]));
               ylim(ax, ybins([1 end]));
                     Cor = corrcoef(X, Y);
                     text_corner(ax,[ num2str(real(Cor(2))*100, '%2.1f') '%'],9);
                  % add linear fit
                   %  [p, S] = polyfit(X{i}, Y{i}, 1);
                   %  Output = polyval(p,X{i}); 
                   %    text_corner(ax,[' Y = ' num2str(p(1), '%4.2f') ' X  + ' num2str(p(2), '%4.2f')],1);
                   %    plot(ax, bins([1 end]), polyval(p, bins([1 end])), 'b')
                   %    plot(ax, bins, mn, 'r')
                   %    plot(ax, bins, md, 'g')

%               plot(ax, xbins([1 end]), xbins([1 end]), 'k')


         
        %colorbar
        pax = get(ax,'Position');
        cb = axes('Position', [pax(1)+.3*pax(3) pax(2)+.95*pax(4) pax(3)*.4 .01]);
            hold(cb,'on');
            pcolor(cb, [cl(1):diff(cl)/10:cl(2)], [0 1],  [cl(1):diff(cl)/10:cl(2); cl(1):diff(cl)/10:cl(2)])
               colormap(cb, cmap.chi);
               shading(cb,'flat');
               set(cb,'box','on', 'Yticklabel', {});
               caxis(cb, cl);
               xlim(cb, cl);



                  
                  
         


