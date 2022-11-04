function agutwocolumn(vextent)
% agutwocolumn(vextent)
% 
% Adjusts the paper size of the current figure to represnt the size of a 
% two column wide figure in AGU format.  (7 inches)
%   vextent - specifies how much of the page space the figure should take
%             vertically.  We assume a text height of 8.5 inches.  Therefore
%             vextent=1/3 implies figure height of 2.833 inches.
%
% Note that this is also a good place to set some defaults for fontsize
% and fontweights.

CWIDTH = 7;
CHEIGHT = 8.5*vextent;

un=get(gcf,'paperunits');
set(gcf,'paperunits','inches','paperpos',[0.75 0.75 CWIDTH CHEIGHT]);
set(gcf,'paperunits',un);

set(gcf,'defaultaxesfontsize',11);
set(gcf,'defaulttextfontsize',11);
set(gcf,'defaultaxesfontweight','normal');
set(gcf,'defaultaxeslinewidth',0.75);
set(gcf,'defaultlinelinewidth',1);
set(gcf,'defaultaxesticklength',[0.01 0.01]*1);

% set the default axes postion.  We need enough room for the
% xlabel and ylabel.  
left = 0.75; % inches...
bot = 9/16; % inches...
right = 0.65;
top = 0.25;

set(gcf,'units','norm');
set(gcf,'defaultaxesposition',...
  [left/CWIDTH bot/CHEIGHT (CWIDTH-(left+right))/CWIDTH (CHEIGHT-(top+bot))/CHEIGHT]);


