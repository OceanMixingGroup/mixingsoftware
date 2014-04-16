function [c] = redblue(m)
%
% redblue  	Shades of red to white to blue colormap.
%		REDBLUE(M) returns an M-by-3 matrix containing a
%		"redblue" colormap.
%               CAVEAT this actually only works properly for even length
%               colormaps.  Some fiddling will get it to work generally.
%
%		See also HSV, COLORMAP, RGBPLOT.

if nargin<1
  [m,n] = size(colormap);
end;

mm = m;

p = [0  1 1.5 2 3  4:8 ]/8;

r = [1 0.8 0 0 0 1 1 1 0.8 0.8]';
g = [0 0 0 0 1 1 1 0 0 0]';
b = [0.9 0.9 0.9 1 1 1 0 0 0 1]';

c = interp1(p,[r g b],(1:mm)/mm);


