function out=gappy_max(in);
ind=find(~isnan(in));
out=max(in(ind));