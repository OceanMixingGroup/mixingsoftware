function xnew=gmin(x)
%function xnew=gmin(x)
% just like mix, except that it skips over bad points
[imax,jmax]=size(x);

for j=1:jmax
       good=find(finite(x(:,j)));
       if length(good)>0
          xnew(j)=min(x(good,j));
       else
          xnew(j)=NaN;
       end
end
