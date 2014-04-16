function rr=nanconf(x,conflimits)
% rr=nanconf(x,conflimits)
% Mean value with confidence intervals (input in %) ignoring NaNs
% default value for confidence intervals 95% (confint=95)
% (treating NaNs as missing values)
% for normally distributed population
% For vectors, nanconf(x) is the means and confidence intervals of the
% non-NaN elements in X.  For matrices, nanconf(x) is a 3 row matrix
% containing the means and confidence intervals of each column,
% ignoring NaNs.
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
% Originally A. Perlin, January 2003

if nargin<2
    Zalphaovertwo=[-1.96 1.96]; % for 95% confidence interval
else
    conflimits=conflimits/100;
    p = [(1-conflimits)/2 conflimits+(1-conflimits)/2];
    Zalphaovertwo = norminv(p,0,1);
end
nans = isnan(x);
if min(size(x))==1,
   count = length(x)-sum(nans);
else
   count = size(x,1)-sum(nans);
end
% Protect against a column of all NaNs
i = find(count==0);
count(i) = ones(size(i));

sig=nanstd(x);

rr(2,:)=nanmean(x);
rr(1,:)=rr(2,:)+Zalphaovertwo(1)*sig./sqrt(count);
rr(3,:)=rr(2,:)+Zalphaovertwo(2)*sig./sqrt(count);
