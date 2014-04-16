% function show_workhorse;
% keep loading savefile every timetowait seconds and plot it up...

prefix=input('Enter prefix --> ');
set_workhorse;
trannum=input('Enter number of ADCP transect --> ');
transfiles=dir(sprintf('%s%s%03d*%s.mat',savedir,prefix,trannum,type_of_average));

f=figure(11);
set(f,'name',[' Workhorse ' ADCP_type '. Transect #' num2str(trannum)]);
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
[guihands,plotinfo]=adduicontrols_sh(plotinfo,gcf);
warning off
fig.stop=uicontrol('units','normalized',...
         'position',[.45 .97 .1 0.025],'string','Stop',...
         'fontunits','normalized','fontsize',.6,...
         'callback','kill_script=1');

while isempty(transfiles)
  fprintf('Cannot find %s;   Pausing\n',sprintf('%s%s%03d*%s.mat',savedir,prefix,trannum,type_of_average))
  for i=1:30
    pause(1)
  end;
transfiles=dir(sprintf('%s%s%03d*%s.mat',savedir,prefix,trannum,type_of_average));
end;
  
hsub=[];
kill_script=0;
while kill_script==0
  try
    transfiles=dir(sprintf('%s%s%03d*%s.mat',savedir,prefix,trannum,type_of_average));
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
    if length(tadcp.time2)>3 % time1 : ADCP time
                            % time2 : GPS time
    % navtime correction
     bad=find(diff(tadcp.navlasttime)<-0.9);
     tadcp.navlasttime(bad+1)=tadcp.navlasttime(bad+1)+1;
     bad=find(diff(tadcp.navlasttime)<-0.9);
     tadcp.navlasttime(bad+1)=tadcp.navlasttime(bad+1)+1;
     bad=find(diff(tadcp.navlasttime)>0.9);
     tadcp.navlasttime(bad+1)=tadcp.navlasttime(bad+1)-1;
     bad=find(diff(tadcp.navfirsttime)<-0.9);
     tadcp.navfirsttime(bad+1)=tadcp.navfirsttime(bad+1)+1;
     bad=find(diff(tadcp.navfirsttime)<-0.9);
     tadcp.navfirsttime(bad+1)=tadcp.navfirsttime(bad+1)+1;
     bad=find(diff(tadcp.navfirsttime)>0.9);
     tadcp.navfirsttime(bad+1)=tadcp.navfirsttime(bad+1)-1;
%       $$$ CORRECTION FOR ADCP MISALINMENT $$$
      U = tadcp.vel1+tadcp.vel2*sqrt(-1);
      U = U.*repmat(exp(sqrt(-1)*angle_offset*pi/180),size(U,1),size(U,2));
      tadcp.vel1 = real(U);
      tadcp.vel2 = imag(U);
      if isfield(tadcp,'bt_vel1')
          Ub=tadcp.bt_vel1+sqrt(-1)*tadcp.bt_vel2;
          Ub=Ub*exp(sqrt(-1)*angle_offset*pi/180);
          tadcp.bt_vel1=real(Ub); tadcp.bt_vel2=imag(Ub);
      end
