function [order inds thorpe]=thorpeSort(in,z);
% [ORDER]=thorpeSort(IN) simply sorts the series IN - ignoring NaN's -
% and returns it to ORDER (NaN's in the same location).
% 
% IN must be a vector.
% 
% The Form:
% [ORDER INDS]=thorpeSort(...) gives the indices of the sort so that:
% ORDER=IN(INDS)
% Note: if NaN's exist in IN, then this will require:
% ORDER(~isnan(INDS))=IN(~isnan(INDS))
% 
% The Form:
% [ORDER INDS THORPE]=thorpeSort(IN,Z) gives the thorpe displacement profile
% THORPE.
% In this case, if length(IN) is a positive integer multiple of
% length(Z) IN is median-decimated to the length of Z.

if nargin>1
  irp=length(in)/length(z);
  if irp>1
    in=nanmedian(reshape(in,irp,length(z)),1)';
  end
end

gd=find(~isnan(in));
[srt ind]=sort(in(gd));
ind=gd(ind);

order=in*NaN;
order(gd)=srt;

if nargout>1
  inds=NaN*in;
  inds(ind)=ind;
  if nargout>2 & nargin>1
    thorpe=zeros(size(in));
    thorpe(ind)=z(ind)-z(gd);
  end
end
