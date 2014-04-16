function Hax=closeplot(m,n,i,dx,dy);
%
% Hax=closeplot(m,n,i); Like subplot, bt closer together and without
% erasing anything underneath.
%
% function Hax=closeplot(m,n,i,dx,dy);
%  where dx and dy are the spacing between the plots in points.
%
  
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
% Originally J. Klymak.
if nargin<4
  dx=0;
end;
if nargin<5
  dy=0;
end;
  
uni = get(gcf,'unit');
p=get(gcf,'defaultaxespos');
hh = axes('position',p);
set(gcf,'uni','point');
set(hh,'units','point');
p = get(hh,'pos');
delete(hh);
left=p(1);bot=p(2);top=1-(p(1)+p(3));right=1-(p(2)-p(4));

wid=p(3);len=p(4);

wid_=((wid)-dx*(n-1))/n; len_=(len - dy*(m-1))/m;
y_=m-ceil(i/n -eps);
x_=rem(i-1,n);
% y_=y_-1
Hax=axes('units','points');
set(Hax,'position',[left + (x_)*wid_+x_*dx, ...
		    bot + (y_)*len_+y_*dy, wid_ ,len_]);


set(gcf,'uni',uni);
set(Hax,'uni','norm');