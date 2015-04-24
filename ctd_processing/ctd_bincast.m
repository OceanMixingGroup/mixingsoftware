function data = ctd_bincast(datain, zmin, dz, zmax)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function data = ctd_bincast(datain, zmin, dz, zmax)
%
% bin datain by depth on zmin:dz:zmax
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
zbin = [zmin:dz:zmax]';
nb = length(zbin);
dz2 = dz/2;

data.t1 = NaN*ones(nb, 1);
data.t2 = NaN*ones(nb, 1);
data.c1 = NaN*ones(nb, 1);
data.c2 = NaN*ones(nb, 1);
data.s1 = NaN*ones(nb, 1);
data.s2 = NaN*ones(nb, 1);
data.theta1 = NaN*ones(nb, 1);
data.theta2 = NaN*ones(nb, 1);
data.sigma1 = NaN*ones(nb, 1);
data.sigma2 = NaN*ones(nb, 1);
data.oxygen = NaN*ones(nb, 1);
data.trans = NaN*ones(nb, 1);
data.fl = NaN*ones(nb, 1);
data.lon = NaN*ones(nb, 1);
data.lat = NaN*ones(nb, 1);
data.time = NaN*ones(nb, 1);
data.nscan = zeros(nb, 1);
data.depth = zbin;

if isfield(datain,'epsilon1')
    data.epsilon1=NaN*ones(nb,1);
end

if isfield(datain,'epsilon2')
    data.epsilon2=NaN*ones(nb,1);
end


hwb = waitbar(0, ['binning ' inputname(1)]);

for ibin = 1:nb
    
    waitbar(ibin/nb, hwb)
    
    zb = zbin(ibin);
    ii = find((datain.depth - zb) <= dz2 & (datain.depth - zb) > -dz2);
    
    data.t1(ibin) = nanmean(datain.t1(ii));
    data.t2(ibin) = nanmean(datain.t2(ii));
    data.c1(ibin) = nanmean(datain.c1(ii));
    data.c2(ibin) = nanmean(datain.c2(ii));
    data.s1(ibin) = nanmean(datain.s1(ii));
    data.s2(ibin) = nanmean(datain.s2(ii));
    data.theta1(ibin) = nanmean(datain.theta1(ii));
    data.theta2(ibin) = nanmean(datain.theta2(ii));
    data.sigma1(ibin) = nanmean(datain.sigma1(ii));
    data.sigma2(ibin) = nanmean(datain.sigma2(ii));
    data.oxygen(ibin) = nanmean(datain.oxygen(ii));
    data.trans(ibin) = nanmean(datain.trans(ii));
    data.fl(ibin) = nanmean(datain.fl(ii));
    data.lon(ibin) = nanmean(datain.lon(ii));
    data.lat(ibin) = nanmean(datain.lat(ii));
    data.time(ibin) = nanmedian(datain.time(ii));
    data.nscan(ibin) = sum(isfinite(datain.t1(ii)));
    
    if isfield(datain,'epsilon1')
        data.epsilon1(ibin)=nanmean(datain.epsilon1(ii));
    end
    
    if isfield(datain,'epsilon2')
        data.epsilon2(ibin)=nanmean(datain.epsilon2(ii));
    end
    
end

close(hwb)

data.p = sw_pres(data.depth, data.lat);

%%