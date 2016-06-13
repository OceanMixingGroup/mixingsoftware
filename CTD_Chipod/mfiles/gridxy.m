function gridxy
%%%%%%%%%%%%
%
% Draw x-y axes on current figure
%
% AP 25 May 2011
%
%%
lims=axis(gca);
hold on
hy=line([lims(1) lims(2)],[0 0]);set(hy,'color','k');
hx=line([0 0],[lims(3) lims(4)]);set(hx,'color','k');
axis(lims);
hold off
return
%%
