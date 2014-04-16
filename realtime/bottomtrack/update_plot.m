% read the bottomavoid data stream and update the plot with the current
% info...
bottom = read_bottom_out(bottomfname);
if isempty(bottom)
  return;
end;


set(plotinfo.time,'string',datestr(bottom.time));


axes(plotinfo.posaxes);
if isfield(plotinfo,'posmark')
  if ~isempty(plotinfo.posmark)
    delete(plotinfo.posmark)
  end;
end;

plotinfo.posmark = plot(bottom.lon,bottom.lat,'o','color', cautioncolor, ...
                        'linewidth',2,'markersize',8,'markerfacecolor', ...
                        cautioncolor');

% adjust the axes if necessary....
minlon = min([survey.lonlim(1) bottom.lon - 3000/(60*mpernm)]);  
maxlon = max([survey.lonlim(2) bottom.lon + 3000/(60*mpernm)]);  
minlat = min([survey.latlim(1) bottom.lat - 3000/(60*mpernm)]);  
maxlat = max([survey.latlim(2) bottom.lat + 3000/(60*mpernm)]);  
set(plotinfo.posaxes,'xlim',[minlon maxlon],...
                  'ylim',[minlat maxlat]);
set(plotinfo.lon,'string',num2str(bottom.lon,7));
set(plotinfo.lat,'string',num2str(bottom.lat,7));
set(plotinfo.spdlog,'string',...
                  sprintf('%3.1f m/s (%3.1f knt)',bottom.shipsog,3600* ...
                          bottom.shipsog/(mpernm)));

set(plotinfo.shiphead,'string',num2str(bottom.shiphead,7));

% show the depth from the ships echo-sounder...
if ~isnan(bottom.shipdepth)
  set(plotinfo.bottom_depth,'string',num2str(bottom.shipdepth,7),...
		    'foregroundcolor',forecol);
else
  set(plotinfo.bottom_depth,'foregroundcolor',cautioncolor);
end;

% set Marlin's speed
if ~isnan(bottom.MarlinSpeed)
  set(plotinfo.marlinspeed,'string',sprintf('%3.2f',bottom.MarlinSpeed),...
		    'foregroundcolor',forecol);
  set(plotinfo.marlinspeedknt,...
      'string',sprintf('%3.2f',bottom.MarlinSpeed*3600/mpernm),...
      'foregroundcolor',forecol);
else
  set(plotinfo.marlinspeed,'foregroundcolor',cautioncolor);
  set(plotinfo.marlinspeedknt,'foregroundcolor',cautioncolor);
end;

% set Marlin's depth
if ~isnan(bottom.MarlinDepth)
  set(plotinfo.marlin_depth,'string',sprintf('%4.1f',bottom.MarlinDepth),...
		    'foregroundcolor',forecol);
  if ~isnan(bottom.shipdepth) 
    set(plotinfo.depthdiff,'string',...
		      num2str(bottom.shipdepth-bottom.MarlinDepth,7),...
		      'foregroundcolor',forecol,'fontsize',20);
  end;
  if (bottom.shipdepth-bottom.MarlinDepth<DEPTHWARN)
    set(plotinfo.depthdiff,'foregroundcolor','r','fontsize',25);
  end;
else
  set(plotinfo.marlin_depth,'foregroundcolor',cautioncolor);
end;

% set OA's distance to bottom...
if ~isnan(bottom.adcprange)
  set(plotinfo.marlinOA,'string',num2str(bottom.adcprange,5),...
		    'foregroundcolor',forecol);
else
  set(plotinfo.marlinOA,'foregroundcolor',cautioncolor);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the bottom depth plot

axes(plotinfo.depthaxes);
hold on;
[bottom.x,bottom.y] = j_ll2xy(bottom.lon,bottom.lat,survey.cenlat);

bottom.x=bottom.x-survey.x(1);
bottom.y=bottom.y-survey.y(1);
% rotate into along/cross track  
bottom.along = xytoalong(survey.x-survey.x(1),survey.y-survey.y(1),bottom.x,bottom.y);

plotinfo.mdepth = [plotinfo.mdepth ...
  plot(bottom.along/1e3,bottom.MarlinDepth,'.',...
       'color',trackcolor,'linewidth',0.5)];
axis('ij');
plotinfo.along=[plotinfo.along plot(bottom.along/1e3,...
     bottom.shipdepth,'r.','linewidth',2)];


%ppa
% stop these from getting too large and crashing the computer.
N = 2000;
if length(plotinfo.mdepth)>2*N
  display('Updating');
  delete(plotinfo.mdepth(1:N));
  plotinfo.mdepth=plotinfo.mdepth(N+1:2*N);
  delete(plotinfo.along(1:N));
  plotinfo.along=plotinfo.along(N+1:2*N);
end;

if ~isempty(plotinfo.marlindepthx)
  delete(plotinfo.marlindepthx);
end;
plotinfo.marlindepthx=plot(bottom.along/1e3,bottom.MarlinDepth, ...
                           '.','markersize',12,'color','r', ...
                           'linewidth',3);

zhi = str2num(get(plotinfo.zdown,'string'))+bottom.MarlinDepth;
zlow = -str2num(get(plotinfo.zup,'string'))+bottom.MarlinDepth;
if (~isempty(zlow) & ~isempty(zhi));
  set(gca,'ylim',[zlow zhi]);
end;

xhi = str2num(get(plotinfo.lright,'string'))*1e3+bottom.along;
xlow = -str2num(get(plotinfo.lleft,'string'))*1e3+bottom.along;
if (~isempty(xlow) & ~isempty(xhi));
  set(gca,'xlim',[xlow xhi]./1e3);
end;







