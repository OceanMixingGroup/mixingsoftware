function [out,maxind,minind]=extrapolate_data(in,flag,nbins)
%  [out,maxind]=extrapolate_data(in) replaces NaNs at the bottom of
%  a matrix with the last non-NaN value in the matrix.
% returns the last truly valid point as well. 
% May also be called as
% [out,maxind,minind]=extrapolate_data(in,'both'), which replaces
% NaNs at the begining of the matrix as well, and where min_ind
% represents the first valid point in each column.
% Can also be called as:
% [out,maxind,minind]=extrapolate_data(in,'both',nbins), where
% nbins= [top_n bot_n] gives the number of bins to average over
% before extrapolating the data at these values.
%
% see also interp_missing_data, fillgap, fillgap2d
    
  if nargin==1
    upper_lower=0;
  elseif strcmpi(flag,'both')
    upper_lower=1;
  end
  if nargin~=3
    nbins=[1 1];
  end
  if length(nbins)==1
    nbins=[nbins nbins];
  end
  nbins(find(nbins<1))=1;
  
  out=in;
  length_in=size(in,1);
  for a=1:size(in,2)
    tmp=(find(~isnan(in(:,a))));
    max_tmp=max(tmp);
    if ~isempty(max_tmp)
      maxind(a)=max_tmp;
      out((maxind(a)+1):length_in,a)=mean(out(maxind(a)+[-(nbins(2)-1):0],a));
    else
      maxind(a)=1;
    end
    if upper_lower
      min_tmp=min(tmp);
      if ~isempty(min_tmp)
	minind(a)=min_tmp;
	out(1:minind(a),a)=mean(out(minind(a)+[0:(nbins(1)-1)],a));
      else
	minind(a)=1;
      end
    end  
    
  end
