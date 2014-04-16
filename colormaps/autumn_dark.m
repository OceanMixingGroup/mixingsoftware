function c = autumn(m)
%AUTUMN Shades of red and yellow color map.
%   AUTUMN(M) returns an M-by-3 matrix containing a "autumn" colormap.
%   AUTUMN, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(autumn)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright (c) 1984-96 by The MathWorks, Inc.
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end

m1=ceil(m*0.42);
m2=m-2*m1;
r = (0:m1-1)'/max(m1-1,1);
c = [ones(m1,1) r zeros(m1,1)];
r = (0:m2-1)'/max(m2-1,1);
c2= [ ones(m2,1) ones(m2,1) r];

r = 0.4*(m1-1)/max(m1-1,1)+0.6*(0:m1-1)'/max(m1-1,1);
c1= [ r zeros(m1,1) zeros(m1,1)];

c=[c1;c;c2];

