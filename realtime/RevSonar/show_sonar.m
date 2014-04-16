function show_sonar(h);
% function show_sonar(h);
% loads trimmed & averaged sonar files starting h hours
% from the last raw data file
% and plots U, V and intensity versus time
% h=1;
if nargin<1
  h=0;
end;

set_sonar;
% get files to plot
dirdata=dir(rawpath);
timediff=datenum(dirdata(end-1).date)-datenum(dirdata(end-2).date);
lastfiletime=datenum(dirdata(end).date);
startfilename=dirdata(end-round(h/(timediff*24))-1).name;
while ~exist([trimpath startfilename])
    disp('Data is not processed... Pausing...');
    pause(60)
end
load('-mat',[trimpath startfilename]);
sonar=trimsonar;
% ship = sonar.shipSOG;
ship = sonar.shipPCODE;
bad = find(sonar.shipPCODE>1);
ship(bad) = sonar.shipSOG(bad);
fsonar.u = sonar.u+repmat(ship,size(sonar.u,1),1);
b = ones(20,1)/20;a=1;
fsonar.u = gappy_filter(b,a,real(fsonar.u)',10)'+sqrt(-1)*gappy_filter(b,a,imag(fsonar.u)',10)';
fsonar.u(1:6)=NaN+sqrt(-1)*NaN;
trimdata=dir(trimpath);
ltr=length(trimdata);
while any(trimdata(ltr).name-startfilename)
    ltr=ltr-1;
end
if ltr~=length(trimdata);
    for j=ltr+1:length(trimdata);
        load('-mat',[trimpath trimdata(j).name]);
        sonar=mergefields(sonar,trimsonar,length(trimsonar.x),2);
%         ship = sonar.shipSOG;
        ship = sonar.shipPCODE;
        bad = find(sonar.shipPCODE>1);
        ship(bad) = sonar.shipSOG(bad);
        fsonar.u = sonar.u+repmat(ship,size(sonar.u,1),1);
        b = ones(20,1)/20;a=1;
        fsonar.u = gappy_filter(b,a,real(fsonar.u)',10)'+sqrt(-1)*gappy_filter(b,a,imag(fsonar.u)',10)';
    end
end
sonar.ranges=sonar.ranges-sonar.ranges(1)+5;
ind=find(sonar.ranges<15);
fsonar.u(ind,:)=NaN+sqrt(-1)*NaN;
ltr=length(trimdata);
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
    xlim=[min(sonar.time) max(sonar.time)];
    hsub(1)=subplot(4,1,1);
    pcolor(sonar.time,sonar.ranges,real(fsonar.u));shading interp;
    kdatetick2;
    hold on;
    caxis(plotinfo.clim);
    set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
    axis('ij');
    ylabel('DEPTH [m]');
%     set(gca,'xticklab','');
    hc(1)=colorbar('v');axes(hc(1));title('U [m s^{-1}]','fontsize',8);
    smallbar(hsub(1),hc(1));
    
    hsub(2)=subplot(4,1,2);
    pcolor(sonar.time,sonar.ranges,imag(fsonar.u));shading interp;
    hold on;
    caxis(plotinfo.clim);
    kdatetick2;
    set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
    axis('ij');
    ylabel('DEPTH [m]');
%     set(gca,'xticklab','');
    hc(2)=colorbar('v');axes(hc(2));
    title('V [m s^{-1}]','fontsize',8);
    smallbar(hsub(2),hc(2));
    
    hsub(3)=subplot(4,1,3);
    pcolor(sonar.time,sonar.ranges,log10(sonar.int));shading interp;
    kdatetick2;
    hold on;
    axis('ij');
    set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
    ylabel('DEPTH [m]');
    xlabel('TIME');
    hc(3)=colorbar('v');axes(hc(3));
    title('Echo [dB]','fontsize',8);
    smallbar(hsub(3),hc(3));
    
    hsub(4)=subplot(4,1,4);
    pppos = get(hsub(4),'pos');
    set(hsub(4),'pos',[pppos(1:2) pppos(3)*0.85 pppos(4)]);
    plot_topo('oregon',plotinfo.clev);
    plot(sonar.pcode_lon,sonar.pcode_lat,'k.','markersize',2);
    hold on;
    plot(sonar.pcode_lon(end),sonar.pcode_lat(end),'r.');
    plot(plotinfo.waypt(:,1),plotinfo.waypt(:,2),'go');
    xlabel('LON');
    ylabel('LAT');
    good =find(~isnan(sonar.pcode_lat));
    medlat=median(sonar.pcode_lat(good));
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
    trimdata=dir(trimpath);
    if length(trimdata)>ltr
        for j=ltr+1:length(trimdata);
            load('-mat',[trimpath trimdata(j).name]);
            sonar=mergefields(sonar,trimsonar,length(trimsonar.x),2);
%             ship = sonar.shipSOG;
            ship = sonar.shipPCODE;
            bad = find(sonar.shipPCODE>1);
            ship(bad) = sonar.shipSOG(bad);
            fsonar.u = sonar.u+repmat(ship,size(sonar.u,1),1);
            b = ones(20,1)/20;a=1;
            fsonar.u = gappy_filter(b,a,real(fsonar.u)',10)'+sqrt(-1)*gappy_filter(b,a,imag(fsonar.u)',10)';
        end
        ltr=length(trimdata);
        sonar.ranges=sonar.ranges-sonar.ranges(1)+5;
        ind=find(sonar.ranges<15);
        fsonar.u(ind,:)=NaN+sqrt(-1)*NaN;
    end    
    
end; % end infinite loop
close all;
