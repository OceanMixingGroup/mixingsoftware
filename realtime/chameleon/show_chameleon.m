% show_chameleon.m

set_chameleon;
path_sum=[path_cham '/sum/'];
[file_b path_b]=uigetfile([path_sum '*.mat'],['Choose Summary File']);
f=figure(12);
set(f,'name',[' Chameleon summary file ' file_b(1:end-4)]);
temp=get(0,'ScreenSize');
% posi=[0 -52 temp(3)/2 temp(4)-7]; 
posi=[0 round(-0.0341*temp(4)) temp(3)/2 temp(4)-5]; 
set(gcf,'position',posi)
clf
height=.025;
posi=.97;
left=.02;

load([path_b file_b]);
in=find(cham.direction(:)=='d');
while length(in)<2
    disp('Not enough data. Waiting...');
    for i=1:20; pause(1); end
    load([path_b file_b],'cham');
    in=find(cham.direction(:)=='d');
end   

fig.filename=file_b;
fig.pathname=path_b;
% max_file=max(cham.castnumber);
% min_file=min(cham.castnumber);
max_file=cham.filemax;
min_file=cham.filemin;
max_depth=cham.depthmax;

fig.h(1)=uicontrol('units','normalized','position',[.02 posi .12 height],'string','Max Depth','fontunits','normalized','fontsize',.6);
fig.h(2)=uicontrol('units','normalized','position',[.26 posi .09 height],'string','Min x','fontunits','normalized','fontsize',.6);
fig.h(3)=uicontrol('units','normalized','position',[.47 posi .09 height],'string','Max x','fontunits','normalized','fontsize',.6);

fig.h(4)=uicontrol('style','edit','units','normalized','position',[.15 posi .06 height],...
    'string','all','fontunits','normalized','fontsize',.6,'callback','plot_cham_summary');
fig.h(5)=uicontrol('style','edit','units','normalized','position',[.36 posi .08 height],...
    'string',num2str(min_file),'fontunits','normalized','fontsize',.6,'callback','plot_cham_summary');
fig.h(6)=uicontrol('style','edit','units','normalized','position',[.57 posi .08 height],...
    'string','all','fontunits','normalized','fontsize',.6,'callback','plot_cham_summary');
fig.h(7)=uicontrol('units','normalized','position',[.7 posi .09 height],'string','Stop',...
  'fontunits','normalized','fontsize',.6,'callback','kill_script=1');


nplots=length(fig.toplot);
for jj=1:nplots
  h1=subplot(nplots,1,jj);set(h1,'fontsize',8);
  sp=get(h1,'position'); set(h1,'position',[sp(1) sp(2) sp(3)-0.05 sp(4)]);
  posi=get(h1,'position');,posi(4)=posi(4)*1.2;,set(h1,'position',posi)
  fig.h1(jj)=uicontrol('units','normalized','position',[left ...
     posi(2)+posi(4)-height .06 height],'string','Max','fontunits','normalized','fontsize',.6);
  fig.h2(jj)=uicontrol('units','normalized','position',[left ...
     posi(2)+posi(4)/2-height .06 height],'string','Min','fontunits','normalized','fontsize',.6);
  fig.h3(jj)=uicontrol('style','edit','units','normalized','position',[left ...
     posi(2)+posi(4)*.75-height .06 height],'string',num2str(fig.colmax(jj)),...
 'fontunits','normalized','fontsize',.6,'callback','plot_cham_summary');
  fig.h4(jj)=uicontrol('style','edit','units','normalized','position',[left ...
     posi(2)+posi(4)*.25-height .06 height],'string',num2str(fig.colmin(jj)),...
 'fontunits','normalized','fontsize',.6,'callback','plot_cham_summary');
    
  eval(['dat = ' char(fig.toplot{jj}) ';']);
  ii=1:size(dat,2);
  in=find(cham.direction(:)=='d');
  ii=ii(in);
  xx=cham.filenums+cham.filemin-1;
%   xx=cham.filenums+cham.filemin-1;
%   pcolor(xx(ii),-cham.depth,dat(:,ii));
  pcolor(cham.castnumber(ii),-cham.depth,real(dat(:,ii)));
  caxis([fig.colmin(jj) fig.colmax(jj)]);
  shading flat
  fig.colhand(jj)=colorbar; set(fig.colhand(jj),'fontsize',8);
  smallbar(h1,fig.colhand(jj));
  cpi=get(fig.colhand(jj),'position');spi=get(h1,'position');
  if jj>1
    set(h1,'position',[spf(1) spi(2) spf(3) spf(4)]);
    set(fig.colhand(jj),'position',[cpf(1) spi(2) cpf(3) spf(4)]);
  else
    set(fig.colhand(jj),'position',[cpi(1) spi(2) cpi(3) spi(4)]);
  end
  spf=get(h1,'position');  cpf=get(fig.colhand(jj),'position');
  if jj~=nplots
	set(gca,'xticklabel','');
  else
    xlabel(['Profile ' num2str(cham.filemax)],'fontsize',9);
  end
  if max_depth>4
      axis([min_file max_file+1 -max_depth-1 0])
  else
      axis([min_file max_file+1 -6 0])
  end    
%   axes(fig.colhand(jj));
  ylabel(fig.colhand(jj),char(fig.names(jj)),'fontsize',9)
end
kill_script=0;
while kill_script==0
  for i=1:10;
    if kill_script==0
      pause(2);
    else
      return;
    end
  end
  try
    clear cham
    load([path_b file_b]);
    disp(cham.filemax);
    plot_cham_summary;
    fclose('all');
  catch
    if kill_script==0
      pause(1);
    else
      return;
    end
    clear cham
    load([path_b file_b]);
    disp(cham.filemax);
    plot_cham_summary;
  end
end
