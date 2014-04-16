function update_series(n)
  global q summ
% add some series to the plot_series routine.
  if n==1
	len=q.nplots;
	h=q.hand.allser;%(findobj('tag','all_series'));
	h2=q.hand.plotser;%(findobj('tag','plot_series'));
	values_to_add=get(h,'value');
	q.current_plots(len+1).series=q.sum_series(values_to_add);
% set the plot string to be displayed
	new_string=[];
	for j=1:length(values_to_add)
	  new_string=[new_string char(q.sum_series(values_to_add(j))) ' '];
	end			  
	q.current_plots(len+1).name=new_string;
%	q.current_plots(len+1).lin=1;
%	q.current_plots(len+1).norm=1;
	set(h2,'string',strvcat(q.current_plots(:).name));
	q.nplots=q.nplots+1;
	set(h2,'value',q.nplots,'max',1); %length(strvcat(q.current_plots(:).name)));
	update_series(14);,update_series(16);	
  elseif n==2
	h2=q.hand.plotser; 
	values_to_remove=get(h2,'value');
	newfields=(setdiff((1:q.nplots),values_to_remove));
	q.current_plots=q.current_plots(newfields);
	q.nplots=length(newfields);
	set(h2,'string',strvcat(q.current_plots.name),'value',1);
	set(h2,'value',q.nplots);

  elseif n==3
	q.xplotseries=q.sum_series(get(q.hand.xseries,'value'));
	
  elseif n==4
	q.xmin=[q.xmin str2num(get(q.hand.xmin,'string'))];

  elseif n==5
	q.xmax=[q.xmax str2num(get(q.hand.xmax,'string'))];


% the following shouldn't be needed anymore
% might want to change it so that you can adjust the colour of each line
%  if n==6
%   h_delete=findobj('tag','change_string');, delete(h_delete);
%   h6=(findobj('tag','all_series'));
%   current_val=get(h6,'value');
%   current_val=current_val(1);
%   uicontrol('style','edit',...
% 			'string',char(q.sum_series(current_val)),...
% 	 'callback','update_series(7)','max',1,'user',current_val,...
%   'tag','change_string','position',[15 250 200 20]);
%   end

%   if n==7
% 	h7=findobj('tag','change_string');
% 	current_val=get(h7,'user');
% 	temp=(get(h7,'string'));
% 	if ~isempty(temp)
% 	  q.sum_series(current_val)={temp(1,:)};
% 	end
% 	delete(h7);
% 	h6=(findobj('tag','all_series'));
% 	set(h6,'string',q.sum_series);
%   end

  % zoom in the horizontal direction...
  elseif n==8
	figure(q.hand.datafig);
	set(q.hand.controlfig,'visible','off')
	[x,y]=ginput(2);
	set(q.hand.controlfig,'visible','on')
	q.xmin=[q.xmin min(x)];
	q.xmax=[q.xmax max(x)];
	set(q.hand.xmin,'string',[datestr(q.xmin(length(q.xmin)),6) ' ' datestr(q.xmin(length(q.xmin)),15)]);
	set(q.hand.xmax,'string',[datestr(q.xmax(length(q.xmax)),6) ' ' datestr(q.xmax(length(q.xmax)),15)]);
	plot_marlin_sum

% zoom out
  elseif n==9
	eval(['q.xmin=min(summ.' char(q.xplotseries) ');']);
	eval(['q.xmax=max(summ.' char(q.xplotseries) ');']);
	set(q.hand.xmin,'string',datestr(q.xmin(length(q.xmin))),0);
	set(q.hand.xmax,'string',datestr(q.xmax(length(q.xmax))),0);
	plot_marlin_sum

  % reload the dataset.
  elseif n==10
	 temp1=summ.pathname;
	 temp2=summ.filename;
     load([summ.pathname summ.filename])
	 summ.pathname=temp1;
	 summ.filename=temp2;
% reset horizontal axis limits...
	eval(['q.xmin=[min(summ.' char(q.xplotseries) ')];']);
	eval(['q.xmax=[max(summ.' char(q.xplotseries) ')];']);
%	 q.xmin=[q.xmin q.xmin(length(q.xmin))];
%	 q.xmax=[q.xmax Inf];
	 set(q.hand.xmin,'string',datestr(q.xmin(length(q.xmin))),0);
	 set(q.hand.xmax,'string',datestr(q.xmax(length(q.xmax))),0);
% replot the data...
	 plot_marlin_sum


  % zoom back....
  elseif n==11
	lenn=max(1,length(q.xmax)-1);
	q.xmax=q.xmax(1:lenn);
	lenn=max(1,length(q.xmin)-1);
	q.xmin=q.xmin(1:lenn);
	set(q.hand.xmin,'string',[datestr(q.xmin(length(q.xmin)),6) ' ' datestr(q.xmin(length(q.xmin)),15)]);
	set(q.hand.xmax,'string',[datestr(q.xmax(length(q.xmax)),6) ' ' datestr(q.xmax(length(q.xmax)),15)]);
	plot_marlin_sum
  elseif n==13
	cval=get(q.hand.plotser,'value');
  set(q.hand.norm,'value',q.current_plots(cval).norm);
  set(q.hand.rev,'value',~q.current_plots(cval).norm);
  set(q.hand.lin,'value',q.current_plots(cval).lin);
  set(q.hand.log,'value',~q.current_plots(cval).lin);
  
elseif n==14
  set(q.hand.lin,'value',1),  set(q.hand.log,'value',0)
  if ~isempty(get(q.hand.plotser,'string'))
  q.current_plots(get(q.hand.plotser,'value')).lin=1;
  end
elseif n==15
  set(q.hand.log,'value',1),  set(q.hand.lin,'value',0)
  if ~isempty(get(q.hand.plotser,'string'))
  q.current_plots(get(q.hand.plotser,'value')).lin=0;
  end
elseif n==16
  set(q.hand.norm,'value',1),  set(q.hand.rev,'value',0)
  if ~isempty(get(q.hand.plotser,'string'))
  q.current_plots(get(q.hand.plotser,'value')).norm=1;
  end
elseif n==17
  set(q.hand.rev,'value',1),  set(q.hand.norm,'value',0)
  if ~isempty(get(q.hand.plotser,'string'))
  q.current_plots(get(q.hand.plotser,'value')).norm=0;
  end
elseif n==99
if strncmp('Yes',questdlg('','Terminate Program?'),3)
  delete(q.hand.datafig,q.hand.controlfig);
end
end
