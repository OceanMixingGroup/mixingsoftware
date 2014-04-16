% qv_selectall - Selects all the buttons in qv so that you can
% just look at a few at once.

% $Date: 2008/01/31 20:22:48 $ $Revision: 1.1.1.1 $ $Author: aperlin $

for i=1:length(q.series)
  h.selected(i)=qv_sel(h.select(i),0,h.update(i));
end;
qv_now