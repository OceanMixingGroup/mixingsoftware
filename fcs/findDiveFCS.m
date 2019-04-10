function [ k, n, z, t, s ] = findDiveFCS( ctd, kDive )
%function [ k n z t s ]  = findDive( ctd, kDive );
%where ctd = struct with ctd.dive, ctd.npts
%finds index=k where ctd.dive == kDive, and
%returns k, n, where n=#profile points at k
%if not found, k=0, n=0
% returns arrays z, t, s of valid data

k = find( ctd.dive == kDive );
if ~isempty(k)
    k = k(1);  %if multiple ones, just use first one
    n = ctd.npts(k);
    %fprintf('found %3d pts at %3d index for dive %4d \n', n, k, kDive);
else
    k = 0;
    n = 0;
end

if n>0 
    z = cell2mat( ctd.p(k) );
    t = cell2mat( ctd.t(k) );
    s = cell2mat( ctd.s(k) );
else
    t = [];
    z = [];
    s = [];
end

