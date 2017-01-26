 function [data]= raw_load_gust(filnam)
% load an 8-channel GusT data file
%example 1 [data] = raw_load_gust('\\ganges\data\gust\test_gust.G001'; Pavan
%example 2 [data] = raw_load_gust(); Opens a window to select the raw file;
% 10/18/14 MJB  Fix file name and time array length
% 11/23/15 Adjust for new compass data format
if nargout<2
  % if no output arguments, assume that we want the globalized
  % version.  
  global data;
end 
data=[];

if nargin<1
    [raw_name,temp]=uigetfile('*.*','Load Binary File');
    filnam=[temp raw_name];
    if raw_name==0
        error('File not found')
        return
    end
end

% filnam=[temp raw_name];
% disp(sprintf('Reading data from %s',raw_name));
%  use full file name rather than raw_name
fid = fopen(filnam,'r');
fseek(fid,0,'eof'); % move to end of file
pos2 = ftell(fid); % pos2 is overall length of file
frewind(fid); % move back to beginning of file
% each second of data has 800 16-bit words of data and one 36-byte time
% record  or 1636 bytes

nseconds=floor((pos2)/1636); % number of one second blocks
disp(sprintf('%d seconds of data in the file',nseconds));
trec.sync = 0;
trec.sernum = 0;
trec.time = 0;
data = [];
syncword = 0;
scount = 0;

% if nseconds > maxtime
%     nseconds = maxtime;
% end
while syncword ~= 65535
    syncword = fread(fid,1,'uint16');
    scount = scount+1;
    if scount > 850
        schar = fread(fid,'uchar');
        scount = 0;
    end;
end;

data.compass = zeros((nseconds-1) * 4,1);
data.pitch = zeros((nseconds-1) *4,1);
data.roll = zeros((nseconds-1) *4,1);

fseek(fid,-2,'cof');
dout = zeros(100*(nseconds-1),8);
dblock = zeros(100,8);
%dout = [];
dtemp = zeros(100,8);
disp('sync found at ');
syncpos = ftell(fid);
disp(ftell(fid));
yidx = 1;


% if ftell(fid) == 1600 the first complete second is at file start
if syncpos == 1600
    fseek(fid, 0, 'bof');
    dblock  = fread(fid,800,'uint16'); 
    dblock = reshape(dblock,8,100)';
    dout(yidx:yidx+99, 1:8)= dblock;
    yidx = yidx+100;    
end
errcount = 0;
rpttime = 1000.0;
% now read the rest of the data
cmpidx = 1;
for ii= 1:nseconds-1
    if ii >= rpttime
        %disp(rpttime);
        rpttime = rpttime + 1000;
    end
    % read the new time record
    trec.sync = fread(fid,1,'uint16');
    trec.sernum = fread(fid,1,'uint16');
    trec.time = fread(fid,1,'uint32');
    % Interpret the compass data record
    cmpdata = fread(fid,12,'int16');
    data.compass(cmpidx) = cmpdata(1)/10.0;
    data.compass(cmpidx+1) = cmpdata(2)/10.0; 
    data.compass(cmpidx+2) = cmpdata(3)/10.0;
    data.compass(cmpidx+3) = cmpdata(4)/10.0;

    data.pitch(cmpidx) = cmpdata(5)/10.0;
    data.pitch(cmpidx+1) = cmpdata(6)/10.0; 
    data.pitch(cmpidx+2) = cmpdata(7)/10.0;
    data.pitch(cmpidx+3) = cmpdata(8)/10.0;

    data.roll(cmpidx) = cmpdata(9)/10.0;
    data.roll(cmpidx+1) = cmpdata(10)/10.0; 
    data.roll(cmpidx+2) = cmpdata(11)/10.0;
    data.roll(cmpidx+3) = cmpdata(12)/10.0;

    cmpidx = cmpidx+4;

    
    
    time(ii+1,1)=trec.time;
    if trec.sync ~= 65535
        disp('sync error at ');
        disp(ii);
        errcount = 1;
        break;
    end;

    dblock  = fread(fid,800,'uint16'); 
    dblock = reshape(dblock,8,100)';
    dout(yidx:yidx+99, 1:8)= dblock;
    yidx = yidx+100;
%
end;

%  now put in the starting time for the file as first time block -1
time1 = time(2,1)-1;
disp('read complete');
% convert to raw volts and move to output
if errcount == 0
    data.AY = dout(2:end,1).*(4.096/65536);
    data.AZ = dout(2:end,2).*(4.096/65536);
    data.AX = dout(2:end,3).*(4.096/65536);
    data.P = dout(2:end,4).*(4.096/65536);
    data.W = dout(2:end,5).*(4.096/65536);
    data.WP = dout(2:end,6).*(4.096/65536);
    data.T = dout(2:end,7).*(4.096/65536);
    data.TP = dout(2:end,8).*(4.096/65536);


%  now put the times into structure and convert to matlab times
starttime=(time1)/86400+double(datenum(1970,1,1));
hundredthsecond = 0.01 * 1/86400;  % matlab counts time in days
xtime = (0.0:hundredthsecond:(nseconds-0.01)/86400)';% transpose to make column vector
xtime = xtime + starttime;
% make sure time record is only as long as data
tlen = length(data.T);
clen = length(data.pitch);
t2len = clen*2;

data.time = xtime(1:tlen);

fclose(fid);
% plot channel 7   You may want to change the channel for other sensors
%plot(data.time, data.ch7);
%kdatetick2;
%xlabel('Collection date and time');
%ylabel('ADC counts');
end
