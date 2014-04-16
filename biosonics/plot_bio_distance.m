function plot_bio_decimated(datadir,start,stop);
  
% function plot_bio_times(datadir,start,stop);
%
% plot biosonics data in datadir, starting at start and finishing at stop. 
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
  
  d=[];
  d=dir([datadir '\*.mat']);
  
  for i=1:length(d)
    times(i) = datenum(str2num(d(i).name(1:4)),str2num(d(i).name(5:6)),...
		       str2num(d(i).name(7:8)),...
		       str2num(d(i).name(9:10)),...
		       str2num(d(i).name(11:12)),0);
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
    load([datadir d(i).name]);
    % keyboard;
    in = find(pings.datenum>=start_plot & pings.datenum<= ...
	      stop_plot & ~isnan(pings.lon));
    if median(diff(pings.lon)<0)
      in=fliplr(in);
    end;
%    keyboard;
    if ~isempty(in)
      imagesc(pings.lon(in),pings.depth,log10(pings.sample(:,in)));
      hold on;
    end;    
%    set(gca,'xlim',[start_plot stop_plot]);
    
  end;
  
  
  