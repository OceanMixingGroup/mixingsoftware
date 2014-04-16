function [vr]=gappy_var(in);

ind=find(~isnan(in));
vr=var(in(ind));
