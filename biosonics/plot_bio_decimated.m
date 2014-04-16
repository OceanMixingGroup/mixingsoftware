function plot_bio_decimated(datadir,start,stop,ydayordatenum);
  
% function plot_bio_times(datadir,start,stop);
%
% plot biosonics data in datadir, starting at start and finishing at stop. 
% Assumes that the biosonics files are of the form
% datadir/yyyymmddhhmm.mat.   The routine
% realtime/biosonics/run_backup.m saves files in the this format.
%
  
% $Author: aperlin $ $Date: 2008/01/31 20:22:42 $ $Revision: 1.1.1.1 $
  if nargin<4
    ydayordatenum=0;
  end;
    
  if nargin<5
    dx=5;
    dz=5;
  end;

  datestr(start)
  datestr(stop)
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
    [datadir d(i).name]
    load([datadir d(i).name]);
  
    in = find(pings.datenum>=start_plot & pings.datenum<= ...
	      stop_plot);
    
    if ~isempty(in)
      imagesc(pings.datenum(in)-ydayordatenum*datenum(2001,1,1,0,0,0),...
	      pings.depth,log10(pings.sample(:,in)));
      hold on;
    end;    
    set(gca,'xlim',[start_plot stop_plot]);

  end;
  
  
  