function [cm] = bluegreen(m)
%
% BLUEGREEN  	Shades of blue to green colormap.
%		BLUEGREEN(M) returns an M-by-3 matrix containing a
%		"bluegreen colormap"
%
%		See also HSV, COLORMAP, RGBPLOT.

if nargin<1
	[m,n] = size(colormap);
end;

mid = m/2;

g = [ones(mid,1)',1-(1/mid):-1/mid:0']';
if (m-floor(mid)==mid)
  r = [0:1/mid:1-(1/mid)',1-(1/mid):-1/mid:0']';
else
 r = [0:1/mid:1,1-(1/mid):-1/mid:0']';
end;
 b = [0:1/mid:(1-(1/mid))',ones(mid,1)']';

cm = flipud([r,g,b]);
% darken so that transparencies look good.
cm = brighten(cm,-0.5);
