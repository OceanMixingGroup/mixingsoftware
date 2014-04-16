function runTcalibrationV2(source,eventdata)
% function to run Chipod T calibration using Microcat Seabird37. 
% This function is called by ChipodTCcalibration.m
% $Revision: 1.2 $ $Date: 2011/07/29 23:35:38 $ $Author: aperlin $	
% A. Perlin, December 2010

% Path to save calibration results
outdir='c:\work\calibration\chipod\T\';
warning off;
if ~isempty(strfind(get(source,'Enable'),'on'))
    set(source,'backgroundcolor','g')
end
pause(0.1);
% get calibration parameters
hfig=get(source,'Parent');
extradata=get(hfig,'UserData');
if extradata.Trange(1)==extradata.Trange(2)
    disp('Please Correct Temperature Range')
    set(source,'backgroundcolor',[0.8314 0.8157 0.7843])
    return
end
sbd.time=ones(40000,1)*NaN;
sbd.t=ones(40000,1)*NaN;
count=ones(40000,1)*NaN;
sp=subplot(3,2,[3:6]);
ylabel('Bath temperature [^oC]')
mkdir(outdir);
outdir=[outdir '\' datestr(now,'yyyy-mm-dd') '\'];
mkdir(outdir);
Trange=extradata.Trange;
tpoint=linspace(Trange(1),Trange(2),extradata.npts);
ssb=serial('COM1');
fopen(ssb);
fopen(ssb);
pause(1);
%%
% Seabird Setup
% Set Output Format
fprintf(ssb,'%s\r','OutputFormat=1')
junk=fgets(ssb);
junk=fgets(ssb);
% pause(.2);
% Disable output Salinity
fprintf(ssb,'%s\r','OutputSal=0')
junk=fgets(ssb); 
junk=fgets(ssb);
% Disable output Sound Velocity
fprintf(ssb,'%s\r','OutputSV=0')
junk=fgets(ssb);
junk=fgets(ssb);
% pause(.2);
% Disable Sync Mode
fprintf(ssb,'%s\r','SyncMode=0')
junk=fgets(ssb);
junk=fgets(ssb);
% pause(.2);
% Do not measure (and output) Pressure; must be repeated twice
fprintf(ssb,'%s\r','SetPressureInstalled=0')
junk=fgets(ssb);
junk=fgets(ssb);
junk=fgets(ssb);
pause(.2);
fprintf(ssb,'%s\r','SetPressureInstalled=0')
junk=fgets(ssb);
junk=fgets(ssb);
junk=fgets(ssb);
pause(0.5);
% Syncronize time
fprintf(ssb,'%s\r',['DateTime=' datestr(now,'mmddyyyyHHMMSS')])
SetSeabirdTime=fgets(ssb);
junk=fgets(ssb);
disp(SetSeabirdTime)

set(ssb,'DataTerminalReady','off')
set(ssb,'DataTerminalReady','on')
if Trange(1)<Trange(2)
    caldir='UP';
    set(ssb,'DataTerminalReady','on')
else
    caldir='DN';
    set(ssb,'DataTerminalReady','off')
end
ii=1;
good=0;
while ~good
    try
        fprintf(ssb,'%s\r','ts')
        % the readout includes three lines: comand sent, sensor output and
        % confirmation that execution was successful
        junk=fgets(ssb);
        sbdline=fgets(ssb);
        junk=fgets(ssb);
        sbline=textscan(sbdline(2:end),'%f %f %s %s','delimiter',',');
        sbd.t(ii)=sbline{1}; sbd.c(ii)=sbline{2};
        sbd.time(ii)=datenum([char(sbline{3}) char(sbline{4})],'dd mmm yyyyHH:MM:SS');
        good=1;
    catch
        disp('Can''t read Seabird. Pausing 2 seconds...')
        pause(2)
    end
end
if ~isempty(strfind(caldir,'UP')) && sbd.t(ii)>Trange(1)
    disp('Bath temperature is higher than T start. Turning off heater...')
    t1=text(0.05,0.6,'Bath temperature is higher than T start.','fontsize',14,'units','normalized');
    t2=text(0.05,0.4,'Turning off heater...','fontsize',14,'units','normalized');
    set(ssb,'DataTerminalReady','off')
    while sbd.t(ii)>Trange(1)
        pause(3);
        ii=ii+1;
        good=0;
        while ~good
            try
                fprintf(ssb,'%s\r','ts')
                % the readout includes three lines: comand sent, sensor output and
                % confirmation that execution was successful
                junk=fgets(ssb);
                sbdline=fgets(ssb);
                junk=fgets(ssb);
                sbline=textscan(sbdline(2:end),'%f %f %s %s','delimiter',',');
                sbd.t(ii)=sbline{1}; sbd.c(ii)=sbline{2};
                sbd.time(ii)=datenum([char(sbline{3}) char(sbline{4})],'dd mmm yyyyHH:MM:SS');
                good=1;
            catch
%                 disp('Can''t read Seabird. Pausing 1 second...')
                pause(1)
            end
        end
        lpl=min(2199,ii-1);
        plot(sbd.time(ii-lpl:ii),sbd.t(ii-lpl:ii));datetick;
    end
    cla
    set(ssb,'DataTerminalReady','on')
elseif ~isempty(strfind(caldir,'DN')) && sbd.t(ii)<Trange(1)
    disp('Bath temperature is lower than T start. Turning on heater...')
    t1=text(0.05,0.6,'Bath temperature is lower than T start.','fontsize',14,'units','normalized');
    t2=text(0.05,0.4,'Turning on heater...','fontsize',14,'units','normalized');
    set(s1,'DataTerminalReady','on')
    while sbd.t(ii)<Trange(1)
        pause(3);
        ii=ii+1;
        good=0;
        while ~good
            try
                fprintf(ssb,'%s\r','ts')
                % the readout includes three lines: comand sent, sensor output and
                % confirmation that execution was successful
                junk=fgets(ssb);
                sbdline=fgets(ssb);
                junk=fgets(ssb);
                sbline=textscan(sbdline(2:end),'%f %f %s %s','delimiter',',');
                sbd.t(ii)=sbline{1}; sbd.c(ii)=sbline{2};
                sbd.time(ii)=datenum([char(sbline{3}) char(sbline{4})],'dd mmm yyyyHH:MM:SS');
                good=1;
            catch
                % disp('Can''t read Seabird. Pausing 1 second...')
                pause(1)
            end
        end
        lpl=min(2199,ii-1);
        plot(sbd.time(ii-lpl:ii),sbd.t(ii-lpl:ii));datetick;
    end
    cla
    set(ssb,'DataTerminalReady','off')
end
for nn=1:length(tpoint)
    disp([nn tpoint(nn)])
    flag=0;
    stp=0;
    while ~stp
        pause(3)
        ii=ii+1;
        good=0;
        while ~good
            try
                fprintf(ssb,'%s\r','ts')
                % the readout includes three lines: comand sent, sensor output and
                % confirmation that execution was successful
                junk=fgets(ssb);
                sbdline=fgets(ssb);
                junk=fgets(ssb);
                sbline=textscan(sbdline(2:end),'%f %f %s %s','delimiter',',');
                sbd.t(ii)=sbline{1}; sbd.c(ii)=sbline{2};
                sbd.time(ii)=datenum([char(sbline{3}) char(sbline{4})],'dd mmm yyyyHH:MM:SS');
                good=1;
            catch
                % disp('Can''t read Seabird. Pausing 1 second...')
                pause(1)
            end
        end
        lpl=min(2199,ii-1);
        plot(sbd.time(ii-lpl:ii),sbd.t(ii-lpl:ii));datetick;
        % Heating calibration
        if ~isempty(strfind(caldir,'UP'))
            if sbd.t(ii)>(tpoint(nn)-0.005) && flag==0
                flag=1;
                set(ssb,'DataTerminalReady','off')
                i1=ii;
                % keep constant temperature at tpoint(nn)
                [sbd ii]=keeptemp(ssb,tpoint(nn),sbd,clock,ii);
                count(i1:ii)=nn;
            end
            if flag
                stp=1;
                set(ssb,'DataTerminalReady','on')
            end
        end
        % Cooling calibration
        if ~isempty(strfind(caldir,'DN'))
            if sbd.t(ii)<(tpoint(nn)+0.005) && flag==0
                flag=1;
                set(ssb,'DataTerminalReady','on')
                i1=ii;
                % keep constant temperature at tpoint(nn)
                [sbd ii]=keeptemp(ssb,tpoint(nn),sbd,clock,ii);
                count(i1:ii)=nn;
            end
            if flag
                stp=1;
                set(ssb,'DataTerminalReady','off')
            end
        end
    end
    sbe.time=sbd.time(1:ii);
    sbe.temp=sbd.t(1:ii);
    sbe.count=count(1:ii);
    save([outdir 'chipod_cal_sbd_' datestr(sbe.time(end),'yyyy-mm-dd') '_point_' num2str(nn)],'sbe')
end
text(0.1,0.4,'Calibration is over','fontsize',16,'units','normalized')
set(ssb,'DataTerminalReady','off')
set(source,'backgroundcolor',[0.8314 0.8157 0.7843])
fclose(ssb);
delete(ssb)
clear ssb
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
sbe.time=sbd.time(1:ii);
sbe.temp=sbd.t(1:ii);
sbe.count=count(1:ii);
save([outdir 'chipod_cal_sbd_' datestr(sbe.time(end),'yyyy-mm-dd')],'sbe')
return
end

function [sbd ii]=keeptemp(ssb,tpoint,sbd,tstart,ii)
title('TAKING  DATA  POINT','fontsize',16,'color','r')
while etime(clock,tstart)<1800
    pause(3)
    ii=ii+1;
    good=0;
    while ~good
        try
            fprintf(ssb,'%s\r','ts')
            % the readout includes three lines: comand sent, sensor output and
            % confirmation that execution was successful
            junk=fgets(ssb);
            sbdline=fgets(ssb);
            junk=fgets(ssb);
            sbline=textscan(sbdline(2:end),'%f %f %s %s','delimiter',',');
            sbd.t(ii)=sbline{1}; sbd.c(ii)=sbline{2};
            sbd.time(ii)=datenum([char(sbline{3}) char(sbline{4})],'dd mmm yyyyHH:MM:SS');
            good=1;
        catch
            % disp('Can''t read Seabird. Pausing 1 second...')
            pause(1)
        end
    end
    lpl=min(2199,ii-1);
    plot(sbd.time(ii-lpl:ii),sbd.t(ii-lpl:ii));datetick;
    title('TAKING  DATA  POINT','fontsize',16,'color','r')
%     if sbd.t(ii)+1.2*(sbd.t(ii)-sbd.t(ii-1))<tpoint
%         set(ssb,'DataTerminalReady','on')
%     elseif sbd.t(ii)+1.2*(sbd.t(ii)-sbd.t(ii-1))>tpoint
%         set(ssb,'DataTerminalReady','off')
%     end
    if sbd.t(ii)<tpoint && (sbd.t(ii)-sbd.t(ii-1))<0
        set(ssb,'DataTerminalReady','on')
    elseif sbd.t(ii)>tpoint
        set(ssb,'DataTerminalReady','off')
    elseif sbd.t(ii)+1.5*(sbd.t(ii)-sbd.t(ii-1))>tpoint
        set(ssb,'DataTerminalReady','off')
    end
end
title('')
end
