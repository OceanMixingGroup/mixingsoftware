% show_chameleon_timer.m
%
% notes added by sjw, January 2014
%
% ******************************************************
% This code plots the processed chameleon data. It's on a timer, so the
% figure is updated as new data is collected.
%
% If you need to stop this code from running. The timer object is called
% "tsc" so simply type the command: stop(tsc)
% ******************************************************


% get information about the deployment such as path names of the raw and
% processed data. Also set what is to be plotted in each subplot.
set_chameleon_oceanus;

% use a gui to choose the summary file to be plotted. path_sum is
% determined so the gui automatically goes to the correct folder.
path_sum=[path_cham filesep 'sum' filesep];
[file_b path_b]=uigetfile([path_sum '*.mat'],['Choose Summary File']);

% start creating the figure. Give it the correct name and position. Set the
% height and positions of the subplots.
f=figure(12);
set(f,'name',[' Chameleon summary file ' file_b(1:end-4)],'color','w');
temp=get(0,'ScreenSize');
posi=[0 round(-0.0341*temp(4)) temp(3)/2 temp(4)-5]; 
set(gcf,'position',posi)
clf
height=.025;
posi=.97;
left=.02;
fs = 12; % define the font size

% load in the summary file
load([path_b file_b]);

% Only want to plot the down-casts. Make an index that does not include up-casts.
% If there are fewer than two casts, do not start plotting until more casts
% are recorded and plotted.
in=find(cham.direction(:)=='d');
while length(in)<2
    disp('Not enough data. Waiting...');
    for i=1:20; pause(1); end
    load([path_b file_b],'cham');
    in=find(cham.direction(:)=='d');
end   

% add the file and pathnames to the structure 'fig'
fig.filename=file_b;
fig.pathname=path_b;

% max_file and min_file are the numbers of the first and last cast to be
% plotted as included in the processed summary file. max_depth is the
% maximum recorded depth of the chameleon.
max_file=cham.filemax;
min_file=cham.filemin;
max_depth=cham.depthmax;

% add gui controls to the plot so that the maximum depth, and min and max of x
% can all be changed through the plot itself.
fig.h(1)=uicontrol('units','normalized','position',[.02 posi .12 height],...
    'string','Max Depth','fontunits','normalized','fontsize',.6);
fig.h(2)=uicontrol('units','normalized','position',[.26 posi .09 height],...
    'string','Min x','fontunits','normalized','fontsize',.6);
fig.h(3)=uicontrol('units','normalized','position',[.47 posi .09 height],...
    'string','Max x','fontunits','normalized','fontsize',.6);

fig.h(4)=uicontrol('style','edit','units','normalized','position',[.15 posi .06 height],...
    'string','all','fontunits','normalized','fontsize',.6,'callback','plot_cham_summary');
fig.h(5)=uicontrol('style','edit','units','normalized','position',[.36 posi .08 height],...
    'string',num2str(min_file),'fontunits','normalized','fontsize',.6,'callback','plot_cham_summary');
fig.h(6)=uicontrol('style','edit','units','normalized','position',[.57 posi .08 height],...
    'string','all','fontunits','normalized','fontsize',.6,'callback','plot_cham_summary');
fig.h(7)=uicontrol('units','normalized','position',[.7 posi .09 height],'string','Stop',...
  'fontunits','normalized','fontsize',.6,'callback','delete(timerfind(tsc));clear tsc');


% PLOT
% start plotting the subplots. The number of subplots and what goes into
% them is written into set_chameleon. Loop through each subplot.
nplots=length(fig.toplot);
for jj=1:nplots
    % create a subplot and change its size
    h1=subplot(nplots,1,jj);set(h1,'fontsize',fs);
    sp=get(h1,'position'); set(h1,'position',[sp(1) sp(2) sp(3)-0.05 sp(4)]);
    posi=get(h1,'position');,posi(4)=posi(4)*1.2;,set(h1,'position',posi)
    
    % add gui controls which allow the user to change the color limits of 
    % the pcolor plots from the figure.
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
    
    % call correct data for this particular subplot 'dat'
    eval(['dat = ' char(fig.toplot{jj}) ';']);
    
    % ii is the number of casts to be plotted (i.e. the length of the data
    % along the x-axis). Only plot the down-casts.
    ii=1:size(dat,2);
    in=find(cham.direction(:)=='d');
    ii=ii(in);
    
    % pcolor the data. set the correct color limits. Color limits are set
    % in set_chameleon at start of this code.
    pcolor(cham.castnumber(ii),-cham.depth,real(dat(:,ii)));
    shading flat
    caxis([fig.colmin(jj) fig.colmax(jj)]);
    
    % add a colorbar. Give it the correct font size and make it skinny.
    fig.colhand(jj)=colorbar; set(fig.colhand(jj),'fontsize',fs);
    smallbar(h1,fig.colhand(jj));
    cpi=get(fig.colhand(jj),'position');
    spi=get(h1,'position');
    if jj>1
        set(h1,'position',[spf(1) spi(2) spf(3) spf(4)]);
        set(fig.colhand(jj),'position',[cpf(1) spi(2) cpf(3) spf(4)]);
    else
        set(fig.colhand(jj),'position',[cpi(1) spi(2) cpi(3) spi(4)]);
    end
    spf=get(h1,'position');  cpf=get(fig.colhand(jj),'position');
    
    % add an x-label to the bottom subplot
    if jj~=nplots
        set(gca,'xticklabel','');
    else
        xlabel(['Profile ' num2str(cham.filemax)],'fontsize',fs);
    end
    
    % make sure the x and y-axes have the correct limits 
    if max_depth>4
        axis([min_file max_file+1 -max_depth-1 0])
    else
        axis([min_file max_file+1 -6 0])
    end    

    % add the correct y-label
    ylabel(fig.colhand(jj),char(fig.names(jj)),'fontsize',fs)
    
    % make sure the font size of the axis is correct
    set(gca,'fontsize',fs)
end

% % % % create a timer that will automatically update this plot as new data is
% % % % collected.
% % % tsc=timer('TimerFcn','plot_cham_summary_timer',...
% % %     'Period',20,'executionmode','fixedrate','busymode','queue');
% % % STARTTIME=now+1/86400;
% % % startat(tsc,STARTTIME);
