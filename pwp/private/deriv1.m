%deriv1.m		discetized first derivative
%	[newx,f_x]=deriv1(f,dx,x,order) returns the first derivative (to 'order' accuracy)
%		at the points in 'newx'.  The last three input arguments are optional, but 
%		they must be specified in the order shown.  That is, it is not possible to 
%		specify 'x' but not 'dx', for example.
%
%		The order can be chosen to be either 2 or 4, and f can be either a vector
%		or matrix.  (It would be straightforward to modify this routine for a 3D array).
%		The routine uses the size of x to decide which dimension of f on which to operate.
%
%function [newx,df/dx]=derivative1(f,dx,x,order)
%
%	Tom Farrar, 2003

function [newx,f_x]=derivative1(f,varargin)

nvarg=nargin;
if nvarg==1
   order=2;
   dx=1;
   x=0:dx:length(f)-1;
elseif nvarg==2
   order=2;
   dx=varargin{:};
   x=0:dx:length(f)-1;
elseif nvarg==3
   order=2;
   dx=varargin{1};
   x=varargin{2};
elseif nvarg==4
   order=varargin{3};
   dx=varargin{1};
   x=varargin{2};
end

sizef=size(f);
dim=find(sizef==length(x));


if dim==2;
if order==4
   newx=x(3:end-2);
   f_x=(-f(:,5:end)+8.*f(:,4:end-1)-8.*f(:,2:end-3)+f(:,1:end-4))./(12.*dx);
end
if order==2
   newx=x(2:end-1);
   f_x=(f(:,3:end)-f(:,1:end-2))./(2.*dx);
end
end%dim=2

if dim==1;
if order==4
   newx=x(3:end-2);
   f_x=(-f(5:end,:)+8.*f(4:end-1,:)-8.*f(2:end-3,:)+f(1:end-4,:))./(12.*dx);
end
if order==2
   newx=x(2:end-1);
   f_x=(f(3:end,:)-f(1:end-2,:))./(2.*dx);
end
end%dim=1



