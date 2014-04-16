set(gcf,'Name',['QuickView 1.01 (an oxymoron): ' head.filename]);
q.display_series=find(h.selected);
index=find((y_axis< maxs.y) & (y_axis>mins.y));
leni=length(index);
% step=round(leni/400);
% if step==0
%  step=1;
% end
skip=1;
mins.x=-.1;
maxs.x=1.1;
mins.ind=index(1);
maxs.ind=index(leni);
q.nplots=length(q.display_series);
for i=1:q.nplots;
if i==1
  hold off
else 
  hold on
end
  tempser=deblank(q.series(q.display_series(i),:));
  eval(['ireps= irep.' tempser ';']);
  eval(['minser=min(data.' tempser '((mins.ind-1)*ireps+1:maxs.ind*ireps));,mins.' tempser ' =minser;'])
  eval(['maxser=max(data.' tempser '((mins.ind-1)*ireps+1:maxs.ind*ireps));,maxs.' tempser ' =maxser;'])
% if step>1
%   skip=step*ireps
% end

  if q.axis_type=='horz'
%    subplot(nplots,1,i);
%    eval(['plot (y_axis8((mins.ind*8-7):8/ireps:maxs.ind*8),' tempser ...
%	  '((mins.ind-1)*ireps+1:maxs.ind*ireps));'])
else 
  if q.plot_type(1:3)=='fit'
    eval(['plot ((data.' tempser '((mins.ind-1)*ireps+1:skip:maxs.ind*ireps)-minser)/(maxser-minser+1e-6),-y_axis32((mins.ind*32-31):skip*32/ireps:maxs.ind*32),''color'',cmap(q.display_series(i),:));']);
  else  
    eval(['plot (((data.' tempser '((mins.ind-1)*ireps+1:skip:maxs.ind*ireps)-minser)/(maxser-minser+1e-6)+i-1)/q.nplots,-y_axis32((mins.ind*32-31):skip*32/ireps:maxs.ind*32),''color'',cmap(q.display_series(i),:));']);
  end
  end
  set(gca,'fontsize',8,'position',[.19 .01 .81 .92],'xticklabel','')
  axis([mins.x maxs.x -maxs.y -mins.y])
  temp1=[num2str(minser) '     '];
  temp2=[num2str(maxser) '     '];
  q.mins(i,:)=[' ' temp1(1:5) '  '];
  q.maxs(i,:)=temp2(1:5);
end

title([head.filename])
set(h.show_limits,'string',[q.series(q.display_series,1:6) q.mins(1:q.nplots,:)  ...
      q.maxs(1:q.nplots,:) ])
q.last_display_series=q.display_series;
set(h.pmin,'string',num2str(p(index(length(index)))))
set(h.pmax,'string',num2str(p(index(1))))
