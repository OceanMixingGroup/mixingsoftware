function h=colorline(x,y,c,lw);
% function h=colorline(x,y,c,lw);
%
% Makes a filled color line at x,y with color c.  lw is the line
% width.
%

if nargin<4
  lw=4;
end;
  
if size(x,1)>size(x,2)
  x=x';
end;
if size(y,1)>size(y,2)
  y=y';
end;
if size(c,1)>size(c,2)
  c=c';
end;

% now we need to find the NaNs
%good = find(~isnan(x) & ~isnan(y) & ~isnan(c));
%x=x(good);y=y(good);c=c(good);    
xx=[x;x]';yy=[y;y]';  
cc=[c;c]';


% h=surface(xx,yy,cc);
h=pcolor(xx,yy,cc);
set(h,'facecolor','none','edgecolor','flat','linewidth',lw);

