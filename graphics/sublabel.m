function [htext,hnewax]=sublabel(varargin)
% function [htext]=sublabel(haxes,topoffset,leftoffset)
%   
%  sub label labels sub-plots from haxes in order as "a", "b",
%  "c".  By default it puts them in the upper left corner.
%
%  Outputs handles to the text.
%
%  topoffset and left offset are optional and specify in points where the
%  label is to go.
%
%  Labels are made with backgroundcolor='w'.  Set to 'none' if you want
%  transparent backgrounds.  Font size and family can be changed after
%  the fact.  Or, vargin can be argument pairs for the text command.
%
%  eg:
%    >> haxes(1) = subplot(2,1,1);
%    >> plot(1:10);
%    >> haxes(2) = subplot(2,1,1);
%    >> plot(1::2:20);
%    >> htext=sublabel(haxes);
% Or:
%    >> htext =
%    sublabel(haxes,[],[],'fontsize',8,'fontweight','bold','backgroundcolor','g');
  
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:46 $ $Author: aperlin $	
% J. Klymak.  August 8, 2000...
  
  fsize = 12; % default fontsize, points....
  fname = 'times'; % font...
  
  haxes=flipud(datachildren(gcf));
  toffset=12;
  roffset=12;
  num = 0;
  while ~isempty(varargin) & ~isstr(varargin{1})
    num = num+1;
    if num==1
      haxes=varargin{1};
    elseif num==2
      toffset=varargin{1};
    elseif num==3
      roffset=varargin{1}
    else
      error('invalid parameter/value pair.');
    end;
    varargin=varargin(2:end);
  end;
  
  
  for i=1:length(haxes)
    uni = get(haxes(i),'units');
    hnewax(i)=axes('units',uni,'pos',get(haxes(i),'pos'));
    set(hnewax(i),'visible','off','units','points');
    poss = get(hnewax(i),'pos'); % this is how big the axis is in points...
    axis([poss(1) poss(1)+poss(3) poss(2) poss(2)+poss(4)]);
    x = poss(1)+roffset;
    y = poss(2)+toffset;
    set(hnewax(i),'ydir','rev');  
    htext(i)=text(x,y,0,sprintf('%c',['a'+i-1]),'fontname', ...  
      fname,'fontsize',fsize,'backgroundcolor','w',varargin{:});
    set(hnewax(i),'visible','off','units',uni,'hittest','off');
    setappdata(hnewax(i),'NonDataObject',[]); % Used by DATACHILDREN.M.
                                              % This makes it
                                              % invulnerable to zooming etc
  end;
  
  return;

  if 0  
  
  %%%% Old junk
  
  
    %axes(haxes(i));
    dxpoints = poss(3);
    dypoints = poss(4);
    % delete newaxis
    %delete(hnewax(i));

    
    xdata=get(haxes(i),'xlim');
    ydata=get(haxes(i),'ylim');
    if strncmp(get(haxes(i),'xdir'),'rev',3);
      xd=-1;  
      oxdata = xdata(2);
    else
      xd=1;
      oxdata = xdata(1);
    end;
    if strncmp(get(haxes(i),'ydir'),'rev',3);
      oydata = ydata(1);
      yd=-1;
    else
      oydata = ydata(2);
      yd=1;
    end;
    
    % we need to get 12 points over.  But this changes if we are in a log scale. 
    if strncmp(get(haxes(i),'xscale'),'log',3)
      dxdata = diff(log10(xdata))
      xpointstodata = (dxdata/dxpoints);
      x=10^(log10(oxdata)+xd*(xpointstodata*roffset));
    else
      dxdata = diff(xdata)
      xpointstodata = dxdata/dxpoints;
      x=oxdata+xd*xpointstodata*roffset;
    end;
    if strncmp(get(haxes(i),'yscale'),'log',3)
      dydata = diff(log10(ydata))
      ypointstodata = (dydata/dypoints);
      y=10^(log10(oydata)-yd*(ypointstodata*toffset));
    else
      dydata = diff(ydata)
      ypointstodata = dydata/dypoints;
      y=oydata-yd*ypointstodata*toffset;
    end;
    %keyboard;
    
  end;

%%%% Internal little function....
  
function h=extentpatch_int(pos,col);
%  function h=extentpatch(pos);
%    makes  apatch over pos where pos is [x y dx dy]...
%
dx=pos(3);dy=pos(4);
x = [pos(1) pos(1) pos(1)+dx pos(1)+dx pos(1)];
if strcmp(get(gca,'ydir'),'reverse')
  dy=-dy;
end;

y = [pos(2) pos(2)+dy pos(2)+dy pos(2) pos(2)];
h=patch(x,y,col);
