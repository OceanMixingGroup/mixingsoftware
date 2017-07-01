function [dataout zout Nobs] = binprofile(datain, zin, zmin, dz, zmax, minobs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function [dataout zout] = binprofile(datain, zin, zmin, dz, zmax)
%
% Bin datain by depth on zmin:dz:zmax
%
% INPUT
% - datain
% - zin
% - zmin
% - dz
% - zmax
% - minobs
%
% OUTPUT
% - dataout
% - zout
% - Nobs
%
%------------
% Modified for more general use from ctd_bincast.m (in mixing software /
% ctd_processing) July 22, 2015 - A. Pickering
% 10/9/15 - AP - Return # points in each bin also
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% minimum # observations in bin
if ~exist('minobs','var')
    minobs = 2;%
end

zbin = [zmin:dz:zmax]';
nb   = length(zbin);
dz2  = dz/2;

dataout = nan*ones(size(zbin));
Nobs    = nan*ones(size(zbin));

for ibin = 1:nb
        
    clear zb ii
    zb = zbin(ibin);
    ii = find((zin - zb) <= dz2 & (zin - zb) > -dz2);
    
    if numel(ii)>minobs
    dataout(ibin) = nanmean(datain(ii));
    Nobs(ibin)    = numel(ii);
    end
        
end

dataout = dataout(:);
Nobs = Nobs(:);
zout = zbin;

%%