function plot_marlin_sum
global q summ
warning off
% plot_single_marlin plots a single marlin data file.  All data is
% contained in AVG and is specified using q.series and a.xlabels.
% Q.SERIES is a cell array containing the series to be plotted.  Any
% series that is preceeded by and '*' is plotted on the same plot as
% before.  epsilon and chi are plotted on a log scale.

hh=figure(q.hand.datafig);
set(hh,'Name',['Marlin Summary Data ending ' datestr(max(summ.timevec),0)])
% first determine the number of plots...
i=1;

%q.series=q.sum_series(q.current_plots);
eval(['idx=find(summ.' char(q.xplotseries) ' >q.xmin(length(q.xmin)) & summ.' char(q.xplotseries) ' <q.xmax(length(q.xmax)));']); 

for ij=1:q.nplots %length(q.current_plots)
%  tempser=['summ.' lower(deblank(char(q.series(ij))))];
%  if tempser(6)=='*'
%	i=i-1;
%	tempser=[tempser(1:5) tempser(7:length(tempser))];
%	hold on
%	% select the line style.
%	if strcmp(specs,'r--')
%	  specs='g:';
%	else
%	  specs='r--';
%	end
%  else 
%	specs='-';
%	hold off
%  end
  q.plothand(ij)=subplot(q.nplots,1,ij);
%  if strncmpi(q.series(ij),'eps',3) | strncmpi(q.series(ij),'chi',3) ...
%		 | strncmpi(q.series(ij),'azhi',3) | strncmpi(q.series(ij),'*eps',3) | strncmpi(q.series(ij),'*chi',3) | strncmpi(q.series(ij),'wd2',3)...
%		 | strncmpi(q.series(ij),'*azhi',3)
%  eval(['plot (summ.' char(q.xplotseries) '(idx),log10(' tempser '(idx)),specs);']);
%  else
%	if strncmpi(tempser(5:length(tempser)),'p',1 )
%	  tempser=['-' tempser];
%	end
  specs='bgrcmkbgrcmkbgrkcmbgrcm';
  hold off 
  for jk=1:length(q.current_plots(ij).series)
	eval(['plot (summ.' char(q.xplotseries) '(idx),summ.' char(q.current_plots(ij).series(jk)) '(idx),specs(jk));']);
	hold on
  end
  if ~q.current_plots(ij).norm
	set(gca,'ydir','reverse');
  end
  if ~q.current_plots(ij).lin
	set(gca,'yscale','log')
  else
	set(gca,'yscale','lin')
  end
  axis tight
  ylabel(char(q.current_plots(ij).name))
  if ij~=q.nplots
	set(gca,'xTickLabel','')
  else
	if strncmpi(char(q.xplotseries),'timevec',7)
	  hold off
	  datetick
	  axis tight
	  if q.xmax(length(q.xmax))~=Inf
		xlabel(['Time' datestr(q.xmin(length(q.xmin))) ' - ' datestr(q.xmax(length(q.xmax)))])
		%     axis([-5 5 -cal.p(q.maxi) -cal.p(q.mini)])
	  else
		xlabel(['Time from ' datestr(q.xmin(length(q.xmin)))]);
	  end
	end
  end
end
zoom yon
for i=1:q.nplots
set(q.plothand(i),'position', [.13 .9*(q.nplots-i)/(q.nplots+.1)+.08 0.7750 ...
					.9/(q.nplots+.1)],'fontsize',7)

end
return

%   end
%   if i==1
% %   title([head.pathname head.thisfile ' Start ' head.starttime])
%   end
% %   if i==7 | i==8 | i==4 | i==2
% %        axis([-1 1 -pmax -pmin])
% %      end
%   set(gca,'fontsize',7,'tag',upper(tempser(5:length(tempser))))
%     ylabel(upper(tempser(5:length(tempser))))
% 	%ylabel(char(q.xlabels(i)),'fontsize',9);
% i=i+1; 
% end

% warning on
