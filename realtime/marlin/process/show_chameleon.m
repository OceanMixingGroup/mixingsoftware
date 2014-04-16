% appears to run the plotting for chameleon summary plots.   
% Querries user for summary to plot up.

set_chameleon;

figure(12)
temp=get(0,'ScreenSize');
% posi=[0 -52 temp(3)/2 temp(4)-7]; 
posi=[0 round(-0.0341*temp(4)) temp(3)/2 temp(4)-5]; 
set(gcf,'position',posi)
clf
height=.025;
posi=.97;
left=.02;

[file_b path_b]=uigetfile([path_sum '*.mat'],['Choose Summary File']);
load([path_b file_b],'sum');
in=find(sum.direction(:)=='d')
while length(in)<2
    disp('Not enough data. Waiting...');
    for i=1:20; pause(1); end
    load([path_b file_b],'sum');
    in=find(sum.direction(:)=='d');
end   

fig.filename=file_b;
fig.pathname=path_b;
max_file=max(sum.castnumber);
min_file=min(sum.castnumber);
max_depth=sum.depthmax;

fig.h(1)=uicontrol('units','normalized','position',[.02 posi .12 height],'string','Max Depth','fontunits','normalized','fontsize',.25);
fig.h(2)=uicontrol('units','normalized','position',[.26 posi .09 height],'string','Min x','fontunits','normalized','fontsize',.25);
fig.h(3)=uicontrol('units','normalized','position',[.47 posi .09 height],'string','Max x','fontunits','normalized','fontsize',.25);

fig.h(4)=uicontrol('style','edit','units','normalized','position',[.15 posi .06 height],...
    'string','all','fontunits','normalized','fontsize',.25,'callback','plot_cham_summary');
fig.h(5)=uicontrol('style','edit','units','normalized','position',[.36 posi .08 height],...
    'string',num2str(min_file),'fontunits','normalized','fontsize',.25,'callback','plot_cham_summary');
fig.h(6)=uicontrol('style','edit','units','normalized','position',[.57 posi .08 height],...
    'string','all','fontunits','normalized','fontsize',.25,'callback','plot_cham_summary');

nplots=length(fig.toplot);
for jj=1:nplots
  h1=subplot(nplots,1,jj);
  posi=get(h1,'position');,posi(4)=posi(4)*1.2;,set(h1,'position',posi)
  fig.h1(jj)=uicontrol('units','normalized','position',[left ...
     posi(2)+posi(4)-height .06 height],'string','Max','fontunits','normalized','fontsize',.25);
  fig.h2(jj)=uicontrol('units','normalized','position',[left ...
     posi(2)+posi(4)/2-height .06 height],'string','Min','fontunits','normalized','fontsize',.25);
  fig.h3(jj)=uicontrol('style','edit','units','normalized','position',[left ...
     posi(2)+posi(4)*.75-height .06 height],'string',num2str(fig.colmax(jj)),...
 'fontunits','normalized','fontsize',.25,'callback','plot_cham_summary');
  fig.h4(jj)=uicontrol('style','edit','units','normalized','position',[left ...
     posi(2)+posi(4)*.25-height .06 height],'string',num2str(fig.colmin(jj)),...
 'fontunits','normalized','fontsize',.25,'callback','plot_cham_summary');
    
  eval(['dat = ' char(fig.toplot{jj}) ';']);
  ii=1:size(dat,2);
  if fig.ignoreups(jj)
    in=find(sum.direction(:)=='d');
    ii=ii(in);
  end;
  
  xx=sum.filenums+sum.filemin-1;
  pcolor(xx(ii),-sum.depths,dat(:,ii));
  caxis([fig.colmin(jj) fig.colmax(jj)]);
  shading flat
  fig.colhand(jj)=colorbar;
  smallbar(h1,fig.colhand(jj))
  if jj~=nplots
	set(gca,'xticklabel','');
  else
    xlabel(['Profile ' num2str(sum.filemax)],'fontsize',12);
  end
  if max_depth>4
      axis([min_file max_file+1 -max_depth-1 -0])
  else
      axis([min_file max_file+1 -6 -0])
  end    
  axes(fig.colhand(jj));
  ylabel(char(fig.names(jj)),'fontsize',12)
end
while 1
    for i=1:20; pause(1); end
    try
        clear sum
        load([path_b file_b],'sum');
        disp(sum.filemax);
        plot_cham_summary;
        fclose('all');
    catch
        for i=1:20; pause(1); end
        clear sum
        load([path_b file_b],'sum');
        disp(sum.filemax);
        plot_cham_summary;
    end
end
