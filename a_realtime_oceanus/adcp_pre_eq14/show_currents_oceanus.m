% show_currents_oceanus
%
% based on show_workhorse (which was written a very long time ago)
% The only original comment in this file:
% keep loading savefile every timetowait seconds and plot it up...
%
% Originally written by Sasha Perlin... or Jody Klymak or Jonathan Nash
% adapted and commented by Sally Warner, January 2014
%
% The purpose of this code is to plot the adcp data as it is collected on
% board the RV Oceanus. First, the data must be processed,  which is done 
% by run_currents_timer_oceanus (which calls make_currents_oceanus)
% then this code will plot it in real time. 
%
% *** Make sure this is run from a different matlab than the matlab that is
% running the timer for the processing and backing up ***

clear all
close all

% get the path where the processed files are saved, and get some plotting
% parameters. set_currents **NEEDS** to be updated for every cruise. Define
% directories here.
set_currents_oceanus;

% get a list of the processed files within the directories defined in set_currents
wh300files = dir([wh300plotdir '*.mat']);
os75files = dir([os75plotdir '*.mat']);

% get the date of the most recent file
wh300year = wh300files(end).name(3:6);
wh300yearday = wh300files(end).name(8:10);
wh300datenum = datenum(str2num(wh300year),0,str2num(wh300yearday));
wh300datestr = datestr(wh300datenum);
os75year = os75files(end).name(3:6);
os75yearday = os75files(end).name(8:10);
os75datenum = datenum(str2num(os75year),0,str2num(os75yearday));
os75datestr = datestr(os75datenum);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start the plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the screensize to determine how big the plots should be, it will
% take up half the screen
temp=get(0,'ScreenSize');
pos1=[1 200 temp(3)*0.7 temp(4)-300]; 

% make the figures, setting the correct position and name
f1=figure(11);
clf
colormap(redblue3);
set(f1,'name',['u and v velocity, ADCP backscatter, position - WH300 and OS75- '...
    wh300datestr],'position',pos1,'defaultaxesfontsize',14,'color',[1 1 1]);
fstitle = 18;

% a few subplot params
lshift1 = 0.08;
lshift2 = 0.09;
hscale = 1.1;


% add the gui control to the plots 
% this controls: ylimits, xlimits, coloraxis limits in guis that can be
% changed within the plot
eval(['[guihands,plotinfo]=' guifilename '(plotinfo,f1);'])
warning off
fig.stop=uicontrol('units','normalized',...
         'position',[.9 .97 .1 0.025],'string','Stop',...
         'fontunits','normalized','fontsize',.6,...
         'callback','kill_script=1');



% Check if files exist. If none are in the directory defined in
% set_currents, pause for 30 seconds. Then use the dir function to
% recheck for files.
while isempty(wh300files) || isempty(os75files)
    disp('No processed data')
    for i=1:30
        pause(1)
    end
    wh300files = dir([wh300plotdir '*.mat']);
    os75files = dir([os75plotdir '*.mat']);
end
  
% hsub contains the handles for the subplots
hsub1=[];
hsub2=[];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% plot and replot as more files are added %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stop when kill_script does not = 0
kill_script=0;

