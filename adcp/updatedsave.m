function updatedsave(adcppath,savepath,prefix,num,trannum);
% function updatedsave(adcppath,savepath,prefix,num,trannum);
% updatedsave copies the latest adcp data into the savepath.  It
% also concatenates it to the latest matfile.
%
% for ct01a:
% updatedsave('\\atlantic\tgtall\adcp\T127\','\\flash\data\jklymak\ct01a\data\adcp\','t127');
  
if nargin<4
  num=2;
  trannum=1;
end;  
num=max(2,num)

plotinfo.adcppath = adcppath;
plotinfo.savepath = savepath;
plotinfo.prefix = prefix;
plotinfo.trannum = trannum;
% smooth and deglitch
smoothtime=2*60;
cfg=[];
clear adcp;

if num>2
  plotinfo.savename = sprintf('%s/matfiles/%s%03d.mat',plotinfo.savepath,...
			      plotinfo.prefix,plotinfo.trannum);
  load(plotinfo.savename);
end;

while 1
  plotinfo.savename = sprintf('%s/matfiles/%s%03d.mat',plotinfo.savepath,...
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
  num = num-1 % this makes it reread teh last one ....
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
      [tadcp,cfg,ens]=rdpadcp(fname,1,-1,cfg);
      % get the gps too...
      fnamegps = sprintf('%s%s%03dN.%03d',plotinfo.adcppath,plotinfo.prefix,...
        plotinfo.trannum,num-1)
      gps = get_adcp_gps_fname(fnamegps);
      % merge them...
      tadcp=mergeadcpgps(tadcp,gps);
      
      % make good...
      if ~isempty(tadcp)
        tadcp=transadcp(tadcp,cfg);
        
        % tadcp=smoothadcp(tadcp,smoothtime,0.2);
        num = num+1
        fprintf('NUM %d\n',num-1);
        if exist('adcp');
          % now trim any repeats at the end....
          [t,ia]=setdiff(tadcp.time,adcp.time);
          bad = setdiff(1:length(tadcp.time),ia)
          if ~isempty(bad)
            tadcp = trimbad(tadcp,bad,'time');
          end;      
          if length(tadcp.time)>0
            adcp=mergefields(adcp,tadcp,size(adcp.u,2));
          end;
        else
          adcp=tadcp;
        end;
        save updatedsave adcp num cfg;
        save(plotinfo.savename,'adcp','cfg');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adcpout = smoothadcp(adcp,tsmooth,spike);
% tsmooth is in seconds.  time is in days...
tsmooth = tsmooth/(24*3600);
if length(adcp.time)>1
  nspike = floor(tsmooth/median(diff(adcp.time)))
else
  nspike=1;
end;
if isinf(nspike)
  nspike=1;
end;

tbin = min(adcp.time)-0.5*tsmooth:tsmooth:max(adcp.time)+0.5*tsmooth;
adcpout.time = tbin(1:end-1)+0.5*mean(diff(tbin));
adcp.ubt = despike(adcp.ubt,nspike,spike);
adcp.vbt = despike(adcp.vbt,nspike,spike);
adcp.wbt = despike(adcp.wbt,nspike,spike);
% block average
adcpout.ubt = bindata1d(tbin,adcp.time,adcp.ubt);
adcpout.vbt = bindata1d(tbin,adcp.time,adcp.vbt);
adcpout.wbt = bindata1d(tbin,adcp.time,adcp.wbt);
for i=1:4
  adcpout.range(i,:) = bindata1d(tbin,adcp.time,adcp.range(i,:));
end;
%keyboard;
adcpout.heading = bindata1d(tbin,adcp.time,adcp.heading);

for i=1:size(adcp.u,1)
  adcp.u(i,:) = despike(adcp.u(i,:),nspike,spike);
  adcp.v(i,:) = despike(adcp.v(i,:),nspike,spike);
  adcp.w(i,:) = despike(adcp.w(i,:),nspike,spike);
  % block average
  adcpout.u(i,:) = bindata1d(tbin,adcp.time,adcp.u(i,:));
  adcpout.v(i,:) = bindata1d(tbin,adcp.time,adcp.v(i,:));
  adcpout.w(i,:) = bindata1d(tbin,adcp.time,adcp.w(i,:));  
  adcpout.inten1(i,:) = bindata1d(tbin,adcp.time,adcp.inten1(i,:));  
  adcpout.inten2(i,:) = bindata1d(tbin,adcp.time,adcp.inten2(i,:));  
  adcpout.inten3(i,:) = bindata1d(tbin,adcp.time,adcp.inten3(i,:));  
  adcpout.inten4(i,:) = bindata1d(tbin,adcp.time,adcp.inten4(i,:));   
end;
adcpout.depth = adcp.depth;

return;
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adcp=mergeadcpgps(adcp,gps);

if isempty(gps)
  adcp.lon=NaN+adcp.time;
  adcp.lat=NaN+adcp.time;
else
  for i=1:length(adcp.time)
    if length(adcp.time)>1
      dt = median(diff(adcp.time));
    else
      dt = 100/(24*3600);
    end;
    ind = find(gps.time>=adcp.time(i)-dt & gps.time<=adcp.time(i)+dt ...
      & ~isnan(gps.lon) & ~isnan(gps.lat));
    if ~isempty(ind)
      adcp.lon(i) = mean(gps.lon(ind));
      adcp.lat(i) = mean(gps.lat(ind));
    else
      adcp.lon(i)=NaN;
      adcp.lat(i)=NaN;
    end;
    
  end;
end;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adcp=transadcp(adcpin,cfg);
  adcp.time=adcpin.mtime;
  % Ummm. this seems to get bad.... some times...
  dt = diff(adcp.time);
  t0 = datenum(2001,1,1,0,0,0);
  bad = find(abs(adcp.time-t0)>2*365);
  good = find(abs(adcp.time-t0)<=2*365);
  if ~isempty(bad)
    % need to fix the time...
    dt = median(diff(adcp.time(good)));
    adcp.time = adcp.time(good(1))+dt*([1:length(adcp.time)]-good(1));
  end;
  adcp.number = adcpin.number;
  adcp.pitch = adcpin.pitch;
  adcp.roll = adcpin.roll;
  adcp.heading = adcpin.heading;
  adcp.temperature = adcpin.temperature;
  adcp.ubt = adcpin.bt_east_vel;
  adcp.vbt = adcpin.bt_north_vel;
  adcp.wbt = adcpin.bt_vert_vel;
  adcp.ebt = adcpin.bt_error_vel;
  adcp.range = adcpin.bt_range;
  adcp.u = adcpin.east_vel;
  adcp.v = adcpin.north_vel;
  adcp.w = adcpin.vert_vel;
  adcp.e = adcpin.error_vel;
  adcp.inten1 = squeeze(adcpin.intens(:,1,:));
  adcp.inten2 = squeeze(adcpin.intens(:,2,:));
  adcp.inten3 = squeeze(adcpin.intens(:,3,:));
  adcp.inten4 = squeeze(adcpin.intens(:,4,:));
  adcp.lon = adcpin.longitude;  
  adcp.lat = adcpin.latitude;  
  adcp.navu = adcpin.nav_east_vel;  
  adcp.navv = adcpin.nav_north_vel;
  % get the depth bins and other stuff from the cfg file...
  adcp.depth = (0.5:1:cfg.n_cells-0.5)*cfg.cell_size + cfg.blank  ...
      + cfg.adcp_depth;adcp.depth = adcp.depth';
  adcp.npings = cfg.pings_per_ensemble;
  adcp.deployname = cfg.deploy_name;
  
  return;











