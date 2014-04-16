% index=find((y_axis< ymax) & (y_axis>ymin));
figure(1);,hold off
nplots=length(q.series);
for i=1:nplots
  q.plothand(i)=subplot(1,nplots,i);
  tempser=['avg.' upper(deblank(char(q.series(i))))];
  if strncmpi(q.series(i),'eps',3) | strncmpi(q.series(i),'chi',3) ...
		 | strncmpi(q.series(i),'az2',3)
  eval(['plot (log10(' tempser '),-avg.P);']);
  else
  eval(['plot (' tempser ',-avg.P);']);
  end
  axis tight
  if i~=1 ,set(gca,'YTickLabel','')
  else ylabel('Depth [m]')
%     axis([-5 5 -cal.p(q.maxi) -cal.p(q.mini)])
  end
  if i==round(nplots/2)
   title([head.pathname head.thisfile '   ' date])
  end
%   if i==7 | i==8 | i==4 | i==2
%        axis([-1 1 -pmax -pmin])
%      end
  set(gca,'fontsize',7,'tag',upper(tempser(5:length(tempser))))
    xlabel(upper(tempser(5:length(tempser))))
end
for i=1:nplots
  set(q.plothand(i),'position', [.9*i/(nplots+.1)-.03 0.1 .9/(nplots+.1) .83 ])
end
