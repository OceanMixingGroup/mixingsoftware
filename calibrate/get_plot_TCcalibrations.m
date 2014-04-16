function [sbd,sensdata,senstime]=get_plot_TCcalibrations(ai,ssb,sbd,fb,ii,channels,plotsec,pairs)
% function get_plot_TCcalibrations(ai,ssb,sbd,fb,ii,channels,plotsec,pairs)
% get data from Seabird and plot sensors & Seabird
% called by function labTCcalibration.m,
% $Revision: 1.2 $ $Date: 2011/05/24 21:58:53 $ $Author: aperlin $	
% A. Perlin, September 2010

good=0;
while ~good
    try
        % send reqiest for data output
        fprintf(ssb,'%s\r','ts')
        % the readout includes three lines: comand sent, sensor output and
        % confirmation that execution was successful
        junk=fgets(ssb);
        sbdline=fgets(ssb);
        junk=fgets(ssb);
        temp=textscan(sbdline(2:end),'%f %f %s %s','delimiter',',');
        good=1;
        sbd.t(ii,1)=temp{1}; sbd.c(ii,1)=temp{2};
        sbd.time(ii,1)=datenum([char(temp{3}) char(temp{4})],'dd mmm yyyyHH:MM:SS');
    catch
        disp('Can''t read Seabird. Pausing 2 seconds...')
        pause(2)
    end
end
% get last plotsec seconds of the data
itime=find(sbd.time>(sbd.time(ii)-plotsec/3600/24));
sensdata=peekdata(ai,plotsec*ai.sampleRate);
senstime=[-size(sensdata,1)/ai.samplerate+1/ai.samplerate:1/ai.samplerate:0]'/86400+now;
set(0,'CurrentFigure',fb);
sp=subplot(5,1,1);
spp=get(sp,'position');
set(sp,'position',[spp(1) spp(2) spp(3) spp(4)*1.1])
plot(sbd.time(itime:ii),sbd.t(itime:ii),'k-','linewidth',2)
set(gca,'xlim',[sbd.time(ii)-plotsec/3600/24 sbd.time(ii)])
kdatetick2
ylabel('Seabird T')
set(0,'CurrentFigure',fb);
sp=subplot(5,1,2);
spp=get(sp,'position');
set(sp,'position',[spp(1) spp(2) spp(3) spp(4)*1.1])
plot(sbd.time(itime),sbd.c(itime),'k-','linewidth',2)
set(gca,'xlim',[sbd.time(ii)-plotsec/3600/24 sbd.time(ii)])
kdatetick2
ylabel('Seabird C')
set(0,'CurrentFigure',fb);
sp=subplot(5,1,[3:5]);
spp=get(sp,'position');
set(sp,'position',[spp(1) spp(2) spp(3) spp(4)*1.03])
plot(senstime,sensdata(:,1:channels(end)+1),'linewidth',2)
set(gca,'xlim',[sbd.time(ii)-plotsec/3600/24 sbd.time(ii)])
ylabel('Raw sensor output [V]')
kdatetick
legend(pairs,'location','sw')
drawnow; % forces Matlab to update the figure
