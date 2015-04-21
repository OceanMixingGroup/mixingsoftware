function [ilag, rms] = ctd_oxygen_lag(data, zmin, dz, zmax, cfg)
  
zbin = [zmin:dz:zmax]';
nb = length(zbin);
oxd = NaN*ones(nb, 1);
oxu = NaN*ones(nb, 1);

[maxz, imax] = max(data.depth);
nz = length(data.depth);
zd = data.depth(1:imax);
zu = flipud(data.depth(imax:nz));
dz2 = dz/2;

ilag = 2*24:12:5*24;
ii = 0;
for jj = ilag

  ii = ii + 1
  ox = volt2ox(data.oxygen(jj:end), data.s1(1:end - jj + 1), data.t1(1:end - jj + 1), data.p(1:end - jj + 1), cfg.oxcal);
 
  for ibin = 1:nb
  
    if ~mod(nb - ibin, 100), disp(num2str(nb - ibin)), end

    zb = zbin(ibin);
    idn = find((zd - zb) <= dz2 & (zd - zb) > -dz2);
    iup = find((zu - zb) <= dz2 & (zu - zb) > -dz2);
  
    oxd(ibin) = nanmean(ox(idn));
    oxu(ibin) = nanmean(ox(iup));
    
  end
  
  rms(ii) = nanmean((oxd - oxu).^2)^0.5;
    
  figure
  subplot(211); plot(oxd, zbin, oxu, zbin, 'r'); grid
  title(['ii = ' num2str(ii) '   ilag = ' num2str(ilag(ii)) '   rms = ' num2str(rms)])
  subplot(212); plot(oxd - oxu, zbin); grid
  drawnow
  
end

 