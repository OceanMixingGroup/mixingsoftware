function resize_gca(pp,h)
% RESIZE_GCA([left_coordinate bottom_coordinate width height],handle) 
% resizes the axis handle
% by the amount specified.

  
  if nargin==1
    h=gca;
  end

  pp1=get(h,'position');
  pp1(1:length(pp))=pp+pp1(1:length(pp));
  set(h,'position',pp1)
