function PTCal8(source,eventdata,handles)
% function to run pitot temp calibration. 
% This function is called by PTempCal4.m
% It controls the coooler to collect temperature, pressure and pitot data.
% This version begins data collection when it reaches the desired start temperature
% and cools until it reaches the desired end temperature.  There is no attempt
% to hold set points----that is really difficult because of time lag.
% This version also saves different files for each pitot tube in the cal tank.
%
%
% Input arguments:
% 
% source - 
% eventdata - 
% handles - handles is a structure of GUI inputs
%  


global cooleron;
global stopflag;
global dio;
global slopesum;
global tanktemp;
cooleron = 0;

warning off;
if ~isempty(strfind(get(source,'Enable'),'on'))
    set(source,'backgroundcolor','g')
end
pause(0.1);
slopesum = 0;
tanktemp = 30.2;

% get calibration parameters
extradata= handles.tempdata;

time=ones(1,100000)*NaN;
temp=ones(1,100000)*NaN;
press=ones(1,100000)*NaN;
pitot=ones(4,100000)*NaN;
tsum = 0;

ylabel('Thermistor temperature [^oC]')

%   myadc has to be opened  also sets up globals dio and tcontrol
myadc = OpenDAQ();
CoolerOn(handles);

% wait for temperature to reach desired start point
ii=1;
[ctemp, pitot(1:4,ii), press(ii)]  = TTemp(myadc);
while ctemp < extradata.tstart
    pause(2);
    [temp(ii), pitot(1:4,ii), press(ii)]  = TTemp(myadc);
    time(ii)=now;
    ctemp = temp(ii);
    
    lpl=min(1080,ii-1);
    set(handles.EDCurrent, 'String', temp(ii));
    plot(time(ii-lpl:ii),temp(ii-lpl:ii));kdatetick2;
    title('Warming to Start Temperature','fontsize',16);
    
    slope = findslope(time, temp, ii);
    slopestr = sprintf('%8.4f',slope);
    set(handles.EDSlope, 'String', slopestr);
    
    esttime = round(10*(extradata.tstart - ctemp)/slope/60)/10;
    esttimestr = sprintf('%8.1f',esttime);
    set(handles.EDesttime, 'String', esttimestr);
    
    ii=ii+1;
    
    if stopflag
        UserHalt(myadc);
        return
    end
end

% tell user to manually switch heater to cooler
beep
% msgbox('Switch from heater to cooler');

% collect data while temperature cools to end point (overwrites previous
% data from wait period)
ii=1;
while ctemp > extradata.tend
    pause(2);
    [temp(ii), pitot(1:4,ii), press(ii)]  = TTemp(myadc);
    time(ii)=now;
    ctemp = temp(ii);
    
    lpl=min(1080,ii-1);
    set(handles.EDCurrent, 'String', temp(ii));
    plot(time(ii-lpl:ii),temp(ii-lpl:ii));kdatetick2;
    title('Cooling to End Temperature','fontsize',16);
    
    slope = findslope(time, temp, ii);
    slopestr = sprintf('%8.4f',slope);
    set(handles.EDSlope, 'String', slopestr);
    
    if slope~=0
    esttime = round(10*(extradata.tend - ctemp)/slope/60)/10;
    esttimestr = sprintf('%8.1f',esttime);
    set(handles.EDesttime, 'String', esttimestr);
    end
    
    ii=ii+1;
    
    if stopflag
        UserHalt(myadc);
        return
    end
end

title('Calibration completed','fontsize',16)
CoolerOff(handles);
set(source,'backgroundcolor',[0.8314 0.8157 0.7843])

