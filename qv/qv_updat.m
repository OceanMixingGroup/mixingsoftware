% Controls updating of voltages beside the sensor names.  Nearest
% sensor is made bold.

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:48 $ $Author: aperlin $	
% originally J. Nash

q.pt = get(gca,'CurrentPoint');
q.py=min(maxs.y,max(mins.y,-q.pt(1,2)));
q.px=min(maxs.x,max(mins.x,q.pt(1,1)));
q.frac=(q.py-mins.y)/(maxs.y-mins.y);  
q.fracx=(q.px-mins.x)/(maxs.x-mins.x); 

if strcmp(q.plot_type,'spread')
  closest = max(1,ceil(q.px*q.nplots));
end;

if ~q.frac | ~q.fracx
  return
end
q.ind=mins.ind+q.frac*(maxs.ind-mins.ind);
for i=1:q.nplots
  sername = upper(deblank(q.series(q.display_series(i),:)));
  dat = getfield(data,sername);
  irepp = getfield(head.irep,sername);
  
  val=dat(round(q.ind*irepp));
  set(h.update(q.display_series(i)),'string',sprintf('%4.5f',val), ...
		    'fontweight','norm')
  
  if i==closest
    set(h.update(q.display_series(i)),'fontweight','bold');
    set(h.select(q.display_series(i)),'fontweight','bold');
  else
    set(h.select(q.display_series(i)),'fontweight','norm');
  end
   
end
 