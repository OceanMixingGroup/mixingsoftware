% this is just like plot_avg_profile except that it plots any series
% that begins with an asterisk on the same plot as the series before it.
% required fields:
% q.series, q.xlabels, q.toprint (y/n)

figure(1);clf
nplots=length(q.xlabels);
i=1;
for ij=1:length(q.series)
  tempser=['avg.' upper(deblank(char(q.series(ij))))];
  if tempser(5)=='*'
	i=i-1;
	tempser=[tempser(1:4) tempser(6:length(tempser))];
	hold on
	specs='--';
  else 
	specs='-';
	hold off
  end
  q.plothand(i)=subplot(1,nplots,i);
  if strncmpi(q.series(ij),'eps',3) | strncmpi(q.series(ij),'chi',3) ...
		 | strncmpi(q.series(ij),'az2',3) | strncmpi(q.series(ij),'*eps',3) | strncmpi(q.series(ij),'*chi',3) | strncmpi(q.series(ij),'wd2',3)...
		 | strncmpi(q.series(ij),'*az2',3)
  eval(['plot (log10(' tempser '),-avg.P,specs);']);
  else
  eval(['plot (' tempser ',-avg.P,specs);']);
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
%    xlabel(upper(tempser(5:length(tempser))))
    xlabel(char(q.xlabels(i)),'fontsize',9);
i=i+1; 
end
for i=1:nplots
  set(q.plothand(i),'position', [.9*i/(nplots+.1)-.5/nplots 0.1 .9/(nplots+.1) .83 ])

if i==1 | i==2 |i==4
%  set(q.plothand(i),'xtick',20:.4:50)
end
if i==5
 % set(q.plothand(i),'xlim',[-9.5 -3])
end
if i==6
 % set(q.plothand(i),'xlim',[-7.5 -3.5])
end
if i==7
 % set(q.plothand(i),'xlim',[-12 -4])
end
if i==9
 % set(q.plothand(i),'xlim',[-10 10])
end
end
%orient landscape
%answer=input('Print this file?','s')
if q.toprint=='y'
  print
end

