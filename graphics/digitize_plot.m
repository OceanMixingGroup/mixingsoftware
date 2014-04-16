function [x,y]=digitize_plot(file_name,file_type,xscale,yscale)
% function [x,y]=digitize_plot(file_name,file_type,xscale,yscale);
% designet to digitize plots
% returns [x,y] coordinates (in figure units) of the digitized plot
% reads picture in any of the following formats:
% bmp, cur, hdf, jpg, ico, pmb, pcx, pgm, png, ppm, ras, tiff, xwd
% and makes a matlab figure;
% user should follow instructions in matlab working window
% parameters file_type, xscale and yscale are optional
% xscale and yscale are the axses scales
% could be linear ('lin') or logarithmic ('log')
% default value 'lin'
% $Revision: 1.2 $ $Date: 2008/02/26 18:24:16 $ $Author: aperlin $

if nargin<2
    in=find(file_name=='.');
    if ~isempty(in) && (in==length(file_name)-3 || in==length(file_name)-4)
        file_type=file_name(in+1:end);
    else
        file_type=input('What is file type?','s');
    end
end
if nargin<4
    xscale='lin';
    yscale='lin';
end
plot=imread(file_name,file_type);
      
f=figure(1001);clf
im=imagesc(plot);colormap('bone');
%++++ this is nesessary to correct for default revised direction
%++++ of y-axis in new matlab versions
if strncmpi(get(gca,'ydir'),'rev',3)
    ymult=-1;
else
    ymult=1;
end
%++++
disp('Click the plot origin');
[x0,y0]=ginput(1);y0=y0*ymult;
cc=input('What is the origin coordinates? [x0 y0] ');
disp('Select one point on horizontal axis');
[gx,gy]=ginput(1);gy=gy*ymult;
x1=input('What is the point x-coordinate? ');y1=cc(2);
disp('Select one point on vertical axis');
[vx,vy]=ginput(1);vy=vy*ymult;
y2=input('What is the point y-coordinate? ');x2=cc(1);

disp('START DIGITIZING');
disp('HIT RETURN AT THE END');
[plotx,ploty]=ginput;ploty=ploty*ymult;

%++++++++++++++++++++++++++++++++++
% This is in case that figure is rotated relatively to
% the screen
% This part yet in screen coordinates

% Angle of rotation of the figure
alpha=atan2((gy-y0),(gx-x0));
% Distance to the digitized points from
% the origin of the plot
r=sqrt((plotx-x0).^2+(y0-ploty).^2);
% angle between "horizontal" axis and directions
% to the digitized points
theta=atan2((ploty-y0),(plotx-x0))-alpha;
% distance along horizontal figure axis from the origin
% to the digitized points
px=r.*cos(theta);
py=r.*sin(theta);
% distance of selected on horizontal and vertical axes 
% points from the origin 
dx=sqrt((gx-x0).^2+(y0-gy).^2);
dy=sqrt((vx-x0).^2+(y0-vy).^2);
%++++++++++++++++++++++++++++++++++++
if xscale=='lin'
    x=cc(1)+px*(x1-cc(1))/dx;
elseif xscale=='log'
    x=10.^(log10(cc(1))+px*(log10(x1)-log10(cc(1)))/dx);
end

if yscale=='lin' 
    y=cc(2)+py*(y2-cc(2))/dy;
elseif yscale=='log'
    y=10.^(log10(cc(2))+py*(log10(y2)-log10(cc(2)))/dy);
end
if vy<y0; y=-y;end
return