function out=gappy_min(in);
ind=find(~isnan(in));
out=min(in(ind));