function runTcalibration(source,eventdata)
% function to run Chipod T calibration using digital thermometer Seabird38. 
% This function is called by ChipodTcalibration.m
% $Revision: 1.3 $ $Date: 2012/11/21 17:50:29 $ $Author: aperlin $	
% A. Perlin, September 2010
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
time=ones(1,100000)*NaN;
temp=ones(1,100000)*NaN;
count=ones(1,100000)*NaN;
sp=subplot(3,2,[3:6]);
ylabel('Bath temperature [^oC]')
mkdir(outdir);
outdir=[outdir '\' datestr(now,'yyyy-mm-dd') '\'];
mkdir(outdir);
Trange=extradata.Trange;
tpoint=linspace(Trange(1),Trange(2),extradata.npts);
ssb=serial('COM1');
fopen(ssb);
set(ssb,'DataTerminalReady','off')
set(ssb,'DataTerminalReady','on')
if Trange(1)<Trange(2)
    caldir='UP';
    set(ssb,'DataTerminalReady','on')
    trm='on';
else
    caldir='DN';
    set(ssb,'DataTerminalReady','off')
    trm='off';
end
ii=1;
good=0;
while ~good
    try
        sbstring{ii}=fgets(ssb);
        temp(ii)=str2num(sbstring{ii});
        time(ii)=now;count(ii)=0;
        good=1;
    catch
        % disp('Can''t read Seabird. Pausing .5 seconds')
        try
            fclose(ssb);
            delete(ssb)
        end
        if ~isempty(instrfind)
            fclose(instrfind);
            delete(instrfind);
        end
        clear ssb
        pause(.4);
        ssb=serial('COM1');
        fopen(ssb);
        set(ssb,'DataTerminalReady','off')
        set(ssb,'DataTerminalReady',trm)
        good=0;
    end
end
if ~isempty(strfind(caldir,'UP')) && temp(ii)>Trange(1)
    disp('Bath temperature is higher than T start. Turning off heater...')
    t1=text(0.05,0.6,'Bath temperature is higher than T start.','fontsize',14,'units','normalized');
    t2=text(0.05,0.4,'Turning off heater...','fontsize',14,'units','normalized');
    set(ssb,'DataTerminalReady','off');trm='off';
    % Cooling the bath to reach first calibration point (cooling calibration)
    while temp(ii)>Trange(1)
        pause(4.4);
        ii=ii+1;
        good=0;
        while ~good
            try
                sbstring{ii}=fgets(ssb);
                temp(ii)=str2num(sbstring{ii});
                if temp(ii)>36 || temp(ii)<3 || abs(diff(temp(ii-1:ii)))>1
                    good=0;
                else
                    time(ii)=now;count(ii)=0;
                    good=1;
                end
            catch
                % disp('Can''t read Seabird. Pausing .5 seconds')
                try
                    fclose(ssb);
                    delete(ssb)
                end
                if ~isempty(instrfind)
                    fclose(instrfind);
                    delete(instrfind);
                end
                clear ssb
                pause(.4);
                ssb=serial('COM1');
                fopen(ssb);
                set(ssb,'DataTerminalReady','off')
                set(ssb,'DataTerminalReady',trm)
                good=0;
            end
        end
        lpl=min(1080,ii-1);
        plot(time(ii-lpl:ii),temp(ii-lpl:ii));kdatetick2;
    end
    % reached first calibration point, turning on heater
    try
        set(ssb,'DataTerminalReady','on')
    catch
        if ~isempty(instrfind)
            fclose(instrfind);
            delete(instrfind);
        end
        clear ssb
        pause(.4);
        ssb=serial('COM1');
        fopen(ssb);
        set(ssb,'DataTerminalReady','off')
        set(ssb,'DataTerminalReady','on')
    end
        
elseif ~isempty(strfind(caldir,'DN')) && temp(ii)<Trange(1)
    disp('Bath temperature is lower than T start. Turning on heater...')
    t1=text(0.05,0.6,'Bath temperature is lower than T start.','fontsize',14,'units','normalized');
    t2=text(0.05,0.4,'Turning on heater...','fontsize',14,'units','normalized');
    set(ssb,'DataTerminalReady','on');trm='on';
    % Heating the bath to reach first calibration point (heating calibration)
    while temp(ii)<Trange(1)
        pause(4.4);
        ii=ii+1;
        good=0;
        while ~good
            try
                sbstring{ii}=fgets(ssb);
                temp(ii)=str2num(sbstring{ii});
                if temp(ii)>36 || temp(ii)<3 || abs(diff(temp(ii-1:ii)))>1
                    good=0;
                else
                    time(ii)=now;count(ii)=0;
                    good=1;
                end
            catch
                % disp('Can''t read Seabird. Pausing .5 seconds')
                try
                    fclose(ssb);
                    delete(ssb)
                end
                if ~isempty(instrfind)
                    fclose(instrfind);
                    delete(instrfind);
                end
                clear ssb
                pause(.4);
                ssb=serial('COM1');
                fopen(ssb);
                % to turn heater on we should turn it explicitly off first
                set(ssb,'DataTerminalReady','off')
                set(ssb,'DataTerminalReady',trm)
                good=0;
            end
        end
        lpl=min(1080,ii-1);
        plot(time(ii-lpl:ii),temp(ii-lpl:ii));kdatetick2;
    end
    % reached first calibration point, turning off heater
    try
        set(ssb,'DataTerminalReady','off')
    catch
        if ~isempty(instrfind)
            fclose(instrfind);
            delete(instrfind);
        end
        clear ssb
        pause(.4);
        ssb=serial('COM1');
        fopen(ssb);
        set(ssb,'DataTerminalReady','off')
    end
end
for nn=1:length(tpoint)
    disp([nn tpoint(nn)])
    flag=0;
    stp=0;
    while ~stp
        pause(4.4)
        ii=ii+1;
        good=0;
        while ~good
            try
                sbstring{ii}=fgets(ssb);
                temp(ii)=str2num(sbstring{ii});
                if temp(ii)>36 || temp(ii)<3 || abs(diff(temp(ii-1:ii)))>1
                    good=0;
                else
                    time(ii)=now;count(ii)=0;
                    good=1;
                end
            catch
                % disp('Can''t read Seabird. Pausing .5 seconds')
                try
                    trm=get(ssb,'DataTerminalReady');
                    fclose(ssb);
                    delete(ssb)
                end
                if ~isempty(instrfind)
                    fclose(instrfind);
                    delete(instrfind);
                end
                clear ssb
                pause(.4);
                ssb=serial('COM1');
                fopen(ssb);
                set(ssb,'DataTerminalReady','off')
                set(ssb,'DataTerminalReady',trm)
                good=0;
            end
        end
        lpl=min(1080,ii-1);
        plot(time(ii-lpl:ii),temp(ii-lpl:ii));kdatetick2;
        % Heating calibration
        if ~isempty(strfind(caldir,'UP'))
            if temp(ii)>(tpoint(nn)-0.005) && flag==0
                flag=1; tpoint(nn)=temp(ii);
                try
                    set(ssb,'DataTerminalReady','off')
                catch
                    try
                        fclose(ssb);
                        delete(ssb)
                    end
                    if ~isempty(instrfind)
                        fclose(instrfind);
                        delete(instrfind);
                    end
                    clear ssb
                    pause(.4);
                    ssb=serial('COM1');
                    fopen(ssb);
                    set(ssb,'DataTerminalReady','off')
                end
                i1=ii;
                % keep constant temperature at tpoint(nn)
                [temp time ii ssb]=keeptemp(ssb,tpoint(nn),temp,time,clock,ii);
                count(i1:ii)=nn;
            end
            if flag
                stp=1;
                try 
                    set(ssb,'DataTerminalReady','on')
                catch
                    try
                        fclose(ssb);
                        delete(ssb)
                    end
                    if ~isempty(instrfind)
                        fclose(instrfind);
                        delete(instrfind);
                    end
                    clear ssb
                    pause(.4);
                    ssb=serial('COM1');
                    fopen(ssb);
                    set(ssb,'DataTerminalReady','off')
                    set(ssb,'DataTerminalReady','on')
               end
            end
        end
        % Cooling calibration
        if ~isempty(strfind(caldir,'DN'))
            if temp(ii)<(tpoint(nn)+0.005) && flag==0
                flag=1; tpoint(nn)=temp(ii);
                try
                    set(ssb,'DataTerminalReady','on')
                catch
                    try
                        fclose(ssb);
                        delete(ssb)
                    end
                    if ~isempty(instrfind)
                        fclose(instrfind);
                        delete(instrfind);
                    end
                    clear ssb
                    pause(.4);
                    ssb=serial('COM1');
                    fopen(ssb);
                    set(ssb,'DataTerminalReady','off')
                    set(ssb,'DataTerminalReady','on')
                end
                i1=ii;
                % keep constant temperature at tpoint(nn)
                [temp time ii ssb]=keeptemp(ssb,tpoint(nn),temp,time,clock,ii);
                count(i1:ii)=nn;
            end
            if flag
                stp=1;
                try
                    set(ssb,'DataTerminalReady','off')
                catch
                    try
                        fclose(ssb);
                        delete(ssb)
                    end
                    if ~isempty(instrfind)
                        fclose(instrfind);
                        delete(instrfind);
                    end
                    clear ssb
                    pause(.4);
                    ssb=serial('COM1');
                    fopen(ssb);
                    set(ssb,'DataTerminalReady','off')
                end
            end
        end
    end
    sbe.time=time(1:ii);
    sbe.temp=temp(1:ii);
    sbe.count=count(1:ii);
    save([outdir 'chipod_cal_sbd_' datestr(now,'yyyy-mm-dd') '_point_' num2str(nn)],'sbe')
end
text(0.1,0.4,'Calibration is over','fontsize',16,'units','normalized')
set(ssb,'DataTerminalReady','off')
set(source,'backgroundcolor',[0.8314 0.8157 0.7843])
sbe.time=time(1:ii);
sbe.temp=temp(1:ii);
sbe.count=count(1:ii);
% sbe.sbstring=sbstring;
save([outdir 'chipod_cal_sbd_' datestr(now,'yyyy-mm-dd')],'sbe')
fclose(ssb);
delete(ssb)
clear ssb
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
return
end

function [temp time ii ssb]=keeptemp(ssb,tpoint,temp,time,tstart,ii)
title('TAKING  DATA  POINT','fontsize',16,'color','r')
while etime(clock,tstart)<1800
    pause(4.4)
    ii=ii+1;
    good=0;
    while ~good
        try
            sbstring{ii}=fgets(ssb);
            temp(ii)=str2num(sbstring{ii});
            if temp(ii)>36 || temp(ii)<3 || abs(diff(temp(ii-1:ii)))>1
                good=0;
            else
                time(ii)=now;
                good=1;
            end
        catch
            % disp('Can''t read Seabird. Pausing .5 seconds')
            try
                trm=get(ssb,'DataTerminalReady');
                fclose(ssb);
                delete(ssb);
            catch
                trm='off';
            end
            if ~isempty(instrfind)
                fclose(instrfind);
                delete(instrfind);
            end
            clear ssb
            pause(.4);
            ssb=serial('COM1');
            fopen(ssb);
            set(ssb,'DataTerminalReady','off')
            set(ssb,'DataTerminalReady',trm)
            good=0;
        end
    end
    lpl=min(1080,ii-1);
    plot(time(ii-lpl:ii),temp(ii-lpl:ii));kdatetick2;
    title('TAKING  DATA  POINT','fontsize',16,'color','r')
%     if temp(ii)+1.2*(temp(ii)-temp(ii-1))<tpoint
%         set(ssb,'DataTerminalReady','on')
%     elseif temp(ii)+1.2*(temp(ii)-temp(ii-1))>tpoint
%         set(ssb,'DataTerminalReady','off')
%     end
    if temp(ii)<tpoint && (temp(ii)-temp(ii-1))<0
        try
            set(ssb,'DataTerminalReady','on')
        catch
            if ~isempty(instrfind)
                fclose(instrfind);
                delete(instrfind);
            end
            clear ssb
            pause(.4);
            ssb=serial('COM1');
            fopen(ssb);
            % we need to turn it off explicitly first time in order to turn it on
            set(ssb,'DataTerminalReady','off')
            set(ssb,'DataTerminalReady','on')
        end
    elseif temp(ii)>tpoint
        try
            set(ssb,'DataTerminalReady','off')
        catch
            if ~isempty(instrfind)
                fclose(instrfind);
                delete(instrfind);
            end
            clear ssb
            pause(.4);
            ssb=serial('COM1');
            fopen(ssb);
            set(ssb,'DataTerminalReady','off')
        end
    elseif temp(ii)+1.5*(temp(ii)-temp(ii-1))>tpoint
        try
            set(ssb,'DataTerminalReady','off')
        catch
            if ~isempty(instrfind)
                fclose(instrfind);
                delete(instrfind);
            end
            clear ssb
            pause(.4);
            ssb=serial('COM1');
            fopen(ssb);
            set(ssb,'DataTerminalReady','off')
        end
    end
end
title('')
end