while kill_script==0
    try
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% load in the wh300 files %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % load the wh300 files and merge them into one structure called
        % adcp300. **** Note: this may take a little while depending on how 
        % many files exist. Possibly want to streamline this by creating a
        % summary file that just adds new data. ****
        wh300files = dir([wh300plotdir '*.mat']);
        if length(wh300files) == 1
        	load([wh300plotdir wh300files.name]);
            adcp300=adcp;
            iii=1;
        else
            load([wh300plotdir wh300files(1).name]);
            adcp300=adcp;
            for iii=2:length(wh300files)
                load([wh300plotdir wh300files(iii).name]);
                adcp300=mergefields(adcp300,adcp);
            end
        end
        % fix the longitude if necessary
        if nanmean(adcp300.lon)>180; 
            adcp300.lon=adcp300.lon-360; 
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% load in the os75 files %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % load the os75 files and merge them into one structure called
        % adcp75. **** Note: this may take a little while depending on how 
        % many files exist. Possibly want to streamline this by creating a
        % summary file that just adds new data. ****
        os75files = dir([os75plotdir '*.mat']);
        if length(os75files)==1
            load([os75plotdir os75files.name]);
            adcp75=adcp;
            iii=1;
        else
            load([os75plotdir os75files(1).name]);
            adcp75=adcp;
            for iii=2:length(os75files)
                load([os75plotdir os75files(iii).name]);
                adcp75=mergefields(adcp75,adcp);
            end
        end
        % fix the longitude if necessary
        if nanmean(adcp75.lon)>180; 
            adcp75.lon=adcp75.lon-360; 
        end
        
        
        
        % clear the subplot handles
        if ~isempty(hsub1)
            delete(hsub1);
        end
        if ~isempty(hsub2)
            delete(hsub2);
        end
      
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% plot the wh300 data %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % (provided that there are more than 3 times)       
        if length(adcp300.time)>3
            
            % find xlims that will plot the last 12 hours of adcp data
            xlim =  max(adcp300.time)+[-plotinfo.xlim 0];
            good = find(~isnan(adcp300.time));
            xlim(1) = max([xlim(1) min(adcp300.time(good))]);
            
            %%%%%%% wh300 - u %%%%%%%
            figure(11)
            
            % create a subplot and adjust the size of this subplot
            hsub1(1)=subplot(4,2,1);
            pp=get(hsub1(1),'position');
            set(hsub1(1),'position',[pp(1)-lshift1,pp(2),pp(3)*hscale,pp(4)]);
            pp=get(hsub1(1),'position');
            
            % plot wh300 u, using imagesc
            imagesc(adcp300.time,adcp300.depth(:,1),adcp300.u)
            hold on
            caxis(plotinfo.clim)
            set(gca,'ylim',plotinfo.ylim300,'xlim',xlim)
            kdatetick
            axis('ij')
            ylabel('DEPTH [m]')
            title('WH300 - u [m s^{-1}]','fontsize',fstitle)
            
%             % create a colorbar
%             hc1(1)=colorbar;
%             set(hsub1(1),'position',pp);
%             set(hc1(1),'position',[pp(1)+pp(3)+0.01 pp(2) 0.015 pp(4)])

            
            %%%%%%% wh300 - v %%%%%%%
            
            % create a subplot and adjust the size of this subplot
            hsub1(2)=subplot(4,2,3);
            pp=get(hsub1(2),'position');
            set(hsub1(2),'position',[pp(1)-lshift1,pp(2),pp(3)*hscale,pp(4)]);
            pp=get(hsub1(2),'position');
            
            % plot wh300 v, using imagesc
            imagesc(adcp300.time,adcp300.depth(:,1),adcp300.v);
            hold on
            caxis(plotinfo.clim);        
            set(gca,'ylim',plotinfo.ylim300,'xlim',xlim);
            kdatetick
            axis('ij');
            ylabel('DEPTH [m]');
            title('WH300 - v [m s^{-1}]','fontsize',fstitle)
            
%             % create a colorbar
%             hc1(2)=colorbar;
%             set(hsub1(2),'position',pp);
%             set(hc1(2),'position',[pp(1)+pp(3)+0.01 pp(2) 0.015 pp(4)])
            
            
            %%%%%%% wh300 - backscatter intensity %%%%%%%
            
            % create a subplot and adjust the size of this subplot
            hsub1(3)=subplot(4,2,5);
            pp=get(hsub1(3),'position');
            set(hsub1(3),'position',[pp(1)-lshift1,pp(2),pp(3)*hscale,pp(4)]);
            pp=get(hsub1(3),'position');
            
            % plot wh300 backscatter intensity, using imagesc
            % (note: only plotting the intensity from the first beam)
            imagesc(adcp300.time,adcp300.depth(:,1),adcp300.amp1);
            hold on
            caxis(plotinfo.climamp);        
            set(gca,'ylim',plotinfo.ylim300,'xlim',xlim);
            kdatetick
            axis('ij');
            ylabel('DEPTH [m]');
            title('WH300 - backscatter intensity [dB]','fontsize',fstitle)
            
