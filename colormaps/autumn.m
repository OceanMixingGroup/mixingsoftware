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
r = (0:m-1)'/max(m-1,1);
c = [ones(m,1) r zeros(m,1)];

