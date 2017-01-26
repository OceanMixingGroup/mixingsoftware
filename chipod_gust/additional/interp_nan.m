function A = interp_nan(x,A,dim)
%% function B = interp_nan(x,A,dim)
% This function can be used to interp over a view nans in a matrix
% x is the dimension
% dim dimension in A
% Matrix

if(dim==1)
    for i = 1:size(A,2)
        ii = find(isnan(A(:,i)));
        ij = find(~isnan(A(:,i)));
        A(ii,i) = interp1(x(ij),A(ij,i),x(ii));
    end
else
    for i = 1:size(A,1)
        ii = find(isnan(A(i,:)));
        ij = find(~isnan(A(i,:)));
        A(i,ii) = interp1(x(ij),A(i,ij),x(ii));
    end
end


return