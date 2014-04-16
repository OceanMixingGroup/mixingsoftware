function updatedplot2(savefile,timetowait,plotinfo);
%
% function updatedplot2(savefile,timetowait);
%
% keep loading savefile every timetowait seconds and plot it up...

waittime=timetowait;

figure(11);
nfailed=0;
while ~exist(savefile)
  fprintf('Cannot find %s;   Pausing\n',savefile)
  for i=1:30
    pause(1)
  end;
end;
hsub=[];
numplots=30;
while 1
  lockname = [savefile '.lock']
  lockedby = 'show_adcp.m';
  while exist(lockname)
    fprintf('%s  locked - pausing\n',savefile);
    pause(5);
  end;
  save(lockname,'lockedby');
  pause(1);
  load(savefile);
  pause(1);
  delete(lockname);
    
  if length(adcp.time)>3
    numplots = numplots+1;
    if numplots>20;
      delete(hsub);
      hsub=[];
      close(11);
      numplots=1;
      figure(11)
      temp=get(0,'ScreenSize');
      % posi=[0 -52 temp(3)/2 temp(4)-7]; 
      posi=[temp(3)/2 round(-0.0488*temp(4)) temp(3)/2 temp(4)-5]; 
      set(gcf,'position',posi)
      
          % figure(11)
          % set(gcf,'units','pixels');
          % set(gcf,'pos',[446 5 572 721]);
          set(gcf,'defaultaxesfontsize',8);
          
          clf
          colormap(redblue);
          [guihands,plotinfo]=adduicontrols(plotinfo,gcf);
      end
      
      % subtract bottom tracking....
      adcp=subtractbt(adcp);
      
      if ~isempty(hsub)
        delete(hsub);
      end;
      
      xlim =  max((1)*(adcp.time))+[-plotinfo.xlim 0];
      good =find(adcp.number>0);
      xlim(1) = max([xlim(1) min((1)*(adcp.time(good)))]);
      
      intime = find(adcp.time>=xlim(1) & adcp.time<xlim(2));
      
      hsub(1)=subplot(4,1,1);
      imagesc((1)*(adcp.time(intime)),adcp.depth(:,1),adcp.u(:,intime));
      hold on;
      plot((1)*(adcp.time(intime)),mean(adcp.range(:,intime),1),'k','linewidth',1.5);
      plot((1)*(adcp.time(intime)),0.85*mean(adcp.range(:,intime),1),'k','linewidth',0.75);
      caxis(plotinfo.clim);
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      hold on;
      %  plot((1)*(adcp.time),adcp.range,'k');
      axis('ij');
      ylabel('DEPTH [m]');
         datetick
         set(gca,'xticklab','');
      ht=title(sprintf('%s; %s',...
        savefile,datestr(max(adcp.time))),...
        'fontname','times','fontsize',9,'interpret','none');
      pp = get(ht,'pos');
      set(ht,'pos',[pp(1) pp(2)+0.07]);  
      hc(1)=colorbar('v');axes(hc(1));title('U [m s^{-1}]','fontsize',8);
      smallbar(hsub(1),hc(1));
      
      hsub(2)=subplot(4,1,2);
      imagesc((1)*(adcp.time(intime)),adcp.depth(:,1),adcp.v(:,intime));
      hold on;
      datetick
      plot((1)*(adcp.time(intime)),mean(adcp.range(:,intime),1),'k','linewidth',1.5);
      plot((1)*(adcp.time(intime)),0.85*mean(adcp.range(:,intime),1),'k','linewidth',0.75);
      
      caxis(plotinfo.clim);
      set(gca,'ylim',plotinfo.ylim);
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      hold on;
      % plot((1)*(adcp.time),adcp.range,'k');
      axis('ij');
      ylabel('DEPTH [m]');
      datetick
      set(gca,'xticklab','');
      hc(2)=colorbar('v');axes(hc(2));
      title('V [m s^{-1}]','fontsize',8);
      smallbar(hsub(2),hc(2));
      
      hsub(3)=subplot(4,1,3);
      imagesc((1)*(adcp.time(intime)),adcp.depth(:,1),adcp.inten1(:,intime));
      hold on;
      plot((1)*(adcp.time(intime)),mean(adcp.range(:,intime),1),'k','linewidth',1.5);
      plot((1)*(adcp.time(intime)),0.85*mean(adcp.range(:,intime),1),'k','linewidth',0.75);
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      set(gca,'ylim',plotinfo.ylim);
      hold on;
      % plot((1)*(adcp.time),adcp.range,'k');
      ylabel('DEPTH [m]');
      %  set(gca,'xticklab','');
      xlabel('TIME [yday]');
      datetick
      hc(3)=colorbar('v');axes(hc(3));
      title('Echo [dB]','fontsize',8);
      smallbar(hsub(3),hc(3));
      
      hsub(4)=subplot(4,1,4);
      pppos = get(hsub(4),'pos');
      set(hsub(4),'pos',[pppos(1:2) pppos(3)*0.85 pppos(4)]);
     % plot_topo('oregon',plotinfo.clev);
      plot(adcp.lon,adcp.lat,'k.','markersiz',2);
      hold on;
      plot(adcp.lon(end),adcp.lat(end),'r.');
      plot(plotinfo.waypt(:,1),plotinfo.waypt(:,2),'go');
      
      xlabel('LON');
      ylabel('LAT');
      good =find(~isnan(adcp.lat));
      medlat=median(adcp.lat(good));
      xlim = get(gca,'xlim');
%      set(gca,'xlim',[plotinfo.waypt(2) xlim(2)]);
      
      if ~isempty(medlat)
        set(gca,'dataaspectratio',[1 cos(medlat*pi/180) 1]);
        set(gca,'ylim',medlat+[-1 1]*0.1);
        xlim=get(gca,'xlim');
        % put a line along the top with distances in nautical miles....
        line(xlim,medlat+0.095,'color','k');
        dd = (1/60)*cos(medlat*pi/180);
        plot([xlim(1):5*dd:xlim(2)],medlat+0.095,'kx');
      end;
      
      
      % check the gui handles....
      if 1;
        plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
	plotinfo.clim = [-1 1]*str2num(get(guihands(5),'string'));
	plotinfo.xlim = str2num(get(guihands(3),'string'));
      end;
      fprintf('Pausing\n');
      for i=1:waittime
        pause(1);
        if 1
	  plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
	  plotinfo.clim = [-1 1]*str2num(get(guihands(5),'string'));
	  plotinfo.xlim = str2num(get(guihands(3),'string'));
	end;
	xlim =  max((1)*(adcp.time))+[-plotinfo.xlim 0];
        good =find(adcp.number>0 & ~isnan(adcp.time));
        xlim(1) = max([xlim(1) min((1)*(adcp.time(good)))]);
        set(hsub(1:3),'xlim',xlim,'ylim',plotinfo.ylim);
      end;
    end; % if adcp data is long enough...
    nfailed=0;
end; % end infinite loop
