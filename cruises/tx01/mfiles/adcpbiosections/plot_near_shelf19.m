%load //ladoga/data/cruises/tx01/adcp150/mat/t150010.mat
%adcp=concatadcp(adcp1,adcp);
load //ladoga/data/cruises/tx01/adcp300/mat/t300015.mat
adcp=rotateby(adcp,-2.49);
adcp = subtractbt(adcp);
adcp=removebottom(adcp,0.85);

load starttimes269
% starttimes=starttimes20;

pname = (['\\Ladoga\datad\cruises\tx01\biosonics\mat\']);
transducerdepth = 5; % m
horizontalsubsample=10;
verticalsubsample=10;

mooring = -(124);

plotinfo.clim = [-1 1]*0.5;
plotinfo.depthlim = [0 100];
plotinfo.xlim = [-18 0];
plotinfo.slim=[30.5 33.6];
plotinfo.sigmalim=[1022 1024];
plotinfo.tlim=[8.8 15.5];

for i=1:length(starttimes)-1;
  figure(i);
  clf
  agutwocolumn(1);wysiwyg;
  colormap(redblue);
  yday = datenum2yday(adcp.time);
  in = find(yday>=starttimes(i) & yday<=starttimes(i+1))

  
  subplot(4,1,1);
  
  surface((adcp.lon(in)-mooring)*60,adcp.depth(:,1),adcp.u(:,in));
  shading flat;
  axis('ij');
  caxis(plotinfo.clim);
  set(gca,'ylim',plotinfo.depthlim,'xlim',plotinfo.xlim);
  ylabel('DEPTH [m]');
  if median(diff(adcp.lon(in)))<0
    title(sprintf('Going west %s    %s',datestr(min(adcp.time(in))), ...
		  datestr(max(adcp.time(in))))); 
  else
      title(sprintf('Going east %s   %s',datestr(min(adcp.time(in))), ...
		  datestr(max(adcp.time(in)),13))); 
  end;
  
  
  
  subplot(4,1,2);
  surface((adcp.lon(in)-mooring)*60,adcp.depth(:,1),adcp.v(:,in));
  hold on;
  plot((adcp.lon(in)-mooring)*60,nanmean(adcp.range(:,in)));
  shading flat;
  axis('ij');
  caxis(plotinfo.clim);
  set(gca,'ylim',plotinfo.depthlim,'xlim',plotinfo.xlim);
  tmin=min(adcp.time(in));tmax=max(adcp.time(in));
  xlabel('MINUTES EAST OF 124');
  box on;
if 1
  subplot(4,1,3);
  % OK this is too much.  
  inn = find(adcp.lon(in)>(plotinfo.xlim(1)/60+mooring) & ...
	     adcp.lon(in)<=(plotinfo.xlim(2)/60 + mooring));
  start = min(adcp.time(in(inn)))
  stop = max(adcp.time(in(inn)))
  
  plot_bio_distance(pname,start,stop);
  set(gca,'xlim',plotinfo.xlim/60+mooring,'ylim',plotinfo.depthlim);
  xlabel('LONGITUDE [^o]');
  
  inold=in;
end;

  ax(1)=subplot(4,1,4)
  load das

  das.ft_sigmat = sw_pden(das.ft_sal,das.ft_temp,3,0);

  in = find(datenum2yday(das.datenum)>=starttimes(i) & datenum2yday(das.datenum)<=starttimes(i+1));  
%  plot(das.lon,das.ft_temp,'.','color',[1 1 1]*0.6);
  hold on;
  
  pos=get(gca,'pos');
  ax(2)=axes('posit',pos)
%  plot(das.lon,das.ft_sal,'.','color',[1 1 1]*0.7);
  hold on;
  plot(das.lon(in),das.ft_sal(in),'.','color',[0 1  0]);
  set(ax(2),'xlim',plotinfo.xlim/60 + mooring,'ylim',plotinfo.slim);
  set(ax(2),'yaxisloc','right');
  set(ax(2),'ycolor',[0 1 0]);

  pos=get(gca,'pos');
  ax(3)=axes('posit',pos)
%  plot(das.lon,das.ft_sigmat,'.','color',[1 1 1]*0.3);
  hold on;
  plot(das.lon(in),das.ft_sigmat(in),'.','color',[0 0 1]);
  set(ax(3),'xlim',plotinfo.xlim/60 + mooring,'ylim',plotinfo.sigmalim);
  set(ax(3),'yaxisloc','right');
  set(ax(3),'ycolor',[0 0 1]);


  
  axes(ax(1));
  plot(das.lon(in),das.ft_temp(in),'.','color',[1 0 0]);
  set(ax(1),'xlim',plotinfo.xlim/60 + mooring,'ylim',plotinfo.tlim);
  set(ax(1),'ycolor',[1 0 0]);
  
  if 1
    print('-djpeg95','-r250',sprintf('adcpbio%8.4f.jpg', ...
				     datenum2yday(min(yday(inold)))));
  else
    ppause
  end;
  
% ppause

end;
