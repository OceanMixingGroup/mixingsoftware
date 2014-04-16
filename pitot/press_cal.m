close all
clear all

sensornum = input('Enter the pitot tube serial number: ','s')
conn = input('Which channel is the pitot tube plugged into? (1-4): ');
if rem(conn,1)~=0 || conn>4 || conn<1
    disp('Invalid channel number. Script terminated.')
    return
end

samplerate=100;  % Hz
time=8*60;  % in seconds
myadc = analoginput('mcc');
set(myadc, 'Tag', 'DaqControl');

Chan = addchannel(myadc,0:5);
Range5 = [-5 5];

set(Chan(1:6),'InputRange',Range5);
set(Chan(1:6),'SensorRange',Range5);
set(Chan(1:6),'UnitsRange',Range5);

set(Chan(1),'ChannelName','thermistor');
set(Chan(2),'ChannelName','pitot1');
set(Chan(3),'ChannelName','pitot2');
set(Chan(4),'ChannelName','pitot3');
set(Chan(5),'ChannelName','pitot4');
set(Chan(6),'ChannelName','pressure')

set(myadc, 'TriggerType', 'immediate');

set(myadc,'SampleRate',samplerate)
set(myadc,'SamplesPerTrigger',samplerate*time)
% set(myadc,'TimerPeriod',0.5);

% Run DAQ
disp('Starting DAQ');
disp('Data will collect for 8 minutes.  Slowly release pressure from 300psi to zero.')
start(myadc)
[data,time] = getdata(myadc);

% while(strcmpi(get(myadc,'Running'),'On')) % To keep the code running until the callback issues a stop
%    pause(0.5);
% end

ptest.time=time';

% calculate temp
vtemp = data(:,1);
gain = 5.5;
for i=1:length(vtemp);
Rt(i) = (vtemp(i)/gain)/((1.2-(vtemp(i)/gain))/17200);
end
lnRt = log(Rt);
lnRt3 = lnRt.^3;
ptest.temp = ( 74.614 + -18.1220*lnRt +0.1392*lnRt3);

% collect pitot voltage
pitot = data(:,conn+1);
ptest.pitot = pitot';

% calculate pressure
vpress = data(:,6);
vpress = vpress';
ptest.press = 76.51*vpress-29.056;

% save data
try
    save(['\\ganges\Work\Instrument_info_Documentation&Soft\pitot\Calibrations\pressure cals\' sensornum '_presscal_' datestr(now,'yyyy-mm-dd-hh')],'ptest');
    disp(['Data saved to:',10, '\\ganges\Work\Instrument_info_Documentation&Soft\pitot\Calibrations\pressure cals\' sensornum '_press_cal_' datestr(now,'yyyy-mm-dd-hh') '.mat'])
catch
    save([pwd '\' sensornum '_presscal_' datestr(now,'yyyy-mm-dd-hh')],'ptest');
    disp(['Data saved to:',10, pwd '\' sensornum '_press_cal_' datestr(now,'yyyy-mm-dd-hh') '.mat'])
end

% Close DAQ
delete(myadc);

% Display data
figure
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
subplot(2,2,1)
plot(ptest.pitot)
title('Pitot Output')
ylabel('V')

subplot(2,2,2)
plot(ptest.press)
title('Pressure')
ylabel('psi')

subplot(2,2,3)
plot(ptest.temp)
title('Temperature')
ylabel('C')

subplot(2,2,4)
plot(ptest.time)
title('Time')
ylabel('sec')
