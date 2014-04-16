% script plot_series plots a bunch of series described in the variable q.series
% index=find((y_axis< ymax) & (y_axis>ymin));
index=q.mini:q.step:q.maxi;
 leni=length(index);
 min_ind=index(1);
 max_ind=index(leni);
nplots=length(q.series);
for i=1:nplots
  q.plothand(i)=subplot(1,nplots,i);
  tempser=['cal.' upper(deblank(char(q.series(i))))];
  eval(['ireps= head.irep.' upper(tempser(5:length(tempser))) ';']);
%  if axis_type=='horz'
%    subplot(nplots,1,i);
%    eval(['plot (y_axis8((min_ind*8-7):8/ireps:max_ind*8),' tempser ...
%	  '((min_ind-1)*ireps+1:max_ind*ireps));'])
%  else 
%   eval(['plot (' tempser '((min_ind-1)*ireps+1:max_ind*ireps),-cal.p8((min_ind*8-7):8/ireps:max_ind*8));']);
   eval(['plot (' tempser '(index*ireps),-cal.P(index));']);
 %  end
%  set(get(gca,'children'),'color',cmap(display_series(i),:));
%  eval(['minser=min(' tempser '((min_ind-1)*ireps+1:max_ind*ireps));,min_' tempser ' =minser;'])
%  eval(['maxser=max(' tempser '((min_ind-1)*ireps+1:max_ind*ireps));,max_' tempser ' =maxser;'])
%    temp=axis;
%    axis([minser maxser -pmax -pmin])
axis tight
  if i~=1 ,set(gca,'YTickLabels','')
  else ylabel('Depth [m]')
%     axis([-5 5 -cal.p(q.maxi) -cal.p(q.mini)])
  end
  if i==round(nplots/2)
   title([head.pathname head.thisfile '   ' date])
  end
%   if i==7 | i==8 | i==4 | i==2
%        axis([-1 1 -pmax -pmin])
%      end
    xlabel(upper(tempser(5:length(tempser))))
  set(gca,'fontsize',7,'tag',upper(tempser(5:length(tempser))))
end
for i=1:nplots
  set(q.plothand(i),'position', [.9*i/(nplots+.1)-.03 0.1 .9/(nplots+.1) .83 ])
end