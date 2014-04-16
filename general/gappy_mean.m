function [mn]=gappy_mean(in);

ind=find(~isnan(in));
mn=mean(in(ind));
