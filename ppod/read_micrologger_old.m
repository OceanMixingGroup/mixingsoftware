function micrologger=read_micrologger(fname)
% Read micrologger file corresponding to 
% airpod file. Function is called from raw_load_ppod.
% fname='\\mserver\data\Air_Ppod\Feb16_09\micrologger\tanktst2';
if nargin<1
    [raw_name,dirname]=uigetfile('*.*','Load Binary File');
    %[raw_name,dirname]=uigetfile('*.bin','Load Binary File', ...
    %              'MultiSelect','on');

    fname=[dirname raw_name];
end
fid = fopen(fname,'r');
% it takes too much time to read the data
% we should preallocate array to speed it up
% the file with 216008 entries is 2592096 bytes
% this is 12 bytes per line
% so we preallocate array acordingly to this proportion 
% plus 10% just to be on the safe side
d=dir(fname);
nlines=round(d.bytes/12*1.1);
m.time=NaN*zeros([nlines,1]);
m.tick=NaN*zeros([nlines,1]);
m.adc=NaN*zeros([nlines,3]);
iii=0;
while ~feof(fid)
    iii=iii+1;
    try
        m.time(iii)=fread(fid,1,'uint32');
        m.tick(iii)=fread(fid,1,'uint16');
        m.adc(iii,1:3)=fread(fid,3,'int16');
    catch
        break
    end
end
%reference time written unix time in seconds
% Column 1 is unix time in seconds.
% Column 2 is the internal sampling counter.  It has 160 'tics' per second.
% On every tick the accelerometers are sampled. Every 8'th tic, the last 8 samples
% are averaged and sent to the output file.
micrologger.time=datenum(1970,1,1)+m.time(1:iii)/3600/24+m.tick(1:iii)/3600/24/160;
% The last three columns are the averaged accelerometer samples.  The X Y and Z
% axis notations are rather arbitrary and depend on the mounting of the board.
% The values range from 0 to 4095 and correspond to voltages of 0 to 3.3V. 
micrologger.acc=m.adc(1:iii,1:3)/4095*3.3;
save([fname '.mat'],'micrologger')
fclose(fid);