% %       $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%       tadcp.ubt=tadcp.bt_vel1;
%       tadcp.vbt=tadcp.bt_vel2;
%       tadcp.u = tadcp.vel1;
%       tadcp.v = tadcp.vel2;
%     GET BOTTOMTRACKING FROM GPS
      [gps.x,gps.y]=lonlattox(tadcp.navfirstlon,tadcp.navfirstlat,tadcp.navfirstlon(1),tadcp.navfirstlat(1));
      gps.u=-diff(gps.x)./diff(tadcp.navfirsttime*24*3600);gps.u(end+1)=gps.u(end);
      gps.v=-diff(gps.y)./diff(tadcp.navfirsttime*24*3600);gps.v(end+1)=gps.v(end);
      % substitute bad bottomtracking with gps
      if isfield(tadcp,'bt_vel1')
          bad=find(isnan(tadcp.bt_vel2) | abs(tadcp.bt_vel2)>7 | abs(tadcp.bt_vel1)>7);
      else
          bad=1:length(gps.u);
      end
      tadcp.bt_vel1(bad)=gps.u(bad);
      tadcp.bt_vel2(bad)=gps.v(bad);

     % subtract bottom tracking....
      tadcp.u = tadcp.vel1-ones(size(tadcp.vel1,1),1)*tadcp.bt_vel1;
      tadcp.v = tadcp.vel2-ones(size(tadcp.vel2,1),1)*tadcp.bt_vel2;
      % calculate shear squared
      dz=tadcp.binpos(2)-tadcp.binpos(1);
      tadcp.Sh2=(diff(tadcp.u)./dz).^2+(diff(tadcp.v)./dz).^2;
      tadcp.depth=(tadcp.binpos+depth_offset);
      if isfield(tadcp,'bt_range1')
          tadcp.bottom=(tadcp.bt_range1+tadcp.bt_range2+tadcp.bt_range3+tadcp.bt_range4)./4+depth_offset;
          bad=find(tadcp.bottom==depth_offset);
          tadcp.bottom(bad)=NaN;
      end
      tadcp.lon=(tadcp.navfirstlon+tadcp.navlastlon)./2;
      tadcp.lat=(tadcp.navfirstlat+tadcp.navlastlat)./2;
      tadcp.time1=tadcp.time1-datenum(100,0,-1);
     
      if ~isempty(hsub)
        delete(hsub);
      end;
      
      xlim =  max(tadcp.time1)+[-plotinfo.xlim 0];
      good =find(~isnan(tadcp.time1));
      xlim(1) = max([xlim(1) min(tadcp.time1(good))]);
      hsub(1)=subplot(4,1,1);
      imagesc(tadcp.time1,tadcp.depth(:,1),tadcp.u);
      hold on;
      if isfield(tadcp,'bottom')
         plot(tadcp.time1,mean(tadcp.bottom,1),'k','linewidth',1.5);
         plot(tadcp.time1,0.85*mean(tadcp.bottom,1),'k','linewidth',0.75);
      end
      caxis(plotinfo.clim);
      kdatetick2;
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      hold on;
      axis('ij');
      ylabel('DEPTH [m]');
      ht=title(sprintf('%s',...
        [transfiles(end).name(1:end-4) '  '],datestr(tadcp.navlasttime(end))),...
        'fontname','times','fontsize',8,'interpret','none');
      pp = get(ht,'pos');
      set(ht,'pos',[pp(1) pp(2)+0.07]);  
      hc(1)=colorbar('v');title(hc(1),'U [m\cdots^{-1}]','fontsize',8);
      smallbar(hsub(1),hc(1));
      
      hsub(2)=subplot(4,1,2);
      imagesc(tadcp.time1,tadcp.depth(:,1),tadcp.v);
      hold on;
      if isfield(tadcp,'bottom')
          plot(tadcp.time1,mean(tadcp.bottom,1),'k','linewidth',1.5);
          plot(tadcp.time1,0.85*mean(tadcp.bottom,1),'k','linewidth',0.75);
      end
      caxis(plotinfo.clim);
      kdatetick2;
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      hold on;
      axis('ij');
      ylabel('DEPTH [m]');
      hc(2)=colorbar('v');axes(hc(2));
      title('V [m\cdots^{-1}]','fontsize',8);
      smallbar(hsub(2),hc(2));
      
      hsub(3)=subplot(4,1,3);
      imagesc(tadcp.time1,tadcp.depth(:,1),tadcp.echo1);
      hold on;
      if isfield(tadcp,'bottom')
          plot(tadcp.time1,mean(tadcp.bottom,1),'k','linewidth',1.5);
          plot(tadcp.time1,0.85*mean(tadcp.bottom,1),'k','linewidth',0.75);
      end
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      kdatetick2;
      hold on;
      ylabel('DEPTH [m]');
      hc(3)=colorbar('v');axes(hc(3));
      title('Echo [dB]','fontsize',8);
      smallbar(hsub(3),hc(3));
      
      hsub(4)=subplot(4,1,4);
      imagesc(tadcp.time1,tadcp.depth(1:end-1,1)+dz/2,log10(tadcp.Sh2));
      hold on;
      if isfield(tadcp,'bottom')
          plot(tadcp.time1,mean(tadcp.bottom,1),'k','linewidth',1.5);
          plot(tadcp.time1,0.85*mean(tadcp.bottom,1),'k','linewidth',0.75);
      end
      caxis(plotinfo.clim2);
      set(gca,'ylim',plotinfo.ylim,'xlim',xlim);
      kdatetick2;
      hold on;
      ylabel('DEPTH [m]');
      hc(4)=colorbar('v');axes(hc(4));
      title('Shear^2 [m^2\cdots^{-2}]','fontsize',8);
      smallbar(hsub(4),hc(4));
      
