function [Noise_in, Noise_out] = NoiseDAQ(fs,n_samples)

%function to input noise for temperature cals using MCC DAQ (USB-1608FS)system
%when declaring function input 
% 1. fs as sampling frequency
% 2. n_samples as number of samples

%make sure the DAQ system is connected to the PC when running the NoiseDAQ
%function. The function gives two outputs, from Noise_in from Channel 0 
% Noise_out from Channel 1 respectively.
%max peak to peak voltage is [-5 5]. 
%For more details check the  USB-1608 user guide
% By Pavan Vutukur, pvutukur@coas.oregonstate.edu, Date: July 2, 2013

info = [];
ai = [];
Range = [-5 5];
% info = daqhwinfo('mcc');
ai = analoginput('mcc');
% ai = eval(info.ObjectConstructorName{2})
set(ai, 'Tag', 'DaqControl');



% fs = input('\nEnter the sampling frequency: '); ;  
set(ai, 'sampleRate', fs);
% n_samples = input('\nEnter the number of samples: ');
duration = n_samples/fs;

set(ai,'samplesPerTrigger',n_samples);
pause(1e-3);
Chan = addchannel(ai,0:1);
set(ai.Channel, 'InputRange', Range);
set(ai.Channel, 'SensorRange', Range);
set(ai.Channel, 'UnitsRange', Range);
set(Chan,'ChannelName','Noise Input');
set(Chan(2),'ChannelName','Noise Output');
set(ai, 'TriggerType', 'immediate');

display(ai.channel);

timeout = 2000;
data = [];
time = [];
timer=0;
start(ai)
s2 = [];

wait(ai,2000);  
 
  

global data
data = getdata(ai);

Noise_out = data(:,2);
Noise_in = data(:,1);


