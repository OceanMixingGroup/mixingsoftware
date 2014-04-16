function h=facetsurface(x,y,z);
% h=facetsurface(x,y,z);  Makes a surface plot with one bin per data. 
%
% Surface interpolates between vertex points.  Facetsurface makes
% a patch for each data point with no interpolation.  This allows
% displaying data with variable x and y spacing which image cannot
% do properly.  Similarly NaN data is plotted properly.
%
% See also SURFACE, IMAGE
  
% J. Klymak, 2001.  
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:46 $ $Author: aperlin $

% fix if x and y are the wrong dim.  

[M,N]=size(x);
if M==1
elseif N==1
  x=x';
else
  x=x(1,:);
end;
[M,N]=size(y);
if M==1
elseif N==1
  y=y';
else
  y=y(:,1)';
end;

  
newx = sort([x(1)-(x(2)-x(1))/2 repmat(x(1:end-1)+diff(x)/2,1,2) ...
	     x(end)+(x(end)-x(end-1))/2]);
x=y;
newy = sort([x(1)-(x(2)-x(1))/2 repmat(x(1:end-1)+diff(x)/2,1,2) ...
	     x(end)+(x(end)-x(end-1))/2]);


% Now remake z...
newz = zeros(2*size(z,1),2*size(z,2));
newz(1:2:end,1:2:end) = z; 
newz(2:2:end,2:2:end) = z; 
newz(2:2:end,1:2:end) = z; 
newz(1:2:end,2:2:end) = z; 
h=surface(newx,newy,newz);
holding= ishold;
if ~holding
  hold on;
end;

% horrid hack to get around ocasional bug???
plot(newx(end),newy(end),'.','markersize',0.00001);
if ~holding
  hold off;
end;
