% function show_workhorse;
% keep loading savefile every timetowait seconds and plot it up...

prefix=input('Enter ADCP type (''wh300'' or ''os75'') --> ');
set_workhorse;
trannum=input('Enter daynam --> ');
transfiles=dir(sprintf('%s/%s_%03d*.mat',savedir,prefix,trannum));
if strcmpi(prefix,'wh300')
    cutoff=0.92;
else
    cutoff=0.85;
end
f=figure(11);
set(f,'name',[' Workhorse ' ADCP_type '. Day #' num2str(trannum)]);
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
[guihands,plotinfo]=adduicontrols_wh(plotinfo,gcf);
warning off
fig.stop=uicontrol('units','normalized',...
         'position',[.45 .97 .1 0.025],'string','Stop',...
         'fontunits','normalized','fontsize',.6,...
         'callback','kill_script=1');

while isempty(transfiles)
  fprintf('Cannot find %s;   Pausing\n',sprintf('%s%s_%03d*%s.mat',savedir,prefix,trannum,type_of_average))
  for i=1:30
    pause(1)
  end;
transfiles=dir(sprintf('%s%s_%03d*%s.mat',savedir,prefix,trannum,type_of_average));
end;
  
hsub=[];
kill_script=0;
while kill_script==0
    try
        transfiles=dir(sprintf('%s/%s_%03d*.mat',savedir,prefix,trannum));
        if length(transfiles)==1
            load([savedir transfiles.name]);
            tadcp=adcp;
            iii=1;
        else
            load([savedir transfiles(1).name]);
            tadcp=adcp;
            for iii=2:length(transfiles)
                load([savedir transfiles(iii).name]);
                tadcp=mergefields(tadcp,adcp);
            end
        end
        if nanmean(tadcp.lon)>180; tadcp.lon=tadcp.lon-360; end
        tadcp.depth=tadcp.depth+depth_offset;
        if length(tadcp.time)>3
            if ~isempty(hsub)
                delete(hsub);
            end;
            xlim =  max(tadcp.time)+[-plotinfo.xlim 0];
            good =find(~isnan(tadcp.time));
            xlim(1) = max([xlim(1) min(tadcp.time(good))]);
            hsub(1)=subplot(4,1,1);
            imagesc(tadcp.time,tadcp.depth(:,1),tadcp.u);
            hold on;
            %       plot(tadcp.time,tadcp.bottom,'k','linewidth',1.5);
            %       plot(tadcp.time,cutoff*mean(tadcp.bottom,1),'k','linewidth',0.75);
            caxis(plotinfo.clim);
            kdatetick2;
            set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
            hold on;
            axis('ij');
            ylabel('DEPTH [m]');
            ht=title(sprintf('%s',...
                [transfiles(end).name(1:end-4) '  '],datestr(tadcp.time(end))),...
                'fontname','times','fontsize',8,'interpret','none');
            pp = get(ht,'pos');
            set(ht,'pos',[pp(1) pp(2)+0.07]);
            hc(1)=colorbar('v');axes(hc(1));title('U [m s^{-1}]','fontsize',8);
            smallbar(hsub(1),hc(1));

            hsub(2)=subplot(4,1,2);
            imagesc(tadcp.time,tadcp.depth(:,1),tadcp.v);
            hold on;
            %       plot(tadcp.time,tadcp.bottom,'k','linewidth',1.5);
            %       plot(tadcp.time,cutoff*tadcp.bottom,'k','linewidth',0.75);
            caxis(plotinfo.clim);
            kdatetick2;
            set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
            hold on;
            axis('ij');
            ylabel('DEPTH [m]');
            hc(2)=colorbar('v');axes(hc(2));
            title('V [m s^{-1}]','fontsize',8);
            smallbar(hsub(2),hc(2));

            hsub(3)=subplot(4,1,3);
            imagesc(tadcp.time,tadcp.depth(:,1),tadcp.amp1);
            hold on;
            %       plot(tadcp.time,tadcp.bottom,'k','linewidth',1.5);
            %       plot(tadcp.time,cutoff*tadcp.bottom,'k','linewidth',0.75);
            set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
            kdatetick2;
            hold on;
            ylabel('DEPTH [m]');
            hc(3)=colorbar('v');axes(hc(3));
            title('Echo [dB]','fontsize',8);
            smallbar(hsub(3),hc(3));

            hsub(4)=subplot(4,1,4);
            pppos = get(hsub(4),'pos');
            set(hsub(4),'pos',[pppos(1:2) pppos(3)*0.85 pppos(4)]);
            %       plot_topo('oregon',plotinfo.clev);
            plot(tadcp.lon,tadcp.lat,'k.','markersiz',2);
            hold on;
            plot(tadcp.lon(end),tadcp.lat(end),'r.');
            plot(plotinfo.waypt(:,1),plotinfo.waypt(:,2),'go');
            xlabel('LON');
            ylabel('LAT');
            good =find(~isnan(tadcp.lat));
            medlat=median(tadcp.lat(good));
            xlim = get(gca,'xlim');
            if datenum(clock)-tadcp.time(end)>1/24/4;
                title('CHECK ADCP!','fontsize',36,'FontWeight','bold','color','r')
                beep;
            end

            %      set(gca,'xlim',[plotinfo.waypt(2) xlim(2)]);

            if ~isempty(medlat)
                set(gca,'dataaspectratio',[1 cos(medlat*pi/180) 1]);
                set(gca,'ylim',medlat+[-1 1]*0.05);
                xlims=get(gca,'xlim');
                %         set(gca,'xlim',[min(xlims(1),min(plotinfo.waypt(:,1))-0.05),-124.1]);
                set(gca,'xlim',[min(plotinfo.waypt(:,1))-0.01,max(plotinfo.waypt(:,1))+0.01]);
                xlim=get(gca,'xlim');ylim=get(gca,'ylim');
                % put a line along the top with distances in nautical miles...
                line(xlim,[ylim(1)+0.25*(ylim(2)-ylim(1)),ylim(1)+0.25*(ylim(2)-ylim(1))],'color','k');
                dd = (1/60)/cos(medlat*pi/180);%/1.853 - for km;
                xxx=[xlim(1):5*dd:xlim(2)];
                plot(xxx,(ylim(1)+0.25*(ylim(2)-ylim(1)))*ones(size(xxx)),'kx');
            end;


            % check the gui handles....
            plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
            plotinfo.clim = [-1 1]*str2num(get(guihands(5),'string'));
            plotinfo.xlim = str2num(get(guihands(3),'string'));
            fprintf('Pausing\n');
            for ii=1:waittime/40
                fprintf(1,'.')
                for iii=1:20
                    if kill_script==0
                        pause(1);
                        plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
                        plotinfo.clim = [-1 1]*str2num(get(guihands(5),'string'));
                        plotinfo.xlim = str2num(get(guihands(3),'string'));
                        xlim =  max(tadcp.time)+[-plotinfo.xlim 0];
                        good =find(~isnan(tadcp.time));
                        xlim(1) = max([xlim(1) min(tadcp.time(good))]);
                        set(hsub(1:3),'xlim',xlim,'ylim',plotinfo.ylim);
                    else
                        return
                    end
                end;
                %         end
            end
        end; % if tadcp data is long enough...
    catch
        fprintf('Had trouble: %s\n',lasterr);
        fprintf('Pausing 10 seconds ...');
        for i=1:10
            pause(1);
        end
    end; % catch
end; % end infinite loop
