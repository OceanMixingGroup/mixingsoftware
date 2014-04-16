
%
%  function arrow6(start, stop, scale, linewid, beta, fillah)
%                        
%  Draw a 2-d dashed line (vector) with an arrowhead at the tip.
%  Seems to work in Matlab4 and Matlab5.
%  Modified to do red lines.
%
%  start is the x,y point where the arrow starts.
%  stop is the x,y point where the arrow stops.
%  scale sets the size of the arrowheads.  Units are non-d (ie, 0 to 1) 
%    and a reasonable first guess is 0.03.  Optional.
%  linewid is the width of the shaft and arrowhead in pixels units.
%    A reasonable first guess would be 1.6.  Optional, but you must 
%    input scale if you want to use this.
%  beta is the angle in radians setting the sharpness of the arrowhead.
%    A reasonable choice is pi/6. Optional, but input scale and linewid
%    if you want to use this.
%  fillah is a flag to be set = 1 if you want to fill in the arrowheads
%    and as before you have to put in the other optional things first.
%    Optional.
%
%  It is assumed that the axis limits are set before coming here.
%
%
%  By Jim Price, June 1997.  Started with and remains about 60% from 
%    the routine arrow4 of the contributed Matlab routines.  This code
%    provided most of the calculations.  JP made several fixes and quite a 
%    few additions, and checked that this works in Matlab5.  This is  
%    written in very simple code and should be easy to modify for 
%    other purposes.   
%
%

function arrow6(start, stop, scale, linewid, beta, fillah)

%  Get the axis ranges set before coming to this routine.

  xl = get(gca, 'xlim');
  yl = get(gca, 'ylim');
  xd = xl(2) - xl(1); 
  yd = yl(2) - yl(1); 

%  Set the scale for the arrow size so that arrow will 
%    appear in correct proportion in the current axis.

 xdif = stop(1) - start(1);
 ydif = stop(2) - start(2);

 if nargin==2
  scale = .03;    %  Set the default arrowhead size.
 end

 axis(axis)

 if( (xdif == 0) & (ydif < 0) )       %  In case xdif is zero.
  theta = -pi/2;
 elseif( (xdif == 0) & (ydif > 0) )
  theta = pi/2;
 else
   theta = atan((ydif/yd)/(xdif/xd));
 end

 if(xdif >= 0)
  scale = -scale;
 end

%  xd and yd are x and y expansion factors, respectively.
%    Multiply x-component of arrowhead by xd and y-component by yd so 
%    that the arrowhead appears undistorted. 

%  The sharpness of the arrowhead is set by the angle beta (radians).
%    beta = pi/6 is OK, so is pi/4.

 betar = pi/6;
 if nargin == 5
  betar = beta;
 end

 xcoeff = scale*xd;
 ycoeff = scale*yd;

 xs = [start(1), stop(1)];    %  Coordinates of the arrow shaft.
 ys = [start(2), stop(2)];

 xah = [stop(1), (stop(1)+xcoeff*cos(theta+betar)), NaN, stop(1),... 
  (stop(1)+xcoeff*cos(theta-betar))]';    %  coord of the arrowhead
 yah = [stop(2), (stop(2)+ycoeff*sin(theta+betar)), NaN, stop(2),... 
  (stop(2)+ycoeff*sin(theta-betar))]';

 hold on

%  Plot the shaft and the arrowhead.  You could easily change the
%    kind of line used for the shaft, if you needed to.
 
 if nargin >= 4
  hp = plot(xs, ys, 'LineWidth', linewid);   %  plot the shaft
  hah = plot(xah, yah, 'LineWidth', linewid)      %  plot the arrowhead
  else
  hp = plot(xs, ys, 'LineWidth', 1.6);
  hah = plot(xah, yah, 'LineWidth', 1.6);
 end        %  if on whether to redefine linewidth

set(hp,'Color','g'); set(hah, 'Color', 'g')

%  To fill in the arrowhead, continue through here.

 if nargin == 6
 if fillah == 1
  xf = [xah(1) xah(2) xah(5) xah(1)];
  yf = [yah(1) yah(2) yah(5) yah(1)];

%  The next section makes slightly meaner looking arrowheads.

  xmid = (xah(2) + xah(5))/2; ymid = (yah(2) + yah(5))/2;
  xxmid = 0.6*xmid + 0.4*xah(1); yymid = 0.6*ymid + 0.4*yah(1);
  xf = [xah(1) xah(2) xxmid xah(5) xah(1)];
  yf = [yah(1) yah(2) yymid yah(5) yah(1)];

%  Define the color of the arrowhead; use the color of the arrow.

  col = get(hp,'Color');
  fill(xf, yf, col);   

 end; end   %  ifs on whether to make filled arrowheads.

%  The end of arrow6.




