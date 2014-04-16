function labTCcalibration(source,eventdata)
% function labTCcalibration(source,eventdata)
% Performs T or C calibrations.
% Called by function labTCcalibrationGUI,
% whith parameters (all in source):
% temperature calibration range, 
% calibration direction (heating or cooling),
% circuit and sensor names 
% and type of the calibrations (T or C) for each sensor.
% The function:
% - controls heater, cooler and pump through digital I/O;
% - collects analog data from up to 8 channels and serial data from MicroCat;
% - plots all collected data in real time;
% - collects MicroCat data and voltages at calibration points;
% - calculates calibration coefficients for all circuit/sensor pairs;
% - plots calibration results and saves calibration data.
% this is based on legacy interface, which currently is only supported in
% 32-bit Matlab
% $Revision: 1.3 $ $Date: 2013/01/15 18:38:12 $ $Author: aperlin $	
% A. Perlin, September 2010

% $$$$$ CUSTOMISABLE PARAMETERS $$$$$$$$$$$
% set sensor samplerate (in Hz)
samplerate=2;
% duration of the data to show in the real time plot (in seconds)
plotsec=1800;
% duration of the data to keep in memory (in hours)
keeptime=10;
% number of calibration points
nsb=10;
% standard deviation threshold
tstd=0.0012;tstop=clock;
% number of points for standard deviation calculation
nstd=10;
% Path to save calibration results
outdir='c:\work\calibration\TC\';
% polynom order for calibration
T_polynom_order=2;
C_polynom_order=1;
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

warning off;
if ~isempty(strfind(get(source,'Enable'),'on'))
    set(source,'backgroundcolor','g')
end
pause(0.1);
% get calibration parameters
hfig=get(source,'Parent');
extradata=get(hfig,'UserData');
if isempty(extradata.caldir)
    disp('Choose Heating or Cooling')
    set(source,'backgroundcolor',[0.8314 0.8157 0.7843])
    return
end
if extradata.Trange(1)==extradata.Trange(2)
    disp('Correct Temperature Range')
    set(source,'backgroundcolor',[0.8314 0.8157 0.7843])
    return
end
if isempty(extradata.circuits) || isempty(extradata.sensors)
    disp('Choose Circuits and Sensors')
    set(source,'backgroundcolor',[0.8314 0.8157 0.7843])
    return
