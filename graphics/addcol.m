function z=addcol(x,y,dim)
% function z=addcol(x,y) adds  matrix x (N by M) to a
% vector y (1 by N) or (1 by M);
% Call as addcol(x,y,dim) to specify the dimension to add
% along (if it is ambiquous), otherwise, this just determines which
% dimensions match, and adds appropriately (doesn't work for
% square matrices).
% $Date: 2008/01/31 20:22:45 $ $Revision: 1.1.1.1 $ $Author: aperlin $ 
% Originally J. Nash
  
  if nargin==2
    dim=0; % this is the default behaviour.
  end
  % allow either x or y to be the column vector
  if min(size(x))==1
    tmp=x;,x=y;,y=tmp;
  end
  
  % If the second element is just a numbebr, then just add it and return
  if length(y)==1 | length(x)==1
    z=x+y;
    return
  end
  [n,m]=size(x);
  if n==m & dim==0
    error(['unable to determine which way to add, please specify' ...
	   ' explicitly using addcol(x,y,dim)'])
  elseif (length(y)==n & dim==0) | dim==1
    z=(x'+meshgrid(y,[1:m]))';
    return  
  elseif (length(y)==m & dim==0) | dim==2
    z=x+meshgrid(y,[1:n]);
    return
  else
    error('dimension mismatch')
  end

