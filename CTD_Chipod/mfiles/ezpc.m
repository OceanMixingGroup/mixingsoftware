function h=ezpc(varargin)
%function h=ezpc(varargin)
%SYNTAX 1: first argument is a structure with fields yday and z; pcolor the
%specified variable.
%EXAMPLE: ezpc(SWIMSgrid,'s')
%SYNTAX 2: pass in x, y vectors and a variable to be pcolored.  
%EXAMPLE: ezpc(ADCP.yday,ADCP.z,ADCP.u)
%
%plot a flat-shaded pcolor, y axis increasing downward.  Return handle.
%
%7/07 MHA

if nargin ==2
    s=varargin{1};x=s.yday;y=s.z;var=s.(varargin{2});
elseif nargin ==3
    x=varargin{1};y=varargin{2};var=varargin{3};
end

% added by EPA, Mar 2022:

if numel(y)>length(y)
    y=y(:,1);
end
if numel(x)>length(x)
    x=x(1,:);
end
good_x=find(~isnan(x));
x=x(good_x);
var=var(:,good_x);
newx=[(3*x(1)-x(2)),(x(1:end-1)+x(2:end)),(x(end)*3-x(end-1))]/2;
[x,y]=meshgrid(newx,y);
var=[var,nan(length(y),1)];

% back to original programming:

h=pcolor(x,y,var);shading flat;axis ij
