function h_out=add_second_axis(h,xpos,xsize,ysize)
%  function add_second_axis(h,xpos,xsize,ysize) adds a second axis on top
%  of the current plot.  h is a handle to the plot, xpos is the
%  horizontal position in data units, xsize is the width of the plot in
%  normalized units, and ysize is the vertical extent of the axes.
% 
%  for example, xsize=[-.05 .05] and ysize=[.1 .9] will create a new axis
%  at xpos extending equally to the left and right .05 units, and will
%  extend from 10% to 90% of the current y extent.
  
  if nargin<4
    % Make the plot full height
    ysize=[0 1];
  end

    if nargin<3
    % Make the plot 10% of the current plot
    xsize=[-.05 .05];
  end

  xlims=get(h,'xlim');
  ylims=get(h,'ylim');
  
  pos=get(h,'position');
  ydirs=get(h,'ydir'); % this is normal or reverse.
  %axes(h),  hold on
  
  new_xcenter=(xpos-xlims(1))/(xlims(2)-xlims(1))*pos(3)+pos(1);
  new_min_x=new_xcenter+xsize(1)*pos(3);
  new_x_width=(xsize(2)-xsize(1))*pos(3);
  
  new_min_y=pos(2)+ysize(1)*pos(4);
  new_y_height=(ysize(2)-ysize(1))*pos(4);
  
  h_out=axes('position',[new_min_x new_min_y new_x_width new_y_height]);
  plot(1),hold on
  set(h_out,'color','none','yticklabel','','xticklabel','');
  axes(h_out);
  ylim(ylims);
set(h_out,'ydir',ydirs,'ytick',[],'box','off','xtick',[],'xticklabel','');
ydirs
