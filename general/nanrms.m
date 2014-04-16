function Y = nanrms(X,dim)
% Root Mean Sqare ignoring NaN values
% NANRMS normalizes Y by N-1 if N>1, where N is the sample size of the 
% non-NaN elements.  This is an unbiased estimator of the variance of the
% population from which X is drawn, as long as X consists of independent,
% identically distributed samples, and data are missing at random.  For
% N=1, Y is normalized by N.
% Y = nanrms(X) returns the normalized root mean square of the values in X, 
% treating NaNs as missing values. For a vector input, Y is the root mean 
% square of the non-NaN elements of X.  For a matrix input, Y is a row
% vector containing the root mean square of the non-NaN elements in
% each column of X.
% Y = nanstd(X,dim) takes the root mean square along the dimension dim of X.


if nargin==1;  dim=1; end
if dim==2 || size(X,1)==1; X=X'; end
[gr,gc]=find(~isnan(X));
lgd=[];
for ii=1:size(X,2)
    lgd(ii)=sum(gc==ii);
end
lgd(lgd==0)=1;
lgd(lgd<0)=NaN;
Y=sqrt(1./lgd.*nansum(X.^2));
if dim==2 || size(X,1)==1; Y=Y'; end
end