%       hsub(4)=subplot(4,1,4);
%       pppos = get(hsub(4),'pos');
%       set(hsub(4),'pos',[pppos(1:2) pppos(3)*0.85 pppos(4)]);
% %       plot_topo('oregon',plotinfo.clev);
%       plot(tadcp.lon,tadcp.lat,'k.','markersiz',2);
%       hold on;
%       plot(tadcp.lon(end),tadcp.lat(end),'r.');
%       plot(plotinfo.waypt(:,1),plotinfo.waypt(:,2),'go');
%       xlabel('LON');
%       ylabel('LAT');
%       good =find(~isnan(tadcp.lat));
%       medlat=median(tadcp.lat(good));
%       xlim = get(gca,'xlim');
      if datenum(clock)-tadcp.navlasttime(end)>1/24/3;
          title('CHECK ADCP!','fontsize',36,'FontWeight','bold','color','r')
          beep;
      end
          
%      set(gca,'xlim',[plotinfo.waypt(2) xlim(2)]);
      
%       if ~isempty(medlat)
%         set(gca,'dataaspectratio',[1 cos(medlat*pi/180) 1]);
%         set(gca,'ylim',medlat+[-1 1]*0.05);
%         xlims=get(gca,'xlim');
% %         set(gca,'xlim',[min(xlims(1),min(plotinfo.waypt(:,1))-0.05),-124.1]);
%         set(gca,'xlim',[min(plotinfo.waypt(:,1))-0.1,-124.3]);
%         xlim=get(gca,'xlim');ylim=get(gca,'ylim');
%         % put a line along the top with distances in nautical miles...
%         line(xlim,[ylim(1)+0.25*(ylim(2)-ylim(1)),ylim(1)+0.25*(ylim(2)-ylim(1))],'color','k');
%         dd = (1/60)/cos(medlat*pi/180);%/1.853 - for km;
%         xxx=[xlim(1):5*dd:xlim(2)];
%         plot(xxx,(ylim(1)+0.25*(ylim(2)-ylim(1)))*ones(size(xxx)),'kx');
%       end;
      
      
      % check the gui handles....
      plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
      plotinfo.clim = [-1 1]*str2num(get(guihands(4),'string'));
      plotinfo.clim2(2) = str2num(get(guihands(3),'string'));
      plotinfo.xlim = str2num(get(guihands(2),'string'));
      fprintf('Pausing\n');
      for ii=1:waittime/20
        fprintf(1,'.')
          for iii=1:20
            if kill_script==0
              pause(1);
              plotinfo.ylim = [0 str2num(get(guihands(1),'string'))];
              plotinfo.clim = [-1 1]*str2num(get(guihands(4),'string'));
              plotinfo.clim2(2) = str2num(get(guihands(3),'string'));
              plotinfo.xlim = str2num(get(guihands(2),'string'));
              xlim =  max(tadcp.time1)+[-plotinfo.xlim 0];
              good =find(~isnan(tadcp.time1));
              xlim(1) = max([xlim(1) min(tadcp.time1(good))]);
              set(hsub(1:4),'xlim',xlim,'ylim',plotinfo.ylim);
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
