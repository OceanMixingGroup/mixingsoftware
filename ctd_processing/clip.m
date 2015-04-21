function x=clip(y,miny,maxy);
% function x=clip(y,miny,maxy);
%
% clip y by the min and max.
  
  x=y;
  x(find(x<miny))=miny;
  x(find(x>maxy))=maxy;
  
 