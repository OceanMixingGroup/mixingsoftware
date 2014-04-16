function a=qv_sel(i,j,k)
% function a=qv_sel(i,j,k)
% does the selecting.

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:47 $ $Author: aperlin $	
% originally J.Nash
  
  toggle=['of';'on'];
  a=~j;
  % swap background color if the status really changes...
  sel = get(k,'visible');
  if ~strncmp(toggle(a+1,:),sel,2)
    b=get(i,'foregroundcolor');
    c=get(i,'backgroundcolor');
    set(i,'foregroundcolor',c,'backgroundcolor',b');
  end;
  set(k,'visible',toggle(a+1,:));
