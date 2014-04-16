function yi=nonmoninterp1(x,y,xi,str)
%function yi=nonmoninterp1(x,y,xi,str)
%Interp1 without the requirement that x be monotonic.
%The interpolation is done after sorting.
%5/02: specify str as the argument to interp1; ie linear, nearest, etc.
%Leave out for linear (default).
%1/01 MHA
%
if nargin <4
    str='linear';
end
%First sort
[xs,is]=sort(x);
%Then get rid of duplicates!
ind=find(diff(x(is)) > 0);
%5/03 change: if ind returns only one point use the next point too
if length(ind)==1
    ind=[ind ind+1];
end
if ~isempty(ind) %2/05 change: fix if there are no points
yi=interp1(x(is(ind)),y(is(ind)),xi,str);
else
    yi=NaN*xi;
end
