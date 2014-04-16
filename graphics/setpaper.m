function setpaper(varargin)
% function SETPAPER sets the printed output to be the same size as that
% in the window.
if nargin
   fig=varargin{1};
else 
   fig=gcf;
end
oldunits=get(fig,'units');
set(fig,'units','inches');
position=get(fig,'position');
papersize=get(fig,'papersize');
paperposition=[(papersize(1)-position(3))/2 (papersize(2)-position(4))/2 ...
      position(3) position(4)];
set(fig,'paperpositionmode','manual','paperposition',paperposition);
set(fig,'units',oldunits);