%             % create a colorbar
%             hc1(3)=colorbar;
%             set(hsub1(3),'position',pp);
%             set(hc1(3),'position',[pp(1)+pp(3)+0.01 pp(2) 0.015 pp(4)])
            
            
            %%%%%%% wh300 - position %%%%%%%
            
            % create a subplot and adjust the size of this subplot
            hsub1(4)=subplot(4,2,7);
            pp=get(hsub1(4),'position');
            set(hsub1(4),'position',[pp(1)-lshift1,pp(2),pp(3)*hscale,pp(4)]);
            pp=get(hsub1(4),'position');
            
            % plot wh300 position
            plot(adcp300.lon,adcp300.lat,'ko','markerfacecolor','k','markersize',2)
            hold on
            plot(adcp300.lon(end),adcp300.lat(end),'ro',...
                'markerfacecolor','r','markersize',10)
            xlabel('LON')
            ylabel('LAT')
%             set(gca,'ylim',plotinfo.ylim300,'xlim',xlim);
            
            title('WH300 - position','fontsize',fstitle)
            
           
           

            
            %%%%% cleck that the most recent data is being plotted
            %%%%% **** for testing purposes, I have turned this off
%             if datenum(clock)-adcp300.time(end)>1/24/3;
%                 title('CHECK WH300!','fontsize',36,'FontWeight','bold','color','r')
%                 beep;
%             end
        end
            
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% plot the os75 data %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % (provided that there are more than 3 files) 
        if length(adcp75.time)>3
            
            
            %%%%%%% os75 - u %%%%%%% 
            
            % create a subplot and adjust the size of this subplot
            hsub2(1)=subplot(4,2,2);
            pp=get(hsub2(1),'position');
            set(hsub2(1),'position',[pp(1)-lshift2,pp(2),pp(3)*hscale,pp(4)]);
            pp=get(hsub2(1),'position');
            
            % plot os75 u, using imagesc
            imagesc(adcp75.time,adcp75.depth(:,1),adcp75.u);
            hold on
            caxis(plotinfo.clim);
            set(gca,'ylim',plotinfo.ylim75,'xlim',xlim);
            kdatetick
            axis('ij');
            ylabel('DEPTH [m]');
            title('OS75 - u [m s^{-1}]','fontsize',fstitle)
            
            % create a colorbar
            hc2(1)=colorbar;
            set(hsub2(1),'position',pp);
            set(hc2(1),'position',[pp(1)+pp(3)+0.01 pp(2) 0.015 pp(4)])
            

            %%%%%%% os75 - v %%%%%%%
                        
            % create a subplot and adjust the size of this subplot
            hsub2(2)=subplot(4,2,4);
            pp=get(hsub2(2),'position');
            set(hsub2(2),'position',[pp(1)-lshift2,pp(2),pp(3)*hscale,pp(4)]);
            pp=get(hsub2(2),'position');
                        
            % plot os75 u, using imagesc
            imagesc(adcp75.time,adcp75.depth(:,1),adcp75.v);
            hold on
            caxis(plotinfo.clim);
            set(gca,'ylim',plotinfo.ylim75,'xlim',xlim);
            kdatetick
            axis('ij');
            ylabel('DEPTH [m]');
            title('OS75 - v [m s^{-1}]','fontsize',fstitle)

            % create a colorbar
            hc2(2)=colorbar;
            set(hsub2(2),'position',pp);
            set(hc2(2),'position',[pp(1)+pp(3)+0.01 pp(2) 0.015 pp(4)])
            
            
            %%%%%%% os75 - backscatter intensity %%%%%%%
            
            % create a subplot and adjust the size of this subplot
            hsub2(3)=subplot(4,2,6);
            pp=get(hsub2(3),'position');
            set(hsub2(3),'position',[pp(1)-lshift2,pp(2),pp(3)*hscale,pp(4)]);
            pp=get(hsub2(3),'position');
            
            % plot os75 backscatter intensity, using imagesc
            % (note: only plotting the intensity from the first beam)
            imagesc(adcp75.time,adcp75.depth(:,1),adcp75.amp1);
            hold on
            caxis(plotinfo.climamp);        
            set(gca,'ylim',plotinfo.ylim75,'xlim',xlim);
            kdatetick
            axis('ij');
            ylabel('DEPTH [m]');
            title('OS75 - backscatter intensity [dB]','fontsize',fstitle)
            
            % create a colorbar
            hc2(3)=colorbar;
            set(hsub2(3),'position',pp);
            set(hc2(3),'position',[pp(1)+pp(3)+0.01 pp(2) 0.015 pp(4)])
            
            
            %%%%%%% os75 - position %%%%%%%
            
            % create a subplot and adjust the size of this subplot
            hsub2(4)=subplot(4,2,8);
            pp=get(hsub2(4),'position');
            set(hsub2(4),'position',[pp(1)-lshift2,pp(2),pp(3)*hscale,pp(4)]);
            pp=get(hsub2(4),'position');
            
            % plot os75 position
            plot(adcp75.lon,adcp75.lat,'ko','markerfacecolor','k','markersize',2)
            hold on
            plot(adcp75.lon(end),adcp75.lat(end),'ro',...
                'markerfacecolor','r','markersize',10)
            xlabel('LON')
            ylabel('LAT')
