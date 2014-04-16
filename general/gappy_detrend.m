function y = gappy_detrend(x,o,bp)
%y = gappy_detrend(x,o,bp)
%
%Gappy_detrend - G. Avicola 4 Feb, 2004
%Based upon the matlab Detrend program:
%----
%   Author(s): J.N. Little, 6-08-86
%   	   J.N. Little, 2-29-88, revised
%   	   G. Wolodkin, 2-02-98, added piecewise linear fit of L. Ljung
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:45 $
%----
%added capability to detrend constant or linear trends from a timeseries
%with gaps in the data.  Gaps are simply linearly interpelated over.

if nargin < 2, o  = 1; end
if nargin < 3, bp = 1; end

n = size(x,1);
if n == 1,
  x = x(:);			% If a row, turn into column vector
end
N = size(x,1);

switch o
case {0,'c','constant'}
  y = x - ones(N,1)*gappy_mean(x);	% Remove just mean from each column

case {1,'l','linear'}
  bp = unique([1;bp(:);N]);	% Include both endpoints

  len=length(bp)-1;
 
  for n=1:len;
      xx=x(bp(n):bp(n+1));
      xx=gappy_filt(1,'l0.499999999',2,xx,1000000000,1,0);
      good=find(~isnan(xx));
      bad=find(isnan(xx));
      M=length(good);
      a(1:M)=[1:M]'/M;
      window=bp(n):bp(n+1);
      y(window)=NaN;
      window=good+bp(n)-1;
      y(window)=x(window)-a'*(a'\xx(good));
  end     
  y=y-ones(1,N)*gappy_mean(y);
      
      	
      
      


otherwise
  % This should eventually become an error.
  warning('MATLAB:detrend:InvalidTrendType', ...
      'Invalid trend type ''%s''.. assuming ''linear''.',num2str(o));
  y = detrend(x,1,bp); 

end

if n == 1
  y = y.';
end
