function xnew=gmax(x)
%function xnew=gmax(x)
% just like max, except that it skips over bad points
[imax,jmax]=size(x);

for j=1:jmax
       good=find(finite(x(:,j)));
       if length(good)>0
          xnew(j)=max(x(good,j));
       else
          xnew(j)=NaN;
       end
end