end
% make output directory
mkdir(outdir);
outdir=[outdir '\' datestr(now,'yyyy-mm-dd') '\'];
mkdir(outdir);

% define calibration points
Trange=sort(extradata.Trange);
tpoint=linspace(Trange(1),Trange(2),nsb);
if strfind(extradata.caldir,'DN')
    tpoint=fliplr(tpoint);
end
disp(tpoint)
% number of channels
aa=char(extradata.sensors);
channels=[];
for ii=1:length(extradata.sensors)
    if ~all(isspace(aa(ii,:)))
        channels=[channels ii-1];
    end
end
sensors=[];
circuits=[];
caltype=[];
pairs=[];
for kk=1:channels(end)+1
    sensors=[sensors cellstr(extradata.sensors{kk})];
    circuits=[circuits cellstr(extradata.circuits{kk})];
    caltype=[caltype cellstr(extradata.type{kk})];
    pairs=[pairs cellstr([char(circuits(kk)) ' ' char(sensors(kk))])];
end
% Find any running data acquisition objects and stop them.
if (~isempty(daqfind))
    stop(daqfind)
end
ai = analoginput('mcc');
% Create the analog input object and add the
% lines for heating, cooling and pump control.
% addchannel(ai,channels);
addchannel(ai,[0:7]);
set(ai,'SampleRate',samplerate);
ai.TriggerRepeat=inf;
set(ai,'SamplesPerTrigger',keeptime*3600*ai.sampleRate);
set(ai,'TriggerFcn',@FlushOldTriggers)
% start analog input
start(ai)
flushdata(ai,'all')
% Create the digital I/O object and specify the
% channels that data should be collected from.
dio = digitalio('mcc');
hwlines = addline(dio,0:2,'out',{'Heat','Cool','Pump'});
% Create serial port object (Seabird)
fclose all;clear ssb;
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
ssb=serial('COM1');
% connects the serial port object to the device
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
%%
% create real time figure
temp=get(0,'ScreenSize');
fb=figure(2);
set(fb,'Menubar','none','color',[1 1 1],'Name','Real Time Data',...
    'Position',[0.5*temp(3),1,0.5*temp(3),temp(4)]);clf
% find number of calibrations to run
numcal=str2num(extradata.numcal);
good=0;
ii=1;
while ~good
    try
        fprintf(ssb,'%s\r','ts')
        % the readout includes three lines: comand sent, sensor output and
        % confirmation that execution was successful
        junk=fgets(ssb);
        sbdline=fgets(ssb);
        junk=fgets(ssb);
        temp=textscan(sbdline(2:end),'%f %f %s %s','delimiter',',');
        sbd.t(ii)=temp{1}; sbd.c(ii)=temp{2};
        sbd.time(ii)=datenum([char(temp{3}) char(temp{4})],'dd mmm yyyyHH:MM:SS');
        good=1;
    catch
        disp('Can''t read Seabird. Pausing 2 seconds...')
        pause(2)
    end
end
% If initial temperature during cooling calibration is lower than first
% calibration point, we need to heat the bath
while ~isempty(strfind(extradata.caldir,'DN')) &&  sbd.t(ii) < tpoint(1) % heat the bath
    ii=ii+1;
    putvalue(dio.Line,[1 0 1]);
    pause(10)
    [sbd,sensdata,senstime]=get_plot_TCcalibrations(ai,ssb,sbd,fb,ii,channels,plotsec,pairs);
end
% If initial temperature during heating calibration is higher than first
% calibration point, we need to cool the bath
while ~isempty(strfind(extradata.caldir,'UP')) &&  sbd.t(ii) > tpoint(1) % cool the bath
    ii=ii+1;
    putvalue(dio.Line,[0 1 1]);
    pause(10)
    [sbd,sensdata,senstime]=get_plot_TCcalibrations(ai,ssb,sbd,fb,ii,channels,plotsec,pairs);
end

for jj=1:numcal
    clear sensdata calibration
    pause(2);
    fprintf(ssb,'%s\r',['DateTime=' datestr(now,'mmddyyyyHHMMSS')])
    SetSeabirdTime=fgets(ssb);
    junk=fgets(ssb);
    disp(['Calibration started: ' SetSeabirdTime])
    ii=0;
    if jj==2 % second calibration
        flushdata(ai,'all')
        % change calibration direction
        if ~isempty(strfind(extradata.caldir,'UP'))
            extradata.caldir='DN';
        else
            extradata.caldir='UP';
        end
        tpoint=fliplr(tpoint);
    end
    % Turn on pump and heater or cooler, depending on the setup conditions
    if ~isempty(strfind(extradata.caldir,'UP')) % heating
        putvalue(dio.Line,[1 0 1]);
    else % cooling
        putvalue(dio.Line,[0 1 1]);
    end
    stdsbd=10;
    ii=0; sbd=[];
    for nn=1:length(tpoint)
        disp([nn tpoint(nn)])
        stp=0;
        takepoint=0;
        while ~stp
            ii=ii+1;
            % pause is nesessary because it cannot output faster that once in
            % 2.5 seconds, but 0.3 is enought here
            pause(0.3)
            [sbd,sensdata,senstime]=get_plot_TCcalibrations(ai,ssb,sbd,fb,ii,channels,plotsec,pairs);
            % turn off the pump when temperature rises above calibration point
            % for heating stage or drops below calibration point for cooling
            % stage
            if (~isempty(strfind(extradata.caldir,'UP')) && sbd.t(ii)>tpoint(nn)) || ...
                    (~isempty(strfind(extradata.caldir,'DN')) && sbd.t(ii)<tpoint(nn))
                putvalue(dio.Line(3),0);
                disp('Pump is off')
                takepoint=takepoint+1;
                if takepoint==1
                    tstop=clock;
                end
            end
            % if pump is not running check standard deviation
            if ~getvalue(dio.Line(3)) && length(sbd.t)>nstd
                % standard deviation of the last nstd Seabird measurements
                stdsbd=std(sbd.t(ii-(nstd-1):ii));
                disp(stdsbd)
            end
            % if standard deviation is less than the predefined threshold
            % get calibration point and turn on the pump and start the new cycle
            if etime(clock,tstop)>480 && stdsbd<tstd
                % duration of the last nstd Seabird measurements in seconds
                sbdtimediff=(sbd.time(ii)-sbd.time(ii-(nstd-1)))*86400;
                calibration.sbdT(nn,1)=mean(sbd.t(ii-(nstd-1):ii));
                calibration.sbdC(nn,1)=mean(sbd.c(ii-(nstd-1):ii));
                itime=[min(sbd.time(ii-(nstd-1):ii)) max(sbd.time(ii-(nstd-1):ii))];
                itt=find(senstime>=itime(1) & senstime<=itime(2));
                calibration.sensor(nn,:)=...
                    mean(sensdata(itt,1:channels(end)+1),1);
                calibration.sbdpointtime(nn,:)=[itime(1) itime(end)];
                calibration.senspointtime(nn,:)=[senstime(itt(1)) senstime(itt(end))];
                % turn on the pump again
                putvalue(dio.Line(3),1);
                disp('Pump is on')
                % start new cycle
                stp=1;
                stdsbd=10;
            end
        end
    end
    calibration.sensdata=peekdata(ai,keeptime*3600*ai.sampleRate);
    calibration.senstime=[-size(calibration.sensdata,1)/ai.samplerate+1/ai.samplerate:1/ai.samplerate:0]'/86400+now;
    calibration.sbd=sbd;
    calibration.circuits=circuits;
    calibration.sensors=sensors;
    calibration.type=caltype;
    flushdata(ai,'all')
    % turn off heater, cooler and pump
    putvalue(dio.Line,[0 0 0]);
    calibration=calibrate_tc(calibration,outdir,T_polynom_order,C_polynom_order,jj);
    save([outdir '\calibration' num2str(jj)],'calibration')
end
% stop and delete all objects and clear memory
stop(ai);
delete(ai);
clear ai 
stop(dio);
delete(dio);
clear dio
fclose(ssb);
delete(ssb);
clear ssb 
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
set(source,'backgroundcolor',[0.8314 0.8157 0.7843])
    function FlushOldTriggers(ai,eventdata)
        % Define Trigger Function
        % Every time new trigger is fired before last trigger is flushed
        % So that memory is not overloaded
        nt=get(ai,'TriggersExecuted');
        if nt>2
            flushdata(ai,'triggers')
        end
    end
    function calibration=calibrate_tc(calibration,outdir,T_polynom_order,C_polynom_order,jj)
        circuits=calibration.circuits;
        sensors=calibration.sensors;
        caltype=calibration.type;
        calibration.coeff=zeros(4,length(sensors));
        for ii=1:length(sensors)
            sens=char(caltype(ii));
            clear coeff;
            if char(caltype(ii))=='T'
                p=polyfit(calibration.sensor(:,ii),...
                    calibration.sbdT,T_polynom_order);
                coeff(1:T_polynom_order+1)=fliplr(p);
            elseif char(caltype(ii))=='C'
                p=polyfit(calibration.sensor(:,ii),...
                    calibration.sbdC,C_polynom_order);
                coeff(1:C_polynom_order+1)=fliplr(p);
            end
            calibration.coeff(1:length(coeff),ii)=coeff;
            
            fc=figure(38);clf
            subplot(3,1,1)
            if length(coeff)==4
                plot(calibration.sensor(:,ii),coeff(1)+...
                    coeff(2).*calibration.sensor(:,ii)+...
                    coeff(3).*calibration.sensor(:,ii).^2+...
                    coeff(4).*calibration.sensor(:,ii).^3,'k-')
                title(['Circuit ' char(circuits(ii)) ' Sensor ' char(sensors(ii)) ...
                    ': ' num2str(coeff(1)) ' + ' num2str(coeff(2)) '\cdotV + '...
                    num2str(coeff(3)) '\cdotV^2 + ' num2str(coeff(4)) '\cdotV^3'])
            elseif length(coeff)==3
                plot(calibration.sensor(:,ii),coeff(1)+...
                    coeff(2).*calibration.sensor(:,ii)+...
                    coeff(3).*calibration.sensor(:,ii).^2,'k-')
                title(['Circuit ' char(circuits(ii)) ' Sensor ' char(sensors(ii)) ...
                    ': ' num2str(coeff(1)) ' + ' num2str(coeff(2)) '\cdotV + '...
                    num2str(coeff(3)) '\cdotV^2'])
            elseif length(coeff)==2
                plot(calibration.sensor(:,ii),coeff(1)+...
                    coeff(2).*calibration.sensor(:,ii),'k-')
                title(['Circuit ' char(circuits(ii)) ' Sensor ' char(sensors(ii)) ...
                    ': ' num2str(coeff(1)) ' + ' num2str(coeff(2)) '\cdotV'])
            end
            if ~isnan(calibration.sensor(:,ii))
                set(gca,'ylim',[min(calibration.(['sbd' sens])) ...
                    max(calibration.(['sbd' sens]))],...
                    'xlim',[min(calibration.sensor(:,ii)) ...
                    max(calibration.sensor(:,ii))]);
            end
            xlabel('V')
            ylabel(['Fit ' sens])
            
            subplot(3,1,2)
            plot(calibration.(['sbd' sens]),'b.','markersize',15)
            hold on
            if length(coeff)==4
                plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)+...
                    coeff(3).*calibration.sensor(:,ii).^2+...
                    coeff(4).*calibration.sensor(:,ii).^3,'r.','markersize',15)
            elseif length(coeff)==3
                plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)+...
                    coeff(3).*calibration.sensor(:,ii).^2,'r.','markersize',15)
            elseif length(coeff)==2
                plot(coeff(1)+coeff(2).*calibration.sensor(:,ii),'r.','markersize',15)
            end
            legend(['Seabird ' sens],['Sensor ' sens],'location','best')
            if sens=='T'
                ylabel('T [\circC]')
            elseif sens=='C'
                ylabel('C [S/m]')
            end
            subplot(3,1,3)
            if length(coeff)==4
                plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)+...
                    coeff(3).*calibration.sensor(:,ii).^2+...
                    coeff(4).*calibration.sensor(:,ii).^3-...
                    calibration.(['sbd' sens]),'b.','markersize',15)
            elseif length(coeff)==3
                plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)+...
                    coeff(3).*calibration.sensor(:,ii).^2-...
                    calibration.(['sbd' sens]),'b.','markersize',15)
            elseif length(coeff)==2
                plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)-...
                    calibration.(['sbd' sens]),'b.','markersize',15)
            end
            legend(['Sensor ' sens ' - ' 'Seabird ' sens],'location','best')
            if char(caltype(ii))=='T'
                ylabel('T [\circC]')
            elseif char(caltype(ii))=='C'
                ylabel('C [S/m]')
            end
            orient(fc,'tall');
            print(fc,'-dpng','-r200',[outdir char(circuits(ii)) '_' char(sensors(ii)) '_' char(caltype(ii)) 'cals' num2str(jj) '.png']);
        end
    end
end



