function h=jtext(str,x,y,varargin);
  if ~exist('x','var')
    x=.05;
  end
  if ~exist('y','var')
    y=1.05;
  end
  h=text(x,y,str,'units','normalized','fontweight','bold',varargin{:});
  end
