function adcp=transadcp(adcpin,cfg,year);
  adcp.time=adcpin.mtime;
  % Ummm. this seems to get bad.... some times...
  dt = diff(adcp.time);
  t0 = datenum(year,1,1,0,0,0);
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
