function plot_bio_times(datadir,start,stop,xducerdepth,dx,dz);
  
% function plot_bio_times(datadir,start,stop);
%
% plot biosonics data in datadir, starting at start and finishing at stop. 
%
% function plot_bio_times(datadir,start,stop,xducerdepth,dx,dz);
% puts the transducer at depth xducerdepth.
%  decimates in x by dx, and z by dz...
%

  if nargin<4
    xducerdepth=[];
  end;
  if isempty(xducerdepth)
    xducerdepth=0;
  end;
  
  if nargin<5
    dx=5;
    dz=5;
  end;

  c1=datevec(start);
  t1=start;
  c2=datevec(stop);
  t2=stop;
  
  years  = c1(1):c2(1);
  months = c1(2):c2(2);
  days   = c1(3):c2(3);
  monthstr={'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
  d=[];
  for i=1:length(years);
    for j=1:length(months);
      for k=1:length(days);
	dirname = [datadir  sprintf('DT%04d\\%s\\DAY%d\\',years(i),monthstr{months(j)},days(k))];
	dd=dir([dirname '*.DT4']);
	for ii=1:length(dd)
	  dd(ii).dirname = dirname;
	  dd(ii).year = years(i);
	  dd(ii).month = months(j);
	  dd(ii).day   = days(k);
	end;
	d=[d dd];
      end;
    end;
  end;
  if isempty(d)
    warning(sprintf('No data in %s',datadir));
    return;
  end;
  
  
  for i=1:length(d)
    times(i) = datenum(d(i).year,d(i).month,d(i).day,...
		       str2num(d(i).name(1:2)),...
		       str2num(d(i).name(3:4)),...
		       str2num(d(i).name(5:6)));
  end;  

  start_plot=start;
  stop_plot=stop;
  
  below = find(times<t1);
  if ~isempty(below)
    start=max(below);
  else
    start=1;
  end;
  above = find(times>t2);
  if ~isempty(above)
    stop=min(above);
  else
    stop=length(times);
  end;
  
  for i=start:stop
    pings=fastreadbio([d(i).dirname d(i).name],xducerdepth,dx,dz);
    in = find(pings.datenum>=start_plot & pings.datenum<= ...
	      stop_plot);
    if ~isempty(in)
      imagesc(pings.datenum(in),pings.depth,log10(pings.sample(:,in)));
      hold on;
    end;    
    set(gca,'xlim',[start_plot stop_plot]);
    
  end;
  
  
  