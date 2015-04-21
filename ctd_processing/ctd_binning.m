  function [datad, datau] = ctd_binning(data, zmin, dz, zmax)
% function [datad, datau] = ctd_binning(data, zmin, dz, zmax)
% bin d(z) on zmin:dz:zmax 
% datad, datau = downcast, upcast binned data
% including number data points in each bin
  
zbin = [zmin:dz:zmax]';
nb = length(zbin);

datad.t1 = NaN*ones(nb, 1); % downcast
datad.t2 = NaN*ones(nb, 1); 
datad.s1 = NaN*ones(nb, 1); 
datad.s2 = NaN*ones(nb, 1); 
datad.theta1 = NaN*ones(nb, 1); 
datad.theta2 = NaN*ones(nb, 1); 
datad.sigma1 = NaN*ones(nb, 1); 
datad.sigma2 = NaN*ones(nb, 1); 
datad.oxygen = NaN*ones(nb, 1); 
datad.trans = NaN*ones(nb, 1); 
datad.fl = NaN*ones(nb, 1); 
datad.lon = NaN*ones(nb, 1); 
datad.lat = NaN*ones(nb, 1); 
datad.time = NaN*ones(nb, 1); 
datad.nscan = zeros(nb, 1);
datad.depth = zbin;

datau.t1 = NaN*ones(nb, 1); % upcast
datau.t2 = NaN*ones(nb, 1); 
datau.s1 = NaN*ones(nb, 1); 
datau.s2 = NaN*ones(nb, 1); 
datau.theta1 = NaN*ones(nb, 1); 
datau.theta2 = NaN*ones(nb, 1); 
datau.sigma1 = NaN*ones(nb, 1); 
datau.sigma2 = NaN*ones(nb, 1); 
datau.oxygen = NaN*ones(nb, 1); 
datau.trans = NaN*ones(nb, 1); 
datau.fl = NaN*ones(nb, 1); 
datau.lon = NaN*ones(nb, 1); 
datau.lat = NaN*ones(nb, 1); 
datau.time = NaN*ones(nb, 1); 
datau.nscan = zeros(nb, 1);
datau.depth = zbin;

[maxz, imax] = max(data.depth);
nz = length(data.depth);
zd = data.depth(1:imax);
zu = data.depth(imax:nz);
dz2 = dz/2;
        
hwb = waitbar(0, 'binning...');
    
for ibin = 1:nb
  
  waitbar(ibin/nb, hwb)
  
  zb = zbin(ibin);
  idn = find((zd - zb) <= dz2 & (zd - zb) > -dz2);
  iup = imax - 1 + find((zu - zb) <= dz2 & (zu - zb) > -dz2);
  
  datad.t1(ibin) = nanmean(data.t1(idn));
  datad.t2(ibin) = nanmean(data.t2(idn));
  datad.s1(ibin) = nanmean(data.s1(idn));
  datad.s2(ibin) = nanmean(data.s2(idn));
  datad.theta1(ibin) = nanmean(data.theta1(idn));
  datad.theta2(ibin) = nanmean(data.theta2(idn));
  datad.sigma1(ibin) = nanmean(data.sigma1(idn));
  datad.sigma2(ibin) = nanmean(data.sigma2(idn));
  datad.oxygen(ibin) = nanmean(data.oxygen(idn));
  datad.trans(ibin) = nanmean(data.trans(idn));
  datad.fl(ibin) = nanmean(data.fl(idn));
  datad.lon(ibin) = nanmean(data.lon(idn));
  datad.lat(ibin) = nanmean(data.lat(idn));
  %datad.time(ibin) = nanmean(data.time(idn));
  datad.nscan(ibin) = sum(isfinite(data.t1(idn)));

  datau.t1(ibin) = nanmean(data.t1(iup));
  datau.t2(ibin) = nanmean(data.t2(iup));
  datau.s1(ibin) = nanmean(data.s1(iup));
  datau.s2(ibin) = nanmean(data.s2(iup));
  datau.theta1(ibin) = nanmean(data.theta1(iup));
  datau.theta2(ibin) = nanmean(data.theta2(iup));
  datau.sigma1(ibin) = nanmean(data.sigma1(iup));
  datau.sigma2(ibin) = nanmean(data.sigma2(iup));
  datau.oxygen(ibin) = nanmean(data.oxygen(iup));
  datau.trans(ibin) = nanmean(data.trans(iup));
  datau.fl(ibin) = nanmean(data.fl(iup));
  datau.lon(ibin) = nanmean(data.lon(iup));
  datau.lat(ibin) = nanmean(data.lat(iup));
  %datau.time(ibin) = nanmean(data.time(iup));
  datau.nscan(ibin) = sum(isfinite(data.t1(iup)));

end

close(hwb)

datad.p = sw_pres(datad.depth, datad.lat);
datau.p = sw_pres(datau.depth, datau.lat);
datad.tau1 = data.tau1;
datad.tau2 = data.tau2;
datau.tau1 = data.tau1;
datau.tau2 = data.tau2;
datad.L1 = data.L1;
datad.L2 = data.L2;
datau.L1 = data.L1;
datau.L2 = data.L2;


