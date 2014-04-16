function [in,min_ind,max_ind]=extrapolate_depth_range(in,number)
% function [min_ind,max_ind]=extrapolate_depth_range(variable,number)
% extrapolate_depth_range.m is a script to extrapolate a VARIABLE over the extra 
% extra NUMBER of points (default=500)
global data cal head

if ~(nargin-1)
  number=500;
end
len=length(in);
flipsize=min(len,number);

in=[2*in(1)-in(flipsize:-1:1) ; ...
  in ; ...
  2*in(len)-in((len-1):-1:(len-flipsize))] ;

min_ind=(flipsize+1);
max_ind=(flipsize+len);