% Save separate files for each pitot tube
ii=ii-1;
for channel=1:4
    ptest.time=time(1:ii);
    ptest.temp=temp(1:ii);
    ptest.pitot = pitot(channel,1:ii);
    ptest.press = press(1:ii);
    ptest.tstart = extradata.tstart;
    ptest.tend = extradata.tend;
    
    eval(['chan=extradata.chan' num2str(channel) ';'])
    if isempty(chan)
        eval(['chan = ''channel' num2str(channel) ''';'])
    end
    filestr=[chan '_tempcal_' datestr(now,'yyyy-mm-dd')];
    file{channel}=filestr;
    try
        dir='\\GANGES\Work\Instrument_info_Documentation&Soft\pitot\Calibrations\tempcals\';
        save([dir file{channel}],'ptest');
    catch
        dir=pwd;
        save([dir file{channel}],'ptest');
    end
end

% display save information in plot
text(min(get(gca,'XLim')),max(get(gca,'YLim')),['Data files saved to path:',...
    dir,file(1),file(2),file(3),file(4)],'VerticalAlignment','top')

CloseDAQ(myadc);

return
end

% this function returns a somewhat smoothed slope
% (4-element smoothing)
function slope = findslope(time, temp, ii)
global slopesum;
 if ii < 12
     slope = -1;
 else
    slopex = (temp(ii)-temp(ii-10))/(time(ii)-time(ii-10));
    slopesum = slopesum * 0.75 + slopex;
    % divide slope by 86400 since dTime is in days, not seconds
    slope = (slopesum/4)/86400.0;
 end
 
end


%  Support functions
function dev = OpenDAQ()
global dio;
global tcontrol;
Range5 = [-5 5];
Range1 = [-1 1];
ai = analoginput('mcc');
dio = digitalio('mcc');
tcontrol = addline(dio, 0, 'Out');
set(ai, 'Tag', 'DaqControl');

set(ai, 'SampleRate', 50);
putvalue(tcontrol, 1);
set(ai, 'SamplesPerTrigger', 50)
Chan = addchannel(ai,0:5);
set(Chan(1:6),'InputRange',Range5);
set(Chan(1:6),'SensorRange',Range5);
set(Chan(1:6),'UnitsRange',Range5);

set(Chan(1),'ChannelName','thermistor');
set(Chan(2),'ChannelName','pitot1');
set(Chan(3),'ChannelName','pitot2');
set(Chan(4),'ChannelName','pitot3');
set(Chan(5),'ChannelName','pitot4');
set(Chan(6),'ChannelName','pressure')

set(ai, 'TriggerType', 'immediate');
dev = ai;
end

function CloseDAQ(dev)
global dio;
stop(dev)
stop(dio);

delete(dev);
delete(dio);
clear dev;
clear dio;
end

% do an orderly shutdown before returning from main function
function UserHalt(dev)
    CloseDAQ(dev);
    title('Halted by user');
end


% read the temperature, pitot, pressure 
function [temp, pitot, press] = TTemp(dev)
set(dev, 'SamplesPerTrigger', 50);
% 50 samples at 50 samples/sec should take about 1 second
start(dev)  
wait(dev, 2);
data = getdata(dev);
vtemp = mean(data(:,1));

gain = 5.5;
Rt = (vtemp/gain)/((1.2-(vtemp/gain))/17200);
%Rt = V;
lnRt = log(Rt);
lnRt3 = lnRt.^3;
temp = ( 74.614 + -18.1220*lnRt +0.1392*lnRt3);
% 8/15/13  correct bug in channel assignments
% pitot1 is channel 2, since channel 1 is temperature
pitot(1) = mean(data(:,2));
pitot(2) = mean(data(:,3));
pitot(3) = mean(data(:,4));
pitot(4) = mean(data(:,5));

vpress = mean(data(:,6));
press = 76.51*vpress-29.056;

%pause(1);
 
end

% Coooler control functions
% when output bit is on, the cooler is OFF!
function CoolerOn(handles)
global tcontrol;
global cooleron;
    cooleron = 1;
    putvalue(tcontrol,0);
end

function CoolerOff(handles)
global tcontrol;
global cooleron;
	cooleron = 0;
    putvalue(tcontrol,1);
end