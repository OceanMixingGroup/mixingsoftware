%load //ladoga/data/cruises/tx01/adcp150/mat/t150010.mat
load //ladoga/data/cruises/tx01/adcp300/mat/t300017.mat

adcp=rotateby(adcp,-2.49);
adcp = subtractbt(adcp);
adcp=removebottom(adcp,0.85);

load //ladoga/datad/cruises/tx01/chameleon/summaries/transect12
load starttimes271
% starttimes=starttimes20;

pname = (['\\Ladoga\datad\cruises\tx01\biosonics\mat\']);
transducerdepth = 5; % m
horizontalsubsample=100;
verticalsubsample=10;

mooring = -(124);

plotinfo.clim = [-1 1]*0.5;
plotinfo.biolim = [0.4 3.6];
plotinfo.depthlim = [0 50];
plotinfo.xlim = [-30 -3];
plotinfo.slim=[30.5 33.6];
plotinfo.sigmalim=[1022 1024];
plotinfo.tlim=[4 16];
plotinfo.epslim=[-10 -4];
plotinfo.sigcontmaj = [1022:2:1027]-1000;
plotinfo.sigcont = setdiff([1022:0.5:1027]-1000,plotinfo.sigcontmaj)

starttime=starttimes(1:2:end);
stoptime = starttimes(2:2:end);

sum.depths = sum.depths';
inup = find(sum.direction=='u');
sum.depths=repmat(sum.depths(:,1),1,size(sum.EPS1,2));
sum.depths(:,inup) = sum.depths(:,inup)+2;


for i=1:length(starttime);
  figure(i);
  clf
  agutwocolumn(1);wysiwyg;
  colormap(redblue);
  yday = datenum2yday(adcp.time);
  in = find(yday>=starttime(i) & yday<=stoptime(i))
  sum.yday=datenum2yday(sum.time);

  incham = find(sum.yday>=starttime(i) & sum.yday<=stoptime(i));
  sum.yday=repmat(sum.yday(1,:),size(sum.EPS1,1),1);
  
  plotinfo.xlim=[starttime(i) stoptime(i)];
  
  ax(1)=subplot(5,1,1);
  
  surface(datenum2yday(adcp.time(in)),adcp.depth(:,1),adcp.u(:,in)-1e6);
  shading flat;
  axis('ij');  
  caxis(plotinfo.clim-1e6);
  hold on;
  [c,h]=contour(sum.yday(:,incham),sum.depths(:,incham),sum.SIGMA(:,incham),...
		plotinfo.sigcont);
  set(h,'edgecolor','k');
  [c,h]=contour(sum.yday(:,incham),sum.depths(:,incham),sum.SIGMA(:,incham),...
		plotinfo.sigcontmaj);
  set(h,'edgecolor','k','linewidth',1.5);
  set(gca,'ylim',plotinfo.depthlim,'xlim',plotinfo.xlim);
  ylabel('DEPTH [m]');
  if median(diff(adcp.lon(in)))<0
    title(sprintf('Going west %s    %s',datestr(min(adcp.time(in))), ...
		  datestr(max(adcp.time(in))))); 
  else
      title(sprintf('Going east %s   %s',datestr(min(adcp.time(in))), ...
		  datestr(max(adcp.time(in)),13))); 
  end;
  
  hcb(1)=colorbar1(plotinfo.clim);
  
  smallbar(ax(1),hcb(1))
  
  
  ax(2)=subplot(5,1,2);
  surface(datenum2yday(adcp.time(in)),adcp.depth(:,1),adcp.v(:,in)-1e6);
  hold on;
  plot(datenum2yday(adcp.time(in)),nanmean(adcp.range(:,in)));
  shading flat;
  axis('ij');
  caxis(plotinfo.clim-1e6);
  hold on;
  [c,h]=contour(sum.yday(:,incham),sum.depths(:,incham),sum.SIGMA(:,incham),...
		plotinfo.sigcont);
  set(h,'edgecolor','k');
  [c,h]=contour(sum.yday(:,incham),sum.depths(:,incham),sum.SIGMA(:,incham),...
		plotinfo.sigcontmaj);
  set(h,'edgecolor','k','linewidth',1.5);

  set(gca,'ylim',plotinfo.depthlim,'xlim',plotinfo.xlim);
  tmin=min(adcp.time(in));tmax=max(adcp.time(in));

  box on;
  hcb(2)=colorbar1(plotinfo.clim);
  smallbar(ax(2),hcb(2))
  
  ax(3)=subplot(5,1,3);
if 1
  % OK this is too much.  
  start = min(adcp.time(in))
  stop = max(adcp.time(in))
  
  plot_bio_decimated(pname,start,stop,1);
  set(gca,'xlim',plotinfo.xlim,'ylim',plotinfo.depthlim);
 
%  datetick;
%keyboard;
  [c,h]=contour(sum.yday(:,incham),sum.depths(:,incham),sum.SIGMA(:,incham),...
		plotinfo.sigcontmaj);
  set(h,'edgecolor','k','linewidth',1.5);

  caxis(plotinfo.biolim);
  inold=in;
  hcb(3)=colorbar1(plotinfo.biolim);
  smallbar(ax(3),hcb(3))

end;



  ax(4)=subplot(5,1,4)
  down = find(sum.direction(incham)=='d');
  inchamdown=incham(down);
  facetsurface(sum.yday(:,inchamdown),sum.depths(:,inchamdown),...
	       log10(sum.EPS1(:,inchamdown))-1e6);
  shading flat;
  hold on;
  [c,h]=contour(sum.yday(:,incham),sum.depths(:,incham),sum.SIGMA(:,incham),...
		plotinfo.sigcont);
  set(h,'edgecolor','k');
  [c,h]=contour(sum.yday(:,incham),sum.depths(:,incham),sum.SIGMA(:,incham),...
		plotinfo.sigcontmaj);
  set(h,'edgecolor','k','linewidth',1.5);
  axis('ij');  
  set(gca,'ylim',plotinfo.depthlim,'xlim',plotinfo.xlim);
  set(gca,'xtickla','');
  caxis(plotinfo.epslim-1e6)
  hcb(4)=colorbar1(plotinfo.epslim);
  smallbar(ax(4),hcb(4))

  
  ax(5)=subplot(5,1,5)
  facetsurface(sum.yday(:,incham),sum.depths(:,incham),sum.THETA(:,incham)-1e6);
  shading flat;
  hold on;
  [c,h]=contour(sum.yday(:,incham),sum.depths(:,incham),sum.SIGMA(:,incham),...
		plotinfo.sigcont);
  for ii=1:5:length(incham)
    text(sum.yday(1,incham(ii)),0, ...
	 int2str(sum.castnumber(incham(ii))),'fontsize',6,'rotation',60);
    
  end;
  
  set(h,'edgecolor','k');
  [c,h]=contour(sum.yday(:,incham),sum.depths(:,incham),sum.SIGMA(:,incham),...
		plotinfo.sigcontmaj);
  set(h,'edgecolor','k','linewidth',1.5);
  axis('ij');  
  set(gca,'ylim',plotinfo.depthlim,'xlim',plotinfo.xlim);
  caxis(plotinfo.tlim-1e6)
  if ~isempty(h)
    clabel(c,h,'fontsize',7,'labelspacing',140);
  end;
  xlabel('yearday');
  
  hcb(5)=colorbar1(plotinfo.tlim);
  smallbar(ax(5),hcb(5))

  
  axes(hcb(1)); ylabel('U [ms^{-1}]');
  axes(hcb(2)); ylabel('V [ms^{-1}]');
  axes(hcb(3)); ylabel('BIOSONICS');
  axes(hcb(4)); ylabel('log10(\epsilon) [m^2 s^{-3}]');
  axes(hcb(5)); ylabel('\Theta [^o]');


  
  
  set(ax,'color',[1 1 1]*0.7);
  
  if 1
    print('-djpeg95','-r250',sprintf('chamsections%8.4f.jpg', ...
				     datenum2yday(min(yday(inold)))));
  else
    ppause
  end;
  
% ppause

end;
