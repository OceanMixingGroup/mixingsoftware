function y = nandemean(x);
% function y = nandemean(x);
% NANDEMEAN removes the mean of data excluding NaN's.
%
% Y = nandemean(X) removes the mean from each column of X, ignoring NaNs.
% If X is a vector it removes the mean of the vector.
%

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
% J. Klymak, Jan, 2003
  
  if size(x,1)==1 & size(x,1)<size(x,2)
    x=x';
    flip=1
  else
    flip=0;
  end;
  
mx = nanmean(x);
y = x-repmat(mx,size(x,1),1);

if flip
  y = y';
end;

