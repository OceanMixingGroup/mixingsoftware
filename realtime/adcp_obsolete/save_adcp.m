function save_adcp(adcppath,savepath,prefix,trannum,year);
% function save_adcp(adcppath,savepath,prefix,trannum,year);
% updatedsave copies the latest adcp data into the savepath.  It
% also concatenates it to the latest matfile.
%


if nargin<3
  trannum=input('Enter number of ADCP transect --> ');
end;

num=2;
num=max(2,num);

plotinfo.adcppath = adcppath;
plotinfo.savepath = savepath;
plotinfo.prefix = prefix;
plotinfo.trannum = trannum;
% smooth and deglitch
smoothtime=30;
cfg=[];
clear adcp;

if num>2
  plotinfo.savename = sprintf('%s\\mat\\%s%03d.mat',plotinfo.savepath,...
			      plotinfo.prefix,plotinfo.trannum);
  load(plotinfo.savename);
end;

while 1
  plotinfo.savename = sprintf('%s\\mat\\%s%03d.mat',plotinfo.savepath,...
			      plotinfo.prefix,plotinfo.trannum);
  plotinfo.rawdir = sprintf('%s\\raw\\',plotinfo.savepath);
  d=dir(sprintf('%s%s%03dP.*',plotinfo.adcppath,plotinfo.prefix,plotinfo.trannum));
  while isempty(d);
    fprintf('Warning: Nothing in %s\n',...
        sprintf('%s%s%03dP.*',plotinfo.adcppath,plotinfo.prefix,plotinfo.trannum));
    fprintf('Pausing...\n');
    for i=1:smoothtime
        pause(1)
    end;  % read in data:
    d=dir(sprintf('%s%s%03dP.*',plotinfo.adcppath,plotinfo.prefix,plotinfo.trannum));
  end;
  num = num-1; % this makes it reread the last one ....
  while num<=length(d);
    d=dir(sprintf('%s%s%03dP.*',plotinfo.adcppath,plotinfo.prefix,plotinfo.trannum));
    if d(num).bytes>300
      fname = sprintf('%s%s%03dP.%03d',plotinfo.adcppath,plotinfo.prefix,...
        plotinfo.trannum,num-1)
      subname = sprintf('%s%s%03d*.%03d',plotinfo.adcppath,plotinfo.prefix,...
        plotinfo.trannum,num-1);
      sprintf('copy %s %s',subname,plotinfo.rawdir)
      dos(sprintf('copy %s %s',subname,plotinfo.rawdir));
      %try 
      [tadcp,cfg,ens]=rdpadcp1(fname,1,-1,cfg,year);
%       % get the gps too...
%       fnamegps = sprintf('%s%s%03dN.%03d',plotinfo.adcppath,plotinfo.prefix,...
%         plotinfo.trannum,num-1)
%       gps = get_adcp_gps_fname(fnamegps);
%       % merge them...
%       tadcp=mergeadcpgps(tadcp,gps);
%       
      % make good...
      if ~isempty(tadcp)
        tadcp=transadcp(tadcp,cfg,year);
        
        % tadcp=smoothadcp(tadcp,smoothtime,0.2);
        num = num+1;
        fprintf('NUM %d\n',num-1);
        if exist('adcp','var');
          % now trim any repeats at the end....
          [t,ia]=setdiff(tadcp.time,adcp.time);
          bad = setdiff(1:length(tadcp.time),ia);
          if ~isempty(bad)
            tadcp = trimbad(tadcp,bad,'time');
          end;      
          if length(tadcp.time)>0
            adcp=mergefields(adcp,tadcp);
          end;
        else
          adcp=tadcp;
        end;
        save updatedsave adcp num cfg;
	lockname = [plotinfo.savename '.lock']
	lockedby = 'save_adcp.m';
	while exist(lockname)
	  fprintf('%s  locked - pausing\n',plotinfo.savename);
	  pause(5);
	end;
	save(lockname,'lockedby');
	pause(0.1);
	save(plotinfo.savename,'adcp','cfg');
	pause(0.1);
	delete(lockname);
      end; % if tadcp OK...
    end; % if the file is not empty...
  end; % end while we have new files to translate...
  
  % check for new trans number....
  d=dir(sprintf('%s%s%03dP.*',plotinfo.adcppath,...
		plotinfo.prefix,plotinfo.trannum+1));
  if ~isempty(d)
    fprintf('There is now some data in transect %d',plotinfo.trannum+1);
    plotinfo.trannum=plotinfo.trannum+1;
    % this will redo the same transect; it does not move on to the next.  Doing so seemed fallible.  
    num=2;
    clear adcp;
    tadcp=[];
    cfg=[];
  else
    % wait a while...
    fprintf('Pausing...\n');
    for i=1:smoothtime
      pause(1)
    end;
  end;
end;

