function [c] = redblue(m)
%
% redblue  	Sh!ades of red to white to blue colormap.
%		REDBLUE(M) returns an M-by-3 matrix containing a
%		"redblue" colormap.
%               CAVEAT this actually only works properly for even length
%               colormaps.  Some fiddling will get it to work generally.
%
%		See also HSV, COLORMAP, RGBPLOT.

if nargin<1
  m=length(colormap);
end;


x=[0     0  100  100
   20   20   20  100
   35  100  100  100
   65  100  100  100
   80  100   20   20
   100 100  100    0];

x=[0     0  100  100
   25   20   20  100
   49  100  100  100
   51  100  100  100
   75  100   20   20
   100 100  100    0];

pos = x(:,1)/100;
rgb = x(:,2:4)/100;

c = interp1(pos,rgb,(1:m)/m);


