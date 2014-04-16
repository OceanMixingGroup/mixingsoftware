function y = rms(x,dim)
%RMS   Root Mean Square value.
%   RMS normalizes Y by N if N>1, where N is the sample size of the elements.
%   For vectors, RMS(X) is the rms value of the elements in X. For
%   matrices, RMS(X) is a row vector containing the rms value of
%   each column.  For N-D arrays, RMS(X) is the rms value of the
%   elements along the first non-singleton dimension of X.
%
%   RMS(X,DIM) takes the rms along the dimension DIM of X. 
%
%   Example: If X = [0 1 2
%                    3 4 5]
%
%   then rms(X,1) is [2.1213 2.9155 3.8079] and rms(X,2) is [1.2910
%                                                     4.0825]
%
%   Class support for input X:
%      float: double, single
%
%   See also MEAN, MEDIAN, STD, MIN, MAX, VAR, COV, MODE.


if nargin==1, 
  % Determine which dimension mean will use
  dim = min(find(size(x)~=1));
  if isempty(dim), dim = 1; end
end

y = sqrt(mean(x.^2,dim));