%             set(gca,'ylim',plotinfo.ylim300,'xlim',xlim);
            
            title('OS75 - position','fontsize',fstitle)
            
          
            
            
            %%%%% cleck that the most recent data is being plotted
            %%%%% **** for testing purposes, I have turned this off
%             if datenum(clock)-adcp75.time(end)>1/24/3;
%                 title('CHECK OS75!','fontsize',36,'FontWeight','bold','color','r')
%                 beep;
%             end
        end
        
        
        
         annotation('textbox',[0 0.02 0.45 0.02],...
                'string',['last WH300 data from: ' datestr(adcp300.time(end))],...
                'fontsize',18,'EdgeColor',[1 1 1],'HorizontalAlignment',...
                'center','BackgroundColor',[1 1 1])

           annotation('textbox',[0.45 0.02 0.45 0.02],...
                'string',['last OS75 data from: ' datestr(adcp75.time(end))],...
                'fontsize',18,'EdgeColor',[1 1 1],'HorizontalAlignment',...
                'center','BackgroundColor',[1 1 1])   
            


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % implement the gui handles
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % the indices of the gui handles relate to the order that they are
        % defined in teh guifilename which is defined in set_currents. It's
        % an mfile with a name like adduicontrols_al12.
        plotinfo.ylim75 = [0 str2num(get(guihands(3),'string'))];
        plotinfo.ylim300 = [0 str2num(get(guihands(1),'string'))];
        plotinfo.clim = [-1 1]*str2num(get(guihands(7),'string'));
        plotinfo.climamp = [-1 1]*str2num(get(guihands(9),'string'));
        plotinfo.xlim = str2num(get(guihands(5),'string'));
        
        
        disp(['Plotting at ' datestr(now)])
        for ii=1:waittime/60
            fprintf(1,'.')
            for iii=1:10
                if kill_script==0
                    pause(1);
                    
                    % get the gui limits from the figure
                    plotinfo.ylim75 = [0 str2num(get(guihands(3),'string'))];
                    plotinfo.ylim300 = [0 str2num(get(guihands(1),'string'))];
                    plotinfo.clim = [-1 1]*str2num(get(guihands(7),'string'));
                    plotinfo.climamp = [-1 1]*str2num(get(guihands(9),'string'));
                    plotinfo.xlim = str2num(get(guihands(5),'string'));
                    
                    % implement the new gui limits
                    xlim =  max(adcp300.time)+[-plotinfo.xlim 0];
                    good = find(~isnan(adcp300.time));                    
                    xlim =  adcp300.time(good(end))+[-plotinfo.xlim 0];
                    xlim(1) = max([xlim(1) min(adcp300.time(good))]);
                    set(hsub1(1:3),'xlim',xlim,'ylim',plotinfo.ylim300);
                    set(hsub2(1:3),'xlim',xlim,'ylim',plotinfo.ylim75);
                    for kk = 1:3
                        axes(hsub1(kk));
                        kdatetick
                        axes(hsub2(kk));
                        kdatetick
                    end
                    caxis(hsub1(1),plotinfo.clim);
                    caxis(hsub1(2),plotinfo.clim);
                    caxis(hsub2(1),plotinfo.clim);
                    caxis(hsub2(2),plotinfo.clim);
                    caxis(hsub1(3),plotinfo.climamp);
                    caxis(hsub2(3),plotinfo.climamp);
                else
                    return
                end
            end
        end
    catch
        fprintf('Had trouble: %s\n',lasterr);
        fprintf('Pausing 10 seconds ...');
        for i=1:10
            pause(1);
        end
    end; % catch
end; % end infinite loop
