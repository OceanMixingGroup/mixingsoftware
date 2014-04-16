% function [b] = nanboot_median(x,m)
% function to bootstrap series x m times
% treating NaNs as missing values,
% returns 95% CI

function [b] = nanboot_median(x,m)
n = length(x);
clear ss
clear mi
rand('state',sum(100*clock))
for i=1:m
    mi(i) = nanmedian(x(floor(rand(1,n)*n+1)));
%     mi(i) = nanmean(x(rand(1,n)*(n-1)+1));
end;
mi = sort(mi);
lim975_index = round(m*0.025);
ans(1) = mi(lim975_index+1);
ans(2) = median(mi);
ans(3) = mi(m-lim975_index);
b = ans;
