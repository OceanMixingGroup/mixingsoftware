function ncquiverref(x,y,u,v,units,reftype)

% NCQUIVERREF: Add a reference vector to quiver plot on map or catesian axes
%
% function ncquiverref(x,y,u,v,units,reftype)
%
% This function adds a reference vector to quiver plots on a map
% or cartesian axis. Reference value is calculated by rounding the median or 
% maximum lengths of the quiver vectors to the first significant digit.
%
% Input:
% x       - x-coordinate or latitude
%
% y       - y-coodinated or longitude
%
% u       - u-component (cartesian +x-direction, map +longitude-direction)
%
% v       - v-component (cartesian +y-direction, map +latitude-direction)
%
% units   - character variable providing the units
%
% reftype - character variable of type of reference vector.
%           Allowable values are 'median' for giving a reference
%           vector based on the media, or 'max' for giving the
%           reference vector based on the maximum.  This
%           argument may be omitted with 'median' as the default.
%
% Output:
% Output is graphical to the current figure.
%
% Note that limits must be declared before using this function for the
% reference vector to remain correct. It is assumed the mapping toolbox
% is included in the matlab distribution, if not the section under "ismap"
% may be removed to use this routine without the mapping toolbox.
%
% Written by Andrew Roberts
% International Arctic Research Center &
% Arctic Region Supercomputing Center
%
% $Id: ncquiverref.m,v 1.1 2008/08/04 21:10:07 aperlin Exp $

% set default values
if nargin<3 ; reftype='median'; end
h=get(gcf,'CurrentAxes');

% determine if the axes are map or cartesian, if the former
% calculate mapping to plot axis, and then do vector field
% otherwise just plot the vector field.
if ismap(h)

 disp('Plotting quiver on current map axes')

 % set lat and lon
 lat=x;
 lon=y;

 % get x and y location on the map
 [x,y] = mfwdtran(lat,lon,h,'line');

 % get angle on the map
 [th,z] = cart2pol(u,v);
 [thproj,len] = vfwdtran(lat,lon,90*ones(size(lat)));
 [uproj,vproj] = pol2cart(th+deg2rad(thproj),z);
 z(isnan(x))=NaN;
 h1=quiver(x,y,uproj,vproj,'Color','b');

else

 disp('Plotting cartesian quiver')

 z=sqrt(u.^2 + v.^2);
 h1=quiver(x,y,u,v,'Color','b');
 h=get(gcf,'CurrentAxes');

end

% get the current axes, its limits and set hold
xa=get(gca,'xlim');
yb=get(gca,'ylim');
hold on;

% get the normalized length of the reference vector on the currrent plot
h2=get(h1);
h3=get(h2.Children(1));
Z=z(:);
j=1;
i=1;
notfound=true;
while notfound
	if ~isnan(h3.XData(i)) & ~isnan(h3.XData(i+1)) & ...
	   ~isnan(h3.YData(i)) & ~isnan(h3.YData(i+1)) & ...
	    Z(j) ~= 0.0 ;

		lengthu=abs(h3.XData(i+1)-h3.XData(i));
		lengthv=abs(h3.YData(i+1)-h3.YData(i));
		veclength=Z(j);
		notfound=false;

	end
	j=j+1;
	i=i+3;
	if i>length(h3.XData)-2
		error('No vectors found on this plot greater than zero')
	end
end

% calculate reference vector length based on rounded median
% or maximum value of plot.  The default is median based.
if strcmp(reftype,'median')
	disp('Calculating reference vector based on median');
	refval=median(z(:));
elseif strcmp(reftype,'max')
	disp('Calculating reference vector based on maximum');
	refval=max(z(:));
else
	error('reftype must be either "max" or "median"');
end
roundp=floor(log10(refval));
refval=floor(refval/(10^roundp))*(10^roundp);


% normalize vector length
normallengthx=lengthu/(xa(2)-xa(1));
normallengthy=lengthv/(yb(2)-yb(1));
normallength=refval*sqrt(normallengthx^2+normallengthy^2)/veclength;


% get the position of the current axes and calculate the
% contraction on the new all-frame grid 
pos=get(h,'Position');
normallength=normallength*pos(3);


% start a new axes for drawing the reference vector
hi=axes('OuterPosition',[0 0 1 1],'Position',[0 0 1 1]);
set(gcf,'CurrentAxes',hi);

% get height of font from frame
htext=text(0,0,'test','Visible','off');


% draw a single vector using quiver
quiver(hi,pos(1)+pos(3)-normallength,max(pos(2)-0.05,0.025),...
       normallength,0,'autoscale','off','Color','b');

% format the key to powers of ten if required
if refval < 0.1 | refval > 100 
	factor=floor(log10(refval));
	reftext=[num2str(refval/(10^factor)),' \times 10^{',num2str(factor),'}'];
else
	reftext=[num2str(refval),' ',units];
end

% place text to the right of the vector
text(pos(1)+pos(3)-normallength,max(pos(2)-0.05,0.025),...
     reftext,'HorizontalAlignment','right');

% make the new axes invisible and make sure limits are set 
% (must be done after calling quiver)
set(gca,'XLim',[0 1],'YLim',[0 1],'Visible','off')

% return to original axes
set(gcf,'CurrentAxes',h);
hold off

end % function

