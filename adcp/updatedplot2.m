function updatedplot2(savefile,waittime);
%
% function updatedplot2(savefile,timetowait);
%
% keep loading savefile every timetowait seconds and plot it up...
% updatedplot2('\\flash\data\jklymak\ct01a\data\adcp\matfiles\T127002',180);
%

plotinfo.ylim = [0 150]; % m
plotinfo.xlim =0.3;  % days
plotinfo.clim =[-1 1]*0.8; % m/s....
figure(1)
set(gcf,'units','pixels');
set(gcf,'pos',[446 5 572 721]);
set(gcf,'defaultaxesfontsize',8);
plotinfo.waypt = [-124-8.8/60  44+13.5/60;
                -125         44+13.5/60];

clf
colormap(redblue);
[guihands,plotinfo]=adduicontrols(plotinfo,gcf);

while ~exist(savefile)
  fprintf('Cannot find %s;   Pausing\n',savefile)
  for i=1:30
    pause(1)
  end;
end;
hsub=[];
while 1
  try
    load(savefile);
    if length(adcp.time)>3
      
      % subtract bottom tracking....
      adcp=subtractbt(adcp);
      
      if ~isempty(hsub)
        delete(hsub);
      end;
      
      xlim =  max(datenum2yday(adcp.time))+[-plotinfo.xlim 0];
      good =find(adcp.number>0);
      xlim(1) = max([xlim(1) min(datenum2yday(adcp.time(good)))]);
      
      hsub(1)=subplot(4,1,1);
      imagesc(datenum2yday(adcp.time),adcp.depth(:,1),adcp.u);
      hold on;
      plot(datenum2yday(adcp.time),mean(adcp.range,1),'k','linewidth',1.5);
      plot(datenum2yday(adcp.time),0.85*mean(adcp.range,1),'k','linewidth',0.75);
      caxis(plotinfo.clim);
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      hold on;
      %  plot(datenum2yday(adcp.time),adcp.range,'k');
      axis('ij');
      ylabel('DEPTH [m]');
      set(gca,'xticklab','');
      ht=title(sprintf('%s; %s',...
        savefile,datestr(max(adcp.time))),...
        'fontname','times','fontsize',9,'interpret','none');
      pp = get(ht,'pos');
      set(ht,'pos',[pp(1) pp(2)+0.07]);  
      hc(1)=colorbar('v');axes(hc(1));title('U [m s^{-1}]','fontsize',8);
      smallbar(hsub(1),hc(1));
      
      hsub(2)=subplot(4,1,2);
      imagesc(datenum2yday(adcp.time),adcp.depth(:,1),adcp.v);
      hold on;
      plot(datenum2yday(adcp.time),mean(adcp.range,1),'k','linewidth',1.5);
      plot(datenum2yday(adcp.time),0.85*mean(adcp.range,1),'k','linewidth',0.75);
      
      caxis(plotinfo.clim);
      set(gca,'ylim',plotinfo.ylim);
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      hold on;
      % plot(datenum2yday(adcp.time),adcp.range,'k');
      axis('ij');
      ylabel('DEPTH [m]');
      set(gca,'xticklab','');
      hc(2)=colorbar('v');axes(hc(2));
      title('V [m s^{-1}]','fontsize',8);
      smallbar(hsub(2),hc(2));
      
      hsub(3)=subplot(4,1,3);
      imagesc(datenum2yday(adcp.time),adcp.depth(:,1),adcp.inten1);
      hold on;
      plot(datenum2yday(adcp.time),mean(adcp.range,1),'k','linewidth',1.5);
      plot(datenum2yday(adcp.time),0.85*mean(adcp.range,1),'k','linewidth',0.75);
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      set(gca,'ylim',plotinfo.ylim);
      hold on;
      % plot(datenum2yday(adcp.time),adcp.range,'k');
      ylabel('DEPTH [m]');
      %  set(gca,'xticklab','');
      xlabel('TIME [yday]');
      hc(3)=colorbar('v');axes(hc(3));
      title('Echo [dB]','fontsize',8);
      smallbar(hsub(3),hc(3));
      
      hsub(4)=subplot(4,1,4);
      pppos = get(hsub(4),'pos');
      set(hsub(4),'pos',[pppos(1:2) pppos(3)*0.85 pppos(4)]);
      plot_topo('../../topo/oregon',[-2000:500:-500 -200:20:0]);
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
      plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
      plotinfo.clim = [-1 1]*str2num(get(guihands(5),'string'));
      plotinfo.xlim = str2num(get(guihands(3),'string'));
      fprintf('Pausing\n');
      for i=1:waittime
        pause(1);
        plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
        plotinfo.clim = [-1 1]*str2num(get(guihands(5),'string'));
        plotinfo.xlim = str2num(get(guihands(3),'string'));
        xlim =  max(datenum2yday(adcp.time))+[-plotinfo.xlim 0];
        good =find(adcp.number>0 & ~isnan(adcp.time));
        xlim(1) = max([xlim(1) min(datenum2yday(adcp.time(good)))]);
        set(hsub(1:3),'xlim',xlim,'ylim',plotinfo.ylim);
      end;
    end; % if adcp data is long enough...
   catch
     fprintf('Had trouble: %s\n',lasterr);
     close all;
     return;
   end; % catch
