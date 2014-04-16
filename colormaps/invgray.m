function g = invgray(m)
% Inversed gray colormap (max values are black, minimum values are white)
%GRAY   Linear gray-scale color map.
%   GRAY(M) returns an M-by-3 matrix containing a gray-scale colormap.
%   GRAY, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(gray)
%
%   See also HSV, HOT, COOL, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
g = (m-1:-1:0)'/max(m-1,1);
g = [g g g];
