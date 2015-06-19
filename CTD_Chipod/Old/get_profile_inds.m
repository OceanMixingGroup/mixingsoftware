function [inds]=get_profile_inds(p,min_p);
% june and jonathan don't know why this needs to be so complicated.  fix
% this later.

inds=find(p>min_p);
inds=inds(1):inds(end);

return

[dummy,maxi]=max(p);

first_ind=max(find(p(1:maxi)<min_p));
last_ind=min(find(p(maxi:end)<min_p))+maxi;

if isempty(first_ind)
    [dummy,first_ind]=min(p(1:maxi));
last_ind=maxi;      
end

inds=first_ind:last_ind;
