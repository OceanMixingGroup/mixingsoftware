function multi_print(in,tp,opt,varargin)
%  multi_print(in,tp,opt,varargin) prints a figure IN in TP format 
%  (PNG, JPEG, PDF, EPS, TIFF: all or any of them)
%  TP could be specified as 'pngjpgtiff' or {'png,'eps','pdf'} 
%  default is set to 'png'
%  OPT is one of 'tall','portrait','landscape' or 'same'
%  default OPT is a current Matlab setting
%  varargin specify quality of the output figure
%  i.e. '-djpeg75','-r300' (defaults are '-djpeg90' and '-r0')
%  required arguments: IN
%  optional arguments: TP, OPT, VARARGIN
%  examples:
%  multi_print('c:\work\sw06\figs\','pngtiffeps','same','-r300')
%  multi_print('c:\work\sw06\figs\',{'pdf','jpg'},'landscape','-djpeg95','-r150')
    
  if ~nargin
    warning('Did Nothing')
    return
  end
  if nargin==1
    tp='png';
    opt=orient;
  elseif nargin==2
    opt=orient;
  end
  tmp=findstr('.',in);
  if tmp
    in=in(1:tmp-1);
  end
 tp=char(tp);tp=tp';tp=tp(:)';
  if strmatch(opt,'portrait')
    opt='portrait';
  orient(gcf,opt)
  elseif strmatch(opt,'landscape')
    opt='landscape';
    orient(gcf,opt)
  elseif strmatch(opt,'tall')
    orient(gcf,opt)
  elseif strmatch(opt,'same')
    h=gcf;
    oldfigunits=get(h,'units');
    paperunits=get(h,'paperunits');
    set(h,'units',paperunits);
    figpos=get(h,'paperposition');
    ht=figpos(4);% the figure's height and width
    wd=figpos(3);
    psize=get(h,'papersize');
    left_os=(psize(1)-wd)/2;
    bot_os=(psize(2)-ht)/2;
    set(h,'paperposition',[left_os bot_os wd ht],'paperpositionmode','auto')
    set(h,'units',oldfigunits)
    opt='port';
  end
  if findstr('-djpeg',cat(2,varargin{:}));
      ff=findstr('-djpeg',cat(2,varargin{:}));
      tt=cat(2,varargin{:});
      jpegres=tt(ff:ff+7);
      varargin=setdiff(varargin,{jpegres});
  end
  % Delete the png file if it exists.
  if  exist([in '.png'])==2
    try
      delete([in '.png']);
    end
  end
  % Delete the jpg file if it exists.
  if  exist([in '.jpg'])==2
    try
      delete([in '.jpg']);
    end
  end
  % Delete the tiff file if it exists.
  if  exist([in '.tiff'])==2 || exist([in '.tif'])==2
    try
      delete([in '.tiff']);
      delete([in '.tif']);
    end
  end
  % Delete the eps file if it exists.
  if  exist([in '.eps'])==2
    try
      delete([in '.eps']);
    end
  end
  % Delete the pdf file if it exists.
  if  exist([in '.pdf'])==2
    try
      delete([in '.pdf']);
    end
  end
  if isempty(tp)
      eval(['png_' opt(1:4) '(''' in '.png'',varargin{:})'])
  end
  if findstr(tp,'png')
      eval(['png_' opt(1:4) '(''' in '.png'',varargin{:})'])
  end
  if findstr(tp,'eps')
      print('-depsc2','-painters',[in])
  end
  if findstr(tp,'jp')
      jpgargin=[{jpegres} varargin];
      eval(['jpeg_' opt(1:4) '(''' in '.jpg'',jpgargin{:})'])
  end
  if findstr(tp,'ti')
      eval(['tiff_' opt(1:4) '(''' in '.tiff'',varargin{:})'])
  end
  if findstr(tp,'pdf')
      if ~isunix
          eval(['pdf_' opt(1:4) '(''' in '.pdf'',varargin{:})'])
      else
          unix(['epstopdf ' in '.eps -o=pdf/' in '.pdf']);
      end
  end

%%  
function png_land(varargin)
% function png_port(fname) writes a png file to fname in
% landscape mode.  Defaults to screen resolution.  All
% defaults can be overridden by specifying them....

orient landscape
set(gcf,'paperorient','portrait')
print('-dpng','-r300',varargin{:})
return


function png_port(varargin)
% function png_port(fname) writes a png file to fname in
% portrait mode.  Defaults to screen resolution.  All
% defaults can be overridden by specifying them....

orient portrait
set(gcf,'paperorient','portrait')
print('-dpng','-r300',varargin{:})
return

function png_tall(varargin)
% function png_tall(fname) writes a png file to fname in
% portrait mode TALL.  Defaults to screen resolution.  All
% defaults can be overridden by specifying them....

orient tall
set(gcf,'paperorient','portrait')
print('-dpng','-r300',varargin{:})
return

%%
function tiff_land(varargin)
% function png_port(fname) writes a tiff file to fname in
% portrait mode.  Defaults to screen resolution.  All
% defaults can be overridden by specifying them....

orient landscape
set(gcf,'paperorient','portrait')
print('-dtiff','-r0',varargin{:})
return


function tiff_port(varargin)
% function png_port(fname) writes a tiff file to fname in
% portrait mode.  Defaults to screen resolution.  All
% defaults can be overridden by specifying them....

orient portrait
set(gcf,'paperorient','portrait')
print('-dtiff','-r0',varargin{:})
return

function tiff_tall(varargin)
% function png_tall(fname) writes a tiff file to fname in
% portrait mode TALL.  Defaults to screen resolution.  All
% defaults can be overridden by specifying them....

orient tall
set(gcf,'paperorient','portrait')
print('-dtiff','-r0',varargin{:})
return

%%
function pdf_land(varargin)
% function png_port(fname) writes a pdf file to fname in
% portrait mode.  Defaults to screen resolution.  All
% defaults can be overridden by specifying them....

orient landscape
set(gcf,'paperorient','portrait')
print('-dpdf','-r300',varargin{:})
return


function pdf_port(varargin)
% function pdf_port(fname) writes a pdf file to fname in
% portrait mode.  Defaults to screen resolution.  All
% defaults can be overridden by specifying them....

orient portrait
set(gcf,'paperorient','portrait')
print('-dpdf','-r300',varargin{:})
return

function pdf_tall(varargin)
% function png_tall(fname) writes a pdf file to fname in
% portrait mode TALL.  Defaults to screen resolution.  All
% defaults can be overridden by specifying them....

orient tall
set(gcf,'paperorient','portrait')
print('-dpdf','-r300',varargin{:})
return

%%
function jpeg_land(varargin)
% function jpeg_port(fname) writes a jpeg file to fname in
% portrait mode.  Defaults to 90% quality, screen resolution.  All
% defaults can be overridden by specifying them....

orient landscape
set(gcf,'paperorient','portrait')
if findstr('-djpeg',cat(2,varargin{:}))
    print('-r0',varargin{:})
else
    print('-djpeg90','-r0',varargin{:})
end
return


function jpeg_port(varargin)
% function jpeg_port(fname) writes a jpeg file to fname in
% portrait mode.  Defaults to 90% quality, screen resolution.  All
% defaults can be overridden by specifying them....

orient portrait
set(gcf,'paperorient','portrait')
if findstr('-djpeg',cat(2,varargin{:}))
    print('-r0',varargin{:})
else
    print('-djpeg90','-r0',varargin{:})
end
return

function jpeg_tall(varargin)
% function jpeg_tall(fname) writes a jpeg file to fname in
% portrait mode TALL.  Defaults to 90% quality, screen resolution.  All
% defaults can be overridden by specifying them....

orient tall
set(gcf,'paperorient','portrait')
if findstr('-djpeg',cat(2,varargin{:}))
    print('-r0',varargin{:})
else
    print('-djpeg90','-r0',varargin{:})
end
return

