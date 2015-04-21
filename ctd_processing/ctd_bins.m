  function [dbin, ubin, ndbin, nubin] = ctd_bins(z, d, zmin, dz, zmax)
% function [dbin, ubin, ndbin, nubin] = ctd_bins(z, d, zmin, dz, zmax)
% bin d(z) on zmin:dz:zmax 
% dbin, ubin = downcast, upcast binned data
% ndbin, nubin = number data points in each bin
  
zbin = [zmin:dz:zmax]';
nb = length(zbin);
dbin = NaN*ones(nb, 1); % downcast
ubin = NaN*ones(nb, 1); % upcast
ndbin = zeros(nb, 1);
nubin = zeros(nb, 1);

[maxz, imax] = max(z);
nz = length(z);

dz2 = dz/2;

jj = isfinite(d);
dd = zeros(size(d));
dd(jj) = d(jj);

for ibin = 1:nb
  if ~mod(nb - ibin, 100), disp(num2str(nb - ibin)), end
  idn = (((abs(z(1:imax) - zbin(ibin)) < dz2) | (z(1:imax) == zbin(ibin) - dz2)) & jj(1:imax));
  iup = (((abs(z(imax:nz) - zbin(ibin)) < dz2) | (z(imax:nz) == zbin(ibin) - dz2)) & jj(imax:nz));
  ndbin(ibin,:) = length(find(idn));
  nubin(ibin,:) = length(find(iup));
  dbin(ibin,:) = idn'*dd(1:imax)/ndbin(ibin,:);
  ubin(ibin,:) = idn'*dd(1:imax)/nubin(ibin,:);
end
