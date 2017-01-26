function out=diffs(var)
%function out=diffs(var)
%Deliver the difference function, but stored in a vector the same size as the
%original.  A zero is stored in the last bin.



[m,n]=size(var);

% if row vector, make into column
if m==1 && n>1
    var=var(:);
end

[m,n]=size(var);
out=zeros(m,n);

out(1:m-1,:)=diff(var);
