function adcp=transadcp(adcpin,cfg);
  good=find(adcpin.number~=0);
  
  adcp.mtime=adcpin.mtime(good);
  adcp.number = adcpin.number(good);
  adcp.pitch = adcpin.pitch(good);
  adcp.roll = adcpin.roll(good);
  adcp.heading = adcpin.heading(good);
  adcp.temperature = adcpin.temperature(good);
  adcp.ubt = adcpin.bt_east_vel(good);
  adcp.vbt = adcpin.bt_north_vel(good);
  adcp.wbt = adcpin.bt_vert_vel(good);
  adcp.ebt = adcpin.bt_error_vel(good);
  adcp.range = adcpin.bt_range(:,good);
  adcp.u = adcpin.east_vel(:,good);
  adcp.v = adcpin.north_vel(:,good);
  adcp.w = adcpin.vert_vel(:,good);
  adcp.e = adcpin.error_vel(:,good);
  adcp.inten1 = squeeze(adcpin.intens(:,1,:));adcp.inten1=adcp.inten1(:,good);
  adcp.inten2 = squeeze(adcpin.intens(:,2,:));adcp.inten2=adcp.inten2(:,good);
  adcp.inten3 = squeeze(adcpin.intens(:,3,:));adcp.inten3=adcp.inten3(:,good);
  adcp.inten4 = squeeze(adcpin.intens(:,4,:));adcp.inten4=adcp.inten4(:,good);
  adcp.longitude = adcpin.longitude(good);  
  adcp.latitude = adcpin.latitude(good);
  adcp.navu = adcpin.nav_east_vel(good);  
  adcp.navv = adcpin.nav_north_vel(good);
  adcp.perc_good = adcpin.perc_good(good);
  % get the depth bins and other stuff from the cfg file...
  adcp.depth = (0.5:1:cfg.n_cells-0.5)*cfg.cell_size + cfg.blank  ...
      + cfg.adcp_depth;adcp.depth = adcp.depth';
  adcp.npings = cfg.pings_per_ensemble;
  adcp.deployname = cfg.deploy_name;
return;
