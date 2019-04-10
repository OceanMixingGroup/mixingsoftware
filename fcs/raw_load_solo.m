function [data] = raw_load_solo1(filnam)
%raw_load_solo loads a raw data file which has been uploaded from ChiSolo
%   The ChiSolo raw data files
% 

% /********************************************************
%    This is the input packet structure that gets the
%    8 16-bit integers from the ChiPod ADC card
%    It also has fields for other data added by the Teensy
% 
%  *********************************************************/
% struct adcpackettype {
%   unsigned long seconds; // replaced unsigned char sernum;
%   unsigned short tick;  // we use tick to demux the compass data
%   // Start with adcv values because they are  at serial input start
%   unsigned short adcv[8];
%   unsigned short ax;   //gets filled with sernum and command
%   unsigned short ay;   // and checksum, but then overwritten
%   unsigned short az;
%   short compmux;       // compass is 3 words 4 times per second
%   //30 bytes to here
%   // we want seconds to start on 4-byte boundary, or packing will be messed up
%   unsigned short spare; // pad to a multiple of 4 bytes
% };  //  32 bytes long
% #define WIDX 0
% #define T1PIDX 1
% #define S1IDX 2
% #define T2IDX 3
% #define T1IDX 4
% #define T2PIDX 5
% #define PIDX 6
% #define S2IDX 7

% jul2018 modified by BDR so can pass in filename as an argument (optional... if not passed, will ask with GUI)
% 26 Feb 2019 Pavan Vutukur added a temporary fix to the compass timing issue with a separate cmptime array that saves parses the data.time for compass in a 4Hz sample size i.e. same size as compass, heading,pitch. Use plot(data.cmptime,data.compass), plot(data.cmptime,data.pitch), plot(data.cmptime,data.roll) to view heading pitch and roll data respectively;

if ~exist('filnam', 'var')
    [raw_name,temp,~]=uigetfile('*.*','Load Binary File');
    filnam=[temp raw_name];
end

fid = fopen(filnam,'r');
% first get the number of bytes in file
fseek(fid,0,'eof'); % move to end of file
pos2 = ftell(fid); % pos2 is overall length of file
frewind(fid); % move back to beginning of file
nrecs = pos2/32;
nseconds=floor((pos2)/3200); % number of one second blocks
fprintf('%d seconds of data in the file\n',nseconds);

% read file as one large array
dvals = fread(fid,[16,nrecs],'uint16');
% break up array into structure elements
% seconds read as two 16-bit integers---low word first
data.secs = dvals(1,:) + dvals(2,:).*65536.0;
data.ticks = dvals(3,:);
data.W = dvals(4,:).*(4.096/65536);
data.S1 = dvals(5,:).*(4.096/65536);
data.T1P = dvals(6,:).*(4.096/65536);
data.T2 = dvals(7,:).*(4.096/65536);
data.T1 = dvals(8,:).*(4.096/65536);
data.T2P = dvals(9,:).*(4.096/65536);
data.P = dvals(10,:).*(4.096/65536);
data.S2 = dvals(11,:).*(4.096/65536);

data.AX = dvals(12,:).*(3.3/4096);
data.AY = dvals(13,:).*(3.3/4096);
data.AZ = dvals(14,:).*(3.3/4096);
data.compmux = dvals(15,:);
temp_x = mod(data.ticks,25);
cmp_idx = find(temp_x == 0);
pitch_idx = find(temp_x == 1);
roll_idx = find(temp_x == 2);
cmp_len = min([length(cmp_idx),length(pitch_idx),length(roll_idx)]);
%It was found that compass pitch and roll vary by 1 element in their
%respective array. Hence use the smallest array amongst these three for
%now.
%We need to update the firmware to fix this issue.
%02/20/2019 Pvutukur

data.spare = dvals(16,:);
%  now put the times into structure and convert to matlab times

tlen = length(data.secs);
tbase = double(datenum(1970,1,1));

tv = data.secs  + data.ticks./100.0; % seconds since base
 %   data.daytime(i) = mod( data.THi(i) * 65536.0 + data.TLo(i), 86400) +  data.tick(i)/100.0;
tv = tv./86400.0;  % matlab keeps time in days
tv = tv + tbase;
data.time = tv;

%This will parse the compmux and time for 4Hz data of compass sensor
%comprising of heading pitch and roll
for i = 1:cmp_len
    data.compass(i) = (data.compmux(cmp_idx(i)))./10;
    data.cmptime(i) = (data.time(cmp_idx(i))); 
    %
        data.pitch(i) = (data.compmux(pitch_idx(i)));
    if data.pitch(i) >32768
        data.pitch(i) = data.pitch(i)-65536;
    end
    
    data.roll(i) = (data.compmux(roll_idx(i)));
    if data.roll(i) >32768
        data.roll(i) = data.roll(i)-65536;
    end
    data.roll(i) = data.roll(i)./10;
    data.pitch(i) = data.pitch(i)./10;
end
fclose(fid);
end

