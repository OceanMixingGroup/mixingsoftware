function [varargout] = make_histogram(X,Y,bins,cl,XL,YL,LL, vis, varargin)
%% [fig] = make_histogram(X,Y,bins,cl,XL,YL,LL, vis)
% reurns a 2D histogram_figure for X,Y
% where X{1}, X{2} ... producees (length(X)) subplots
% cl limet for colorbar
% XL{} label for X
% YL{} label Y
% LL{} general label
% vis figure visible 'off', 'on'

% load colormaps
load  cmap.mat;

%% Big title
if nargin == 9
   TT = varargin{1};
else
   TT = {};
end


N = length(X);

    fig = figure('Color',[1 1 1],'visible',vis,'Paperunits','centimeters',...
            'Papersize',[35 11*N],'PaperPosition',[0 0 35 11*N])

        [ax, axc] = create_axes(gcf, N, 3, 2);


        for i = 1:N
            % remove nans
            X{i} = X{i}(~isnan(Y{i}));
            Y{i} = Y{i}(~isnan(Y{i}));
            Y{i} = Y{i}(~isnan(X{i}));
            X{i} = X{i}(~isnan(X{i}));



           [hist,mn,mdn,md] = hist2d(bins, bins, X{i}, 0, Y{i}, 0, 3);

            hold(ax(i),'on');
            pcolor(ax(i), bins, bins, hist);
               shading(ax(i),'flat');
               colormap(ax(i), cmap.chi);
               caxis(ax(i), cl)
               xlim(ax(i), bins([1 end]));
               ylim(ax(i), bins([1 end]));
               %ylabel(ax(i), YL{i});
               text_corner(ax(i), XL{i}, 9);
               text_corner(ax(i),YL{i},1);
                  % add linear fit
                   %  [p, S] = polyfit(X{i}, Y{i}, 1);
                   %  Output = polyval(p,X{i}); 
                     Cor = corrcoef(X{i}, Y{i});
                      text_corner(ax(i),[ num2str(real(Cor(2))*100, '%2.1f') '%'],6);
                   %    text_corner(ax(i),[' Y = ' num2str(p(1), '%4.2f') ' X  + ' num2str(p(2), '%4.2f')],1);
                   %    plot(ax(i), bins([1 end]), polyval(p, bins([1 end])), 'b')
                   %    plot(ax(i), bins, mn, 'r')
                   %    plot(ax(i), bins, md, 'g')

                       plot(ax(i), bins([1 end]), bins([1 end]), 'k')


        end
         
        %colorbar
            hold(axc(1),'on');
            pcolor(axc(1), [cl(1):.001:cl(2)], [0 1],  [cl(1):.001:cl(2); cl(1):.001:cl(2)])
               colormap(axc(1), cmap.chi);
               caxis(axc(1), cl);
               xlim(axc(1), cl);

            set(axc(2),'visible','off ')
            set(axc(3),'visible','off ')

        for i = 1:N
           iax = N+i;
            hold(ax(iax),'on')
            histogram(ax(iax), real(X{i}), bins, 'normalization', 'probability')
            histogram(ax(iax), real(Y{i}), bins, 'normalization', 'probability')
               set(ax(iax), 'Yaxislocation', 'right', 'Ycolor', [1 1 1])
               xlim(ax(iax), bins([1 end]));
               % draw median values
               yl_all(i,:) = get(ax(iax),'Ylim');

           %% relative histogram    
           iax2 = 2*N+i;
            hold(ax(iax2),'on')
            bins2 = [-2:.05:2];
            histogram(ax(iax2), log10(10.^real(Y{i})./10.^real(X{i})), bins2, 'normalization', 'probability')
               set(ax(iax2), 'Yaxislocation', 'right', 'Ycolor', [1 1 1])
               xlim(ax(iax2), bins2([1 end]));
               %ylim(ax(iax2),[0 .15]);
               yl_all2(i,:) = get(ax(iax2),'Ylim');
        end
   
        [~, iyl] = max(yl_all(:,2));
        yl = yl_all(iyl,:)
        for i = 1:N
           iax = N+i;
                  ylim(ax(iax), yl);
                  plot(ax(iax), log10(nanmean(10.^(real(X{i})))), yl(2)-diff(yl)/5, '+k') 
                  plot(ax(iax), nanmedian(real(X{i})), yl(2)-diff(yl)/5, 'xk') 
                  plot(ax(iax), log10(nanmean(10.^(real(X{i})))), yl(2)-diff(yl)/5, '+b') 
                  plot(ax(iax), nanmedian(real(X{i})), yl(2)-diff(yl)/5, 'xb') 
                  plot(ax(iax), log10(nanmean(10.^(real(Y{i})))), yl(2)-diff(yl)/5, '+r') 
                  plot(ax(iax), nanmedian(real(Y{i})), yl(2)-diff(yl)/5, 'xr') 

                  %t  = text_corner(ax(iax), ['log_{10}(\langle\chi\rangle/\langle\chi_{ref}\rangle) = '...
                  %      num2str(log10(nanmean(10.^(real(Y{i})))./nanmean(10.^(real(X{i})))), '%4.2f')], 2);

           iax2 = 2*N+i;
                  plot(ax(iax2), [0 0], [0 .9].*yl_all2(i,:), 'k', 'Linewidth', 1);   
                  %plot(ax(iax2), [1 1]*log10(2), [0 .75].*yl_all2(i,:), '--k', 'Linewidth', 1);   
                  %plot(ax(iax2), [1 1]*log10(5), [0 .75].*yl_all2(i,:), '--k', 'Linewidth', 1);   
                  plot(ax(iax2), [1 1]*log10(10), [0 .75].*yl_all2(i,:), '--k', 'Linewidth', 1);   
                  %plot(ax(iax2), -[1 1]*log10(2), [0 .75].*yl_all2(i,:), '--k', 'Linewidth', 1);   
                 % plot(ax(iax2), -[1 1]*log10(5), [0 .75].*yl_all2(i,:), '--k', 'Linewidth', 1);   
                  plot(ax(iax2), -[1 1]*log10(10), [0 .75].*yl_all2(i,:), '--k', 'Linewidth', 1);   
                  M = nanmean(log10(10.^real(Y{i})./10.^real(X{i})));
                  S = nanstd(log10(10.^real(Y{i})./10.^real(X{i})));
                     plot(ax(iax2), [1 1]*M, [0 .9].*yl_all2(i,:), 'b')
                  %   plot(ax(iax2), [1 1]*(M-S), [0 .75].*yl_all2(i,:), 'b--')
                  %   plot(ax(iax2), [1 1]*(M+S), [0 .75].*yl_all2(i,:), 'b--')

                  t  = text_corner(ax(iax2), {['mean = ' num2str(M , '%4.2f')];['std  = ' num2str(S , '%4.2f')]}, 2);
                  %t.BackgroundColor = [0.8 0.8 0.8]

                  if(i==1)
                     legend(ax(iax), XL{i}, YL{i}, 'mean', 'median', 'Location', 'northeast');

                        t  = text_corner(ax(iax2), [' log_{10}(' YL{i} '/' XL{i} ')'], 5);
                  else
                     legend(ax(iax), XL{i}, YL{i}, 'Location', 'northeast');
                  end
               legend(ax(iax), 'boxoff')
        end
      %% Big Title

                  t  = text_corner(axc(2), TT, 10);

   abc='abcdefghijklmnopqrst'
   for i = 1:(size(ax,1)*size(ax,2))
      text_corner(ax(i), abc(i), 4);
   end

   varargout{1} = fig;
   varargout{2} = ax; 
                  
                  
         


