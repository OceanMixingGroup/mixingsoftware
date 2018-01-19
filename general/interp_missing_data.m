function in=interp_missing_data(in,maxgap)
% interp_missing_data interpolates over NaNs in a matrix.
% call as function in=interp_missing_data(in,maxgap).  
% linear interp of the data in the columnwise direction
% maxgap is the biggest gap we allow to fill (default=5).  
%
% see also extrapolate_data, fillgap, fillgap2d
%
% *** (sjw Jan 2018) USE fast_fillgap which is nearly 100x
% faster than this code for large datasets!! ***

if nargin<2
  maxgap=5;
end
[nrow,ncol]=size(in);

% first we replace all of the NaN occurences in order:
for gapsize=1:maxgap
  for k=1:gapsize
      tmp=find(isnan(in));
      tmp=tmp(find(tmp>=(1+k) & tmp<=(nrow*ncol-gapsize+k-1)));
      in(tmp)=((gapsize-k+1)*in(tmp-k)+k*in(tmp-k+gapsize+1))/(gapsize+1);
%      tmp=find(isnan(in));
%      tmp=tmp(find(tmp>=gapsize & tmp<=(nrow*ncol-gapsize)));
  end
end
  
 
