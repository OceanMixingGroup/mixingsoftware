function show_nbadcp(h);
% function show_nbadcp(h);
% loads processed narrowband RDI ADCP files starting h hours
% from the last raw data file
% and plots U, V and intensity versus time
% h=1;
if nargin<1
  h=1;
end;
% get files to plot
set_nbadcp;
rdir=dir(rawdir);
lraw=length(rdir);
t2=datenum(rdir(end).date);
t1=t2-datenum(0,0,0,h,30,0);
adcp=makebignbadcp(t1,t2,rawdir,matdir,prefix);
while isempty(adcp)
    disp('Data is not processed... Waiting...');
    for i=1:60
        pause(1);
    end
    adcp=makebignbadcp(t1,t2,rawdir,matdir,prefix);
end
adcp=subtractbt(adcp);    
adcp.int=adcp.inten1;
adcp.depth=adcp.depth(:,1)+5;
adcp.bottom=nanmean(adcp.range);

plotinfo.ulim=[-1 1]*0.5;
plotinfo.ylim=[0 180];
mdir=dir(matdir);
sizelast=mdir(end).bytes;
figure(11)
temp=get(0,'ScreenSize');
% posi=[0 -52 temp(3)/2 temp(4)-7]; 
posi=[temp(3)/2 round(-0.0488*temp(4)) temp(3)/2 temp(4)-5]; 
set(gcf,'position',posi)
set(gcf,'defaultaxesfontsize',8);

clf
colormap(redblue);
[guihands,plotinfo]=adduicontrols_sonar(plotinfo,gcf);
hsub=[];
while 1
    if ~isempty(hsub)
        delete(hsub);
    end;
    hsub(1)=subplot(5,1,2);
    pcolor(adcp.mtime,adcp.depth,adcp.u);shading flat;
    hold on;
    caxis(plotinfo.clim);
    plot(adcp.mtime,adcp.bottom,'k-','linewidth',1.5);
    kdatetick2;
    set(gca,'ylim',plotinfo.ylim);
    axis('ij');
    ylabel('DEPTH [m]');
%     set(gca,'xticklab','');
    hc(1)=colorbar('v');axes(hc(1));title('U [m s^{-1}]','fontsize',8);
    smallbar(hsub(1),hc(1));
    
    hsub(2)=subplot(5,1,3);
    pcolor(adcp.mtime,adcp.depth,adcp.v);shading flat;
    hold on;
    caxis(plotinfo.clim);
    plot(adcp.mtime,adcp.bottom,'k-','linewidth',1.5);
    kdatetick2;
    set(gca,'ylim',plotinfo.ylim);
    axis('ij');
    ylabel('DEPTH [m]');
%     set(gca,'xticklab','');
    hc(2)=colorbar('v');axes(hc(2));
    title('V [m s^{-1}]','fontsize',8);
    smallbar(hsub(2),hc(2));
    
    hsub(3)=subplot(5,1,4);
    pcolor(adcp.mtime,adcp.depth,log10(adcp.int));shading flat;
    kdatetick2;
    hold on;
    plot(adcp.mtime,adcp.bottom,'k-','linewidth',1.5);
    axis('ij');
    set(gca,'ylim',plotinfo.ylim);
    ylabel('DEPTH [m]');
    xlabel('TIME');
    hc(3)=colorbar('v');axes(hc(3));
    title('Echo [dB]','fontsize',8);
    smallbar(hsub(3),hc(3));
    
    hsub(4)=subplot(5,1,5);
    pppos = get(hsub(4),'pos');
    set(hsub(4),'pos',[pppos(1:2) pppos(3)*0.85 pppos(4)]);
    plot_topo('oregon',plotinfo.clev);
    plot(adcp.longitude,adcp.latitude,'k.','markersize',2);
    hold on;
    plot(adcp.longitude(end),adcp.latitude(end),'r.');
    plot(plotinfo.waypt(:,1),plotinfo.waypt(:,2),'go');
    xlabel('LON');
    ylabel('LAT');
    good =find(~isnan(adcp.latitude));
    medlat=median(adcp.latitude(good));
    xlim = get(gca,'xlim');
    
    if ~isempty(medlat)
        set(gca,'dataaspectratio',[1 cos(medlat*pi/180) 1]);
        set(gca,'ylim',medlat+[-1 1]*0.1);
        xlims=get(gca,'xlim');
        set(gca,'xlim',[min(xlims(1),min(plotinfo.waypt(:,1))-0.05),-123.9]);
        xlim=get(gca,'xlim');ylim=get(gca,'ylim');
        % put a line along the top with distances in nautical miles...
        line(xlim,[ylim(1)+0.25*(ylim(2)-ylim(1)),ylim(1)+0.25*(ylim(2)-ylim(1))],'color','k');
        dd = (1/60)/cos(medlat*pi/180);%/1.853 - for km;
        xxx=[xlim(1):5*dd:xlim(2)];
        plot(xxx,(ylim(1)+0.25*(ylim(2)-ylim(1)))*ones(size(xxx)),'kx');
    end;
    
    hsub(5) = subplot(5,1,1);
    plot(adcp.mtime,adcp.heading);
    axis tight;
    smallbar(hsub(5),colorbar);
    ylabel('HEAD [^o]');
    title(sprintf('%s',datestr(max(adcp.mtime))))
    kdatetick2;
    
    % check the gui handles....
    plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
%     plotinfo.clim = [-1 1]*str2num(get(guihands(3),'string'));
    fprintf('Pausing\n');
    for i=1:waittime
        pause(1);
        plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
%         plotinfo.clim = [-1 1]*str2num(get(guihands(3),'string'));
        set(hsub(1:3),'ylim',plotinfo.ylim);
%         set(hsub(1:2),'clim',plotinfo.clim);
    end;
    rdir=dir(rawdir);
    mdir=dir(matdir);
    if length(rdir)>lraw | mdir(end).bytes~=sizelast
        lraw=length(rdir);
        t2=datenum(rdir(end).date);
        adcp=makebignbadcp(t1,t2,rawdir,matdir,prefix);
        while isempty(adcp)
            disp('Data is not processed... Waiting...');
            for i=1:60
                pause(1);
            end
            adcp=makebignbadcp(t1,t2,rawdir,matdir,prefix);
        end
        adcp=subtractbt(adcp);    
        adcp.int=adcp.inten1;
        adcp.depth=adcp.depth(:,1)+5;
        adcp.bottom=nanmean(adcp.range);
    end
    sizelast=mdir(end).bytes;
end; % end infinite loop
close all;
