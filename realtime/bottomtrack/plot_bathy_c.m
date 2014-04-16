function plot_bathy(fname,vminor,vmajor,tracks);
% function plot_bathy(fname,vminor,vmajor);
  
  if nargin<1
    fname='';
  end;
  if nargin<2
    vminor=[];
  end;
  if nargin<3
    vmajor=[];
  end;
  if nargin<4
    tracks=1;
  end;
  
  if isempty(fname)
    [fname,pathname]=uigetfile('*.mat','Pick Bathymetry To Plot');
    fname = strcat(pathname,fname)
  end;

  % generic plotting for fname...
    load(fname);
    if exist('bathy','var')
      lat = bathy.lat;
      lon = bathy.lon;
      depths=bathy.depth;
    end;
    
    cax = [-8000 8000];  
    mainax=gca;
    
    set(gca,'ydir','nor');
set(gca,'dataaspectratio',[1 cos(median(lat(:))*pi/180) 4000])
if isempty(vminor)
  vminor=[-1000:50:00];
end;
if isempty(vmajor)
  vmajor=[-10000:1000:0];
end;
vminor=setdiff(vminor,vmajor);

% do the colormap demcmap is dumb....
% get the proportion for each map....
%cmaplen=abs(diff(cax))/20;
% note that cmaplen is defined so that 0 will fall on an the
% boundary between two colurs (or it should)
%cmp=reliefsea(ceil(cmaplen*abs(min(cax))./(max(cax)-min(cax))));
%cmp2=reliefland(cmaplen-length(cmp(:,1)));
%cmp=[cmp;     
%     cmp2];
%cmp;
%demcmap([-12000 max(depth(:))],128,sea(64),land(64))
%caxis(cax);
%colormap(cmp);
%brighten2(0.1);
%hold on;
%hsurf=surface(lon,lat,depths);shading interp
%set(hsurf,'ambientstrength',1,'diffusestren',0.2, ...
%	  'facelighting','gouraud','specularstren',0.25)
%light('position',[-164 10 12000],'color',[1 1 1],'style','local')
%light('position',[-164 10 12000],'color',[1 1 1],'style','local')

axis([min(lon(:)) max(lon(:)) min(lat(:)) max(lat(:))]);
hold on;
if ~isempty(vminor)
  [c,h2]=contour(lon,lat,depths+1e6,vminor+1e6);
  set(h2,'edgecolor',[1 1 1]*0.4,'linewidth',0.5);
end;
[c,h2]=contour(lon,lat,depths+1e6,vmajor+1e6);
set(h2,'edgecolor',[1 1 1]*0.4,'linewidth',1.5);
[c,hh]=contour(lon,lat,depths+1e6,[0 0]+1e6);
set(hh,'edgecolor',[1 1 1]*0.4,'linewidth',1.5);

grid on
box on
%return
%set(gca,'xcolor','m','ycolor','m','zcolor','m');

xlabel('LONGITUDE','fontangle','oblique');
ylabel('LATITUDE','fontangle','oblique');
% nudge current figure up a bit...
%pos = get(gca,'pos');
%set(gca,'pos',[pos(1) pos(2) pos(3)-0.1 pos(4)]); 



axes(mainax);

return

hcbar=axes('pos',[0.85 0.3 0.025 0.4]);
colorbar1(hcbar,cax);
set(hcbar,'fontsize',8,...
	  'ylim',[-6000 5000],...
	  'yticklabelmode','auto','yaxisloc','right');
delete(findobj(get(hcbar,'child'),'Type','text'));
Y = cax(1):abs(diff(cax))/100:cax(2);
D = Y'*ones(1,2);
axes(hcbar);
hold on;


% lets add some tracks
if tracks
  load gregg
  plot(track.lon,track.lat,'.','color',[0.8 0 0.8],'linewidth',0.25,...
       'markersize',1);
  load revelle
  plot(track.lon,track.lat,'.','color',[0.7 0 0.1],'linewidth',0.25,...
       'markersize',1);
  load levinesouth
  plot(track.lon,track.lat,'.','color',[0.1 0 0.7],'linewidth',0.25,...
       'markersize',1);
  load levinenorth
  plot(track.lon,track.lat,'.','color',[0.1 0 0.7],'linewidth',0.25,...
       'markersize',1);
  load sanford
  plot(track.lon,track.lat,'.','color',[1 0 0.0],'linewidth',0.25,...
       'markersize',1);
  % add the mooring locations
  if 1
    pos=[-158-32.502/60 21+36.66/60;
	 -158-27.836/60 21+47.999/60]
    plot(pos(:,1),pos(:,2),'x','markersize',5,'linewidth',2);
  end;
  % sanford and gregg's stations
  load greggstations
  plot(station.lon,station.lat,'o','markersize',5,'linewidth',2);
  load sanfordstations
  plot(station.lon,station.lat,'d','markersize',5,'linewidth',2);
end;







