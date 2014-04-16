function h=putonleft(h);
% function h=putonleft(h); 
% puts the text pointed to in h on the upper left of plot.
%

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:46 $ $Author: aperlin $	
% J. Klymak July 2002
  
  set(h,'unit','nor');
  pos = get(h,'pos');
  set(h,'pos',[0 pos(2:3)],'horiz','left');
return; 
