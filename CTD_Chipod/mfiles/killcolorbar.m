function killcolorbar(ahcbu)
%function killcolorbar(ahcbu)
%Hide the specified color bar.  This works by hiding the specified axis and all of its children.
set(ahcbu,'visible','off');
ahc=get(ahcbu,'children');
set(ahc,'visible','off');
