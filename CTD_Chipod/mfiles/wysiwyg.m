function wysiwyg
%WYSIWYG -- this function is called with no args and merely
%       changes the size of the figure on the screen to equal
%       the size of the figure that would be printed, 
%       according to the papersize attribute.  Use this function
%       to give a more accurate picture of what will be 
%       printed.
%       Dan(K) Braithwaite, Dept. of Hydrology U.of.A  11/93

% $Author: jklymak $ $Revision: 1.2 $ $Date: 2002/08/28 15:51:10 $
unis = get(gcf,'units');
ppos = get(gcf,'paperposition');
set(gcf,'units',get(gcf,'paperunits'));
pos = get(gcf,'position');
pos(3:4) = ppos(3:4);
pos(1:2) = [0.2 0.5];
set(gcf,'position',pos);
set(gcf,'units',unis);
  