end; % end infinite loop

function adcp=subtractbt(adcp);

adcp.u = adcp.u-ones(size(adcp.u,1),1)*adcp.ubt;
adcp.v = adcp.v-ones(size(adcp.u,1),1)*adcp.vbt;
%adcp. = adcp.u-ones(size(adcp.u,1),1)*adcp.ubt;
% also do the depth...


function [guihands,plotinfo]=adduicontrols(plotinfo,h0);
  
  x0 = 0.88;
  y0 = 0.1;
  dx = 0.07;
  dy = 0.025;
  backcol = [1 1 1];
  forecol=[0 0 0];
  
  
  guihands(1) =  uicontrol('Parent',h0,...
			   'Units','normal', ...
			   'BackgroundColor',backcol, ...
			   'ListboxTop',0, ...
			   'fontsize',10,...		   
			   'Position',[x0 y0 dx dy], ...
			   'Style','edit',...
			   'String',num2str(plotinfo.ylim(2)),...
			   'foregroundcol',forecol);
  guihands(2) =  uicontrol('Parent',h0,...
			   'Units','normal', ...
			   'BackgroundColor',backcol, ...
			   'ListboxTop',0, ...
			   'fontsize',10,...		   
			   'Position',[x0-dx y0 dx dy], ...
			   'Style','text',...
			   'String','Max Z',...
			   'foregroundcol',forecol);
  guihands(3) =  uicontrol('Parent',h0,...
			   'Units','normal', ...
			   'BackgroundColor',backcol, ...
			   'ListboxTop',0, ...
			   'fontsize',10,...		   
			   'Position',[x0 y0+1.5*dy dx dy], ...
			   'Style','edit',...
			   'String',num2str(plotinfo.xlim(1)),...
			   'foregroundcol',forecol);
  guihands(4) =  uicontrol('Parent',h0,...
			   'Units','normal', ...
			   'BackgroundColor',backcol, ...
			   'ListboxTop',0, ...
			   'fontsize',10,...		   
			   'Position',[x0-dx y0+1.5*dy dx dy], ...
			   'Style','text',...
			   'String','days before now:',...
			   'foregroundcol',forecol);
  guihands(5) =  uicontrol('Parent',h0,...
			   'Units','normal', ...
			   'BackgroundColor',backcol, ...
			   'ListboxTop',0, ...
			   'fontsize',10,...		   
			   'Position',[x0 y0+3*dy dx dy], ...
			   'Style','edit',...
			   'String',num2str(plotinfo.clim(2)),...
			   'foregroundcol',forecol);
  guihands(6) =  uicontrol('Parent',h0,...
			   'Units','normal', ...
			   'BackgroundColor',backcol, ...
			   'ListboxTop',0, ...
			   'fontsize',10,...		   
			   'Position',[x0-dx y0+3*dy dx dy], ...
			   'Style','text',...
			   'String','Max |U|',...
			   'foregroundcol',forecol);


