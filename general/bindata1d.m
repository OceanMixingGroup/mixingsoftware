function [meanX,VarX,nX]=bindata1d(binx,x,X);
%
% BINDATA1 does 1-D data binning.
%
% Drives bindrv.  [meanX,varX,nX]=bindata(binx,x,X); Where X is the
% data to binned.  X is located at points (x).  binx is the bins to
% put the data is.  Caution: binx and biny are not implemented to
% accept uneven bins.  If there is a need I can do this with some more
% work.
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
% Originally J Klymak

biny = [0 1e6];

% check the dimensions
if size(binx,1)>1
  binx=binx';
  flip=1;
else
  flip=0;
end;
if size(binx,1)>1
  error('Can only accept a column vector for binx');
end;

good = find(~isnan(x) & ~isnan(X));
x=x(good)';
X=X(good)';

%%
y = 100+0*x';
y=y';
%%


[meanX,VarX,nX]=bindata(binx,biny,x,y,X);
bad = find(nX==0);
meanX(bad) = NaN;VarX(bad)=NaN;

if flip
  meanX=meanX';
  VarX=VarX';
  nX=nX';
end;

%keyboard